module Main exposing (..)

import Browser exposing (Document)
import Browser.Events
import Card exposing (..)
import Dict
import Extras.Html.Attributes exposing (none)
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes exposing (class, style)
import Html.Events as Events exposing (on, onClick)
import Html.Extra as Html exposing (nothing, static)
import Html.Parser as Parser
import Html.Parser.Util as Parser
import Json.Decode as Decode exposing (Value)
import List exposing (concat, concatMap, filter, foldl, indexedMap, length, map)
import List.Extra exposing (..)
import Maybe exposing (withDefault)
import Maybe.Extra as Maybe exposing (orElse)
import Process
import Random
import Result.Extra exposing (isOk)
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
    initGame


initGame =
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


attrIf cond a =
    if cond then
        a

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
        , if model.state == GameOver then
            div [ class "modal", on "pointerup" (Decode.succeed <| Restart) ]
                [ div [ class "modal-content" ]
                    [ text <| "Game over"
                    , Html.br [] []
                    , text <|
                        case
                            ( model.you.dead, model.they.dead )
                        of
                            ( False, True ) ->
                                "Victory!"

                            ( True, False ) ->
                                "Defeat..."

                            ( _, _ ) ->
                                "Draw."
                    ]
                ]

          else
            nothing
        ]


viewBoard : Model -> Html Msg
viewBoard model =
    let
        revealThey =
            model.state == Settling

        playing =
            model.state == Playing

        gameOver =
            model.state == GameOver

        predicted =
            playCards model.you
    in
    div [ class "h-full w-3/4 max-h-screen relative " ]
        [ div [ class "they flex p-1  text-gray-900", style "height" "25%" ]
            [ div [ class "flex-grow hand " ] <|
                map
                    (viewTheirCard gameOver revealThey)
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
                [ div [] [ text <| "❤️ Life " ++ String.fromInt model.you.health ++ " › " ++ String.fromInt predicted.health ]
                , div [] [ text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ++ " › " ++ String.fromInt predicted.sanity ]
                , div [] [ text <| "📖 Wisdom " ++ String.fromInt model.you.wisdomUsed ++ "/" ++ String.fromInt model.you.wisdom ]
                , case ( schemeValid model.you, predicted.health > 0 ) of
                    ( Err reason, _ ) ->
                        div [ class "text-red-600 tooltip" ] [ text <| "❌ Invalid scheme", tooltip (text <| reason) ]

                    ( _, False ) ->
                        div [ class "text-green-600 hover:text-green-300", attrIf playing (on "pointerup" (Decode.succeed <| SubmitScheme)) ] [ text <| "💀 Ritual suicide" ]

                    ( Ok (), True ) ->
                        div [ class "text-blue-600 hover:text-blue-300", attrIf playing (on "pointerup" (Decode.succeed <| SubmitScheme)) ] [ text <| "✨ Play scheme" ]
                ]
            , div [ class "flex-grow hand " ] <|
                map
                    (viewYourCard (model.state == Playing))
                    model.you.hand
            ]
        ]


tooltip : Html msg -> Html msg
tooltip content =
    div [ class "top" ]
        [ content
        , Html.i [] []
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
                ((text <| String.fromInt cost ++ " " ++ details.name)
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


viewTheirCard : Bool -> Bool -> { a | card : Card, selected : Bool, cost : Int } -> Html Msg
viewTheirCard gameOver settling { card, selected, cost } =
    if (selected && settling) || gameOver then
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
        Restart ->
            initGame

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
                    List.filter (schemeValid >> isOk) <|
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

        getEffectTotal from to scheme =
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
                scheme

        summonEffect player =
            player.summon |> Maybe.map (.effects >> filter .selected >> map .effects >> concat) |> withDefault []

        yourEffectTotal =
            getEffectTotal you they (concatMap .effect yourScheme ++ summonEffect you)

        theirEffectTotal =
            getEffectTotal they you (concatMap .effect theirScheme ++ summonEffect they)
    in
    { model
        | you =
            { you
                | health = you.health - theirEffectTotal.damage + yourEffectTotal.gainHealth
                , draw = you.draw + yourEffectTotal.draw
                , wisdom = you.wisdom + yourEffectTotal.gainWisdom
                , sanity = you.sanity + yourEffectTotal.gainSanity
                , summon = yourEffectTotal.summon |> orElse you.summon
            }
                |> playCards
        , they =
            { they
                | health = they.health - yourEffectTotal.damage + theirEffectTotal.gainHealth
                , draw = they.draw + theirEffectTotal.draw
                , wisdom = they.wisdom + theirEffectTotal.gainWisdom
                , sanity = they.sanity + theirEffectTotal.gainSanity
                , summon = theirEffectTotal.summon |> orElse they.summon
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
        |> updateCosts
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



-- TODO trigger on new turn


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


schemeValid : Player -> Result String ()
schemeValid player =
    if player.wisdomUsed > player.wisdom then
        Err "Not enough wisdom."

    else if (length <| filter (\c -> (cardDetails c.card).cardType == Types.M) (getScheme player.hand)) > 1 then
        Err "More then one summon selected."

    else
        Ok ()


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
