module Main exposing (..)

import Browser exposing (Document)
import Browser.Events
import Card exposing (..)
import Dict
import Extras.Html.Attributes exposing (none)
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes exposing (selected)
import Html.Events as Events
import Json.Decode as Decode exposing (Value)
import List exposing (map)
import List.Extra exposing (..)
import Process
import Random
import Set
import Storage exposing (Storage)
import Svg exposing (Svg)
import Svg.Attributes
import Task
import Time


type alias Model =
    { you : Player
    , they : Player
    , turn : Int
    , state : State
    }


type alias Player =
    { hand : List { card : Card, selected : Bool }
    , health : Int
    , sanity : Int
    , wisdom : Int
    , wisdomUsed : Int
    , summon : Maybe Card
    , dead : Bool
    , draw : Int
    }


initPlayer : Player
initPlayer =
    { hand = []
    , health = 20
    , sanity = 20
    , wisdom = 1
    , wisdomUsed = 0
    , summon = Just W14
    , dead = False
    , draw = 0
    }


type State
    = Playing
    | Settling
    | GameOver


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


view : Model -> Document Msg
view model =
    { title = "Library of Azathoth"
    , body = [ viewRoot model ]
    }


viewRoot : Model -> Html Msg
viewRoot model =
    div [ Attributes.class "flex justify-center h-full items-center select-none font-display relative" ]
        [ viewBoard model
        ]


viewBoard : Model -> Html Msg
viewBoard model =
    div [ Attributes.class "h-full w-3/4 max-h-screen relative " ]
        [ div [ Attributes.class "flex p-1 justify-start", Attributes.style "height" "25%" ]
            (map
                (viewTheirCard (model.state == Settling))
                model.they.hand
                ++ [ div [ Attributes.class "flex-grow playerStats text-right text-gray-600", Attributes.style "font-size" "200%" ]
                        [ div [] [ text <| String.fromInt model.they.health ++ "/20 Health ❤️" ]
                        , div [] [ text <| String.fromInt model.they.sanity ++ "/20 Sanity 🧠" ]
                        , div [] [ text <| String.fromInt model.they.wisdomUsed ++ "/" ++ String.fromInt model.they.wisdom ++ " Wisdom 📖" ]
                        ]
                   ]
            )
        , div [ Attributes.class "flex p-1 justify-center text-gray-900", Attributes.style "height" "50%" ]
            (map
                (\mcard ->
                    case mcard of
                        Nothing ->
                            div [ Attributes.class "imageContainer border-small border-transparent" ]
                                [ div []
                                    [ img [ Attributes.src cardBack ] []
                                    ]
                                ]

                        Just card ->
                            div [ Attributes.class "imageContainer border-small border-transparent" ]
                                [ div []
                                    [ img [ Attributes.src card.art ] []
                                    , Html.span [ Attributes.class "text ", Attributes.style "font-size" "200%" ]
                                        [ button [ Attributes.class "block" ] [ text "+1: Stab" ]
                                        , button [ Attributes.class "block" ] [ text "0: Learn" ]
                                        , button [ Attributes.class "block" ] [ text "-5: Kill" ]
                                        ]
                                    ]
                                ]
                )
                [ Maybe.map cardDetails model.they.summon, Maybe.map cardDetails model.you.summon ]
            )
        , div [ Attributes.class "you flex p-1  text-gray-900", Attributes.style "height" "25%" ]
            [ div [ Attributes.class "flex-none playerStats text-gray-600 mr-8 ", Attributes.style "font-size" "200%" ]
                [ div [] [ text <| "❤️ Health " ++ String.fromInt model.you.health ++ "/20" ]
                , div [] [ text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ++ "/20" ]
                , div [] [ text <| "📖 Wisdom " ++ String.fromInt model.you.wisdomUsed ++ "/" ++ String.fromInt model.you.wisdom ]
                , div
                    (if schemeValid model.you then
                        [ Attributes.class "text-blue-600 hover:text-blue-300"
                        , if model.state == Playing then
                            Events.on "pointerup" (Decode.succeed <| SubmitScheme)

                          else
                            none
                        ]

                     else
                        [ Attributes.class "text-red-600" ]
                    )
                    [ text <| "✨ Play scheme" ]
                ]
            , div [ Attributes.class "flex-grow hand " ] <|
                List.indexedMap
                    (\i { card, selected } ->
                        let
                            details =
                                Card.cardDetails card
                        in
                        div
                            [ Attributes.class "imageContainer"
                            , if model.state == Playing then
                                Events.on "pointerup" (Decode.succeed <| SelectCard i)

                              else
                                none
                            ]
                            [ div
                                [ Attributes.class
                                    (if selected then
                                        "border-yellow-300 border-opacity-75"

                                     else
                                        "border-transparent"
                                    )
                                ]
                                [ img [ Attributes.src details.art ] []
                                , Html.span [ Attributes.class "name" ] [ text <| String.fromInt details.cost ++ " " ++ details.name ]
                                , Html.span [ Attributes.class "text" ] [ text details.text ]

                                -- , Html.span [ Attributes.class "cost" ] [ text <| String.fromInt details.cost ]
                                ]
                            ]
                    )
                    model.you.hand
            ]
        ]


viewTheirCard : Bool -> { card : Card, selected : Bool } -> Html Msg
viewTheirCard settling { card, selected } =
    if selected && settling then
        let
            details =
                Card.cardDetails card
        in
        div
            [ Attributes.class "imageContainer border-small"
            , Attributes.class "border-transparent"
            ]
            [ div []
                [ img [ Attributes.src details.art ] []
                , Html.span [ Attributes.class "name" ] [ text details.name ]
                , Html.span [ Attributes.class "text" ] [ text details.text ]
                , Html.span [ Attributes.class "cost" ] [ text <| String.fromInt details.cost ]
                ]
            ]

    else
        div [ Attributes.class "imageContainer border-small border-transparent" ]
            [ div []
                [ img [ Attributes.src cardBack ] []

                -- , Html.span [] [ Html.text "blabla" ]
                ]
            ]



-- UPDATE


type Msg
    = Restart
    | SelectCard Int
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
                settled = model |> settleSchemes
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
            List.concatMap
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
        getScheme hand =
            map (\c -> cardDetails c.card) <| List.filter (\held -> held.selected) <| hand

        yourScheme =
            getScheme you.hand

        theirScheme =
            getScheme they.hand

        getEffect from to scheme =
            List.foldl
                (\step total ->
                    case step of
                        Damage f ->
                            { total | damage = total.damage + f from to }

                        Draw f ->
                            { total | draw = total.draw + f from to }

                        _ ->
                            total
                )
                { damage = 0, draw = 0 }
            <|
                List.concatMap .effect scheme

        yourEffect =
            getEffect you they yourScheme

        theirEffect =
            getEffect they you theirScheme
    in
    { model
        | you =
            { you
                | health = you.health - theirEffect.damage
                , draw = you.draw + yourEffect.draw
            }
                |> playCards
        , they =
            { they
                | health = they.health - yourEffect.damage
                , draw = they.draw + theirEffect.draw
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
        | hand = sortHand <| map (\c -> { card = c, selected = False }) <| cards
        , draw = 0
    }


dealCards : Player -> List Card -> Player
dealCards ({ hand } as player) cs =
    { player
        | hand = sortHand <| List.append hand (map (\c -> { card = c, selected = False }) cs)
        , draw = 0
    }


sortHand : List { a | card : Card } -> List { a | card : Card }
sortHand hand =
    List.sortBy (\h -> cardDetails h.card |> .cost) <| List.sortBy (\h -> cardDetails h.card |> .name) hand


selectCard : Player -> Int -> Player
selectCard ({ hand } as player) j =
    { player
        | hand =
            List.indexedMap
                (\i c ->
                    if j == i then
                        { c | selected = not c.selected }

                    else
                        c
                )
                hand
    }
        |> updateCosts


updateCosts : Player -> Player
updateCosts ({ hand } as player) =
    { player
        | wisdomUsed = List.sum <| map (\h -> (cardDetails h.card).cost) <| List.filter .selected hand
    }


schemeValid : Player -> Bool
schemeValid player =
    player.wisdomUsed <= player.wisdom


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
