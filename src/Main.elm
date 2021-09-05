module Main exposing (..)

import Browser exposing (Document)
import Browser.Events
import Card exposing (..)
import Dict
import Extras.Html.Attributes exposing (none)
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes exposing (class, style)
import Html.Events as Events exposing (on, onClick)
import Html.Extra as Html exposing (static)
import Html.Parser as Parser
import Html.Parser.Util as Parser
import Json.Decode as Decode exposing (Value)
import List exposing (concatMap, filter, foldl, indexedMap, length, map)
import List.Extra exposing (..)
import Maybe.Extra as Maybe exposing (orElse)
import Process
import Random
import Set
import Storage exposing (Storage)
import Summon exposing (..)
import Svg exposing (Svg)
import Svg.Attributes
import Task
import Time
import Types exposing (..)


type alias Model =
    { you : Player
    , they : Player
    , turn : Int
    , state : State
    }


type State
    = Playing
    | Settling
    | GameOver


initPlayer : Player
initPlayer =
    { hand = []
    , health = 20
    , sanity = 20
    , wisdom = 4
    , wisdomUsed = 0
    , summon = Just (summonDetails M1)
    , dead = False
    , draw = 0
    }


handSize : number
handSize =
    7


init : Value -> ( Model, Cmd Msg )
init _ =
    ( { you = initPlayer
      , they = initPlayer
      , turn = 1
      , state = Playing
      }
      -- , Random.generate Spawn Tetrimino.random
    , Cmd.batch
        [ Random.generate DealYouHand (Random.list handSize Card.random)
        , Random.generate DealTheyHand (Random.list handSize Card.random)
        ]
    )



-- VIEW


classIf cond a =
    if cond then
        class a

    else
        none


ifElse cond a b =
    if cond then
        a

    else
        b


view : Model -> Document Msg
view model =
    { title = "Library of Azathoth"
    , body = [ viewRoot model ]
    }


viewRoot : Model -> Html Msg
viewRoot model =
    div [ class "flex justify-center h-full items-center select-none font-display relative" ]
        [ viewBoard model
        ]


viewBoard : Model -> Html Msg
viewBoard model =
    let
        revealThey =
            model.state == Settling
    in
    div [ class "h-full w-3/4 max-h-screen relative " ]
        [ div [ class "they flex p-1  text-gray-900", style "height" "25%" ]
            [ div [ class "flex-grow hand " ] <|
                map
                    (viewTheirCard revealThey)
                    model.they.hand
            , div [ class "flex-none playerStats text-gray-600", style "font-size" "200%" ]
                [ div [] [ text <| String.fromInt model.they.health ++ " Life ❤️" ]
                , div [] [ text <| String.fromInt model.they.sanity ++ " Sanity 🧠" ]
                , div [] [ text <| String.fromInt model.they.wisdomUsed ++ "/" ++ String.fromInt model.they.wisdom ++ " Wisdom 📖" ]
                ]
            ]
        , div [ class "flex p-1 justify-center text-gray-900 summons", style "height" "50%" ]
            [ viewSummon False revealThey model.they.summon, viewSummon True True model.you.summon ]
        , div [ class "you flex p-1  text-gray-900", style "height" "25%" ]
            [ div [ class "flex-none playerStats text-gray-600 ", style "font-size" "200%" ]
                [ div [] [ text <| "❤️ Life " ++ String.fromInt model.you.health ]
                , div [] [ text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ]
                , div [] [ text <| "📖 Wisdom " ++ String.fromInt model.you.wisdomUsed ++ "/" ++ String.fromInt model.you.wisdom ]
                , div
                    (if schemeValid model.you then
                        [ class "text-blue-600 hover:text-blue-300"
                        , if model.state == Playing then
                            on "pointerup" (Decode.succeed <| SubmitScheme)

                          else
                            none
                        ]

                     else
                        [ class "text-red-600" ]
                    )
                    [ text <| "✨ Play scheme" ]
                ]
            , div [ class "flex-grow hand " ] <|
                map
                    (viewYourCard (model.state == Playing))
                    model.you.hand
            ]
        ]


viewSummon : Bool -> Bool -> Maybe SummonDetails -> Html Msg
viewSummon interactive revealed summon =
    case summon of
        Nothing ->
            div [ class "imageContainer" ]
                [ div []
                    [ img [ Attributes.src cardBack ] []
                    ]
                ]

        Just { card, influence, effects } ->
            let
                cdetails =
                    cardDetails card
            in
            div [ class "imageContainer" ]
                [ div []
                    [ img [ Attributes.src cdetails.art ] []
                    , Html.span [ class "name", style "font-size" "200%" ] [ text <| cdetails.name, Html.br [] [], text <| String.fromInt influence ]
                    , Html.span [ class "text", style "font-size" "125%" ]
                        ((text <| cdetails.text)
                            :: viewSummonEffects interactive revealed effects
                        )
                    ]
                ]


viewSummonEffects interactive revealed effects =
    indexedMap
        (\i e ->
            button
                [ class "summonEffect"
                , classIf (e.selected && revealed) "selected"
                , ifElse interactive (onClick (SelectEffect i)) none
                ]
                [ viewSummonEffectCost e.cost, static e.text ]
        )
        effects


viewSummonEffectCost cost =
    Html.span [ class "summonEffectCost" ] [ text <| (ifElse (cost > 0) "+" "" ++ String.fromInt cost) ]


viewYourCard : Bool -> Held -> Html Msg
viewYourCard playing { card, selected, cost, index } =
    let
        details =
            Card.cardDetails card
    in
    div
        [ class "imageContainer"
        , if playing then
            on "pointerup" (Decode.succeed <| SelectCard index)

          else
            none
        ]
        [ div
            [ class
                (if selected then
                    "border-yellow-300 border-opacity-75"

                 else
                    "border-transparent"
                )
            ]
            [ img [ Attributes.src details.art ] []
            , Html.span [ class "name" ]
                (( text <| String.fromInt cost ++ " " ++ details.name )
                    :: (Maybe.map
                            (\sd ->
                                [ Html.br [] [], text <| String.fromInt sd.influence ]
                            )
                            (getSummonDetails card)
                            |> Maybe.withDefault []
                       )
                )
            , Html.span [ class "text" ]
                (Parser.toVirtualDom (Result.withDefault [ Parser.Comment "String" ] (Parser.run details.text))
                    ++ (Maybe.map
                            (\sd ->
                                viewSummonEffects False False sd.effects
                            )
                            (getSummonDetails card)
                            |> Maybe.withDefault []
                       )
                )

            -- , Html.span [ class "cost" ] [ text <| String.fromInt details.cost ]
            ]
        ]


viewTheirCard : Bool -> { a | card : Card, selected : Bool, cost : Int } -> Html Msg
viewTheirCard settling { card, selected, cost } =
    if selected && settling then
        let
            details =
                Card.cardDetails card
        in
        div
            [ class "imageContainer" ]
            [ div
                [ class
                    (if selected then
                        "border-yellow-300 border-opacity-75"

                     else
                        "border-transparent"
                    )
                ]
                [ img [ Attributes.src details.art ] []
                , Html.span [ class "name" ] [ text <| String.fromInt cost ++ " " ++ details.name ]
                , Html.span [ class "text" ] [ text details.text ]

                -- , Html.span [ class "cost" ] [ text <| String.fromInt cost ]
                ]
            ]

    else
        div [ class "imageContainer" ]
            [ div [ class "border-transparent" ]
                [ img [ Attributes.src cardBack ] []

                -- , Html.span [] [ Html.text "blabla" ]
                ]
            ]



-- UPDATE


type Msg
    = Restart
    | SelectCard Int
    | SelectEffect Int
    | SubmitScheme
    | SettleSchemes
    | DealYouHand (List Card)
    | DealTheyHand (List Card)
    | DealYouCards (List Card)
    | DealTheyCards (List Card)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ you, they } as model) =
    case msg of
        SelectCard card ->
            ( { model | you = selectCard you card }
            , Cmd.none
            )

        SelectEffect i ->
            ( { model | you = selectEffect you i }
            , Cmd.none
            )

        DealYouHand cards ->
            ( { model | you = dealHand you cards }
            , Cmd.none
            )

        DealTheyHand cards ->
            ( { model | they = dealHand they cards }
            , Cmd.none
            )

        SubmitScheme ->
            ( { model | state = Settling } |> randomAI
            , Process.sleep 2000
                |> Task.perform (\_ -> SettleSchemes)
            )

        SettleSchemes ->
            let
                settled =
                    model |> settleSchemes
            in
            ( settled
            , Cmd.batch
                [ Random.generate DealYouCards (Random.list settled.you.draw Card.random)
                , Random.generate DealTheyCards (Random.list settled.they.draw Card.random)
                ]
            )

        DealYouCards cs ->
            ( { model | you = dealCards you cs }
            , Cmd.none
            )

        DealTheyCards cs ->
            ( { model | they = dealCards they cs }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


possibleHands : List { a | selected : Bool } -> List (List { a | selected : Bool })
possibleHands list =
    case list of
        [] ->
            [ [] ]

        head :: rest ->
            concatMap
                (\r -> [ { head | selected = True } :: r, { head | selected = False } :: r ])
                (possibleHands rest)


randomAI : Model -> Model
randomAI ({ they } as model) =
    { model
        | they =
            Maybe.withDefault they <|
                List.head <|
                    List.filter schemeValid <|
                        map (\option -> updateCosts { they | hand = option }) <|
                            possibleHands they.hand
    }


settleSchemes : Model -> Model
settleSchemes ({ you, they } as model) =
    let
        yourScheme =
            map (\c -> cardDetails c.card) <| getScheme you.hand

        theirScheme =
            map (\c -> cardDetails c.card) <| getScheme they.hand

        getEffect from to scheme =
            foldl
                (\step total ->
                    case step of
                        Damage f ->
                            { total | damage = total.damage + f from to }

                        Draw f ->
                            { total | draw = total.draw + f from to }

                        GainWisdom f ->
                            { total | gainWisdom = total.gainWisdom + f from to }

                        GainSanity f ->
                            { total | gainSanity = total.gainSanity + f from to }

                        GainHealth f ->
                            { total | gainHealth = total.gainHealth + f from to }

                        Summon m ->
                            { total | summon = Just (summonDetails m) }

                        _ ->
                            total
                )
                { damage = 0, draw = 0, gainWisdom = 0, gainSanity = 0, gainHealth = 0, summon = Nothing }
            <|
                concatMap .effect scheme

        yourEffect =
            getEffect you they yourScheme

        theirEffect =
            getEffect they you theirScheme
    in
    { model
        | you =
            { you
                | health = you.health - theirEffect.damage + yourEffect.gainHealth
                , draw = you.draw + yourEffect.draw
                , wisdom = you.wisdom + yourEffect.gainWisdom
                , sanity = you.sanity + yourEffect.gainSanity
                , summon = yourEffect.summon |> orElse you.summon
            }
                |> playCards
        , they =
            { they
                | health = they.health - yourEffect.damage + theirEffect.gainHealth
                , draw = they.draw + theirEffect.draw
                , wisdom = they.wisdom + theirEffect.gainWisdom
                , sanity = they.sanity + theirEffect.gainSanity
                , summon = theirEffect.summon |> orElse they.summon
            }
                |> playCards
        , state = Playing
    }
        |> calcGameOver


calcGameOver : Model -> Model
calcGameOver model =
    { model
        | state =
            if model.you.dead || model.they.dead then
                GameOver

            else
                model.state
    }


playCards : Player -> Player
playCards ({ hand, wisdom, wisdomUsed, sanity, draw } as player) =
    { player
        | hand = List.filter (\held -> not held.selected) <| hand
        , wisdom = wisdom + 1
        , wisdomUsed = 0
        , sanity = sanity - wisdomUsed
        , draw = draw + 1
    }
        |> drainSanityFromHealth
        |> calcPlayerDead


drainSanityFromHealth : { a | sanity : number, health : number } -> { a | sanity : number, health : number }
drainSanityFromHealth player =
    if player.sanity >= 0 then
        player

    else
        { player
            | sanity = 0
            , health = player.health + player.sanity
        }


calcPlayerDead : Player -> Player
calcPlayerDead player =
    { player
        | dead = player.health <= 0
    }


id x =
    x


dealHand : Player -> List Card -> Player
dealHand player cards =
    { player
        | hand = sortHand <| map (\c -> { card = c, selected = False, cost = (cardDetails c).cost, index = -1 }) <| cards
        , draw = 0
    }


dealCards : Player -> List Card -> Player
dealCards ({ hand } as player) cs =
    { player
        | hand = sortHand <| List.append hand (map (\c -> { card = c, selected = False, cost = (cardDetails c).cost, index = -1 }) cs)
        , draw = 0
    }


sortHand : List Held -> List Held
sortHand hand =
    indexedMap (\i c -> { c | index = i }) <| List.sortBy (\h -> cardDetails h.card |> .cost) <| List.sortBy (\h -> cardDetails h.card |> .name) hand


selectCard : Player -> Int -> Player
selectCard ({ hand } as player) i =
    { player
        | hand =
            List.map
                (\c ->
                    if c.index == i then
                        { c | selected = not c.selected }

                    else
                        c
                )
                hand
    }
        |> updateCosts


selectEffect : Player -> Int -> Player
selectEffect ({ summon } as player) selected =
    case summon of
        Nothing ->
            player

        Just ({ influence, effects } as jsummon) ->
            { player
                | summon =
                    Just
                        { jsummon
                            | effects = indexedMap (\i e -> { e | selected = i == selected }) effects
                        }
            }


getScheme hand =
    List.filter (\held -> held.selected) <| hand


updateCosts : Player -> Player
updateCosts ({ hand } as player) =
    let
        initCosts =
            map (\held -> { held | cost = (cardDetails held.card).cost })

        playerScheme =
            getScheme player.hand

        modCosts ( e_card, e ) h =
            case e of
                CostMod f ->
                    map (\held -> { held | cost = held.cost + f player e_card held }) h

                _ ->
                    h

        allModCosts h =
            foldl modCosts h (concatMap (\e_card -> map (\e -> ( e_card, e )) (cardDetails e_card.card).effect) playerScheme)

        clampCosts =
            map (\held -> { held | cost = max 0 held.cost })

        updatedHand =
            hand
                |> initCosts
                |> allModCosts
                |> clampCosts
    in
    { player
        | hand = updatedHand
        , wisdomUsed = List.sum <| map (\h -> h.cost) <| List.filter .selected updatedHand
    }


schemeValid : Player -> Bool
schemeValid player =
    player.wisdomUsed
        <= player.wisdom
        && 1
        >= (length <| filter (\c -> (cardDetails c.card).cardType == Types.M) (getScheme player.hand))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []


main : Program Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
