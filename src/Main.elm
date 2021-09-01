module Main exposing (main)

import Browser exposing (Document)
import Browser.Events
import Card exposing (..)
import Dict
import Html exposing (Html)
import Html.Attributes as Attributes exposing (selected)
import Html.Events as Events
import Json.Decode as Decode exposing (Value)
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
    }


initPlayer : Player
initPlayer =
    { hand = []
    , health = 20
    , sanity = 20
    , wisdom = 1
    , wisdomUsed = 0
    , summon = Just W14
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
    Html.div [ Attributes.class "flex justify-center h-full items-center select-none font-display relative" ]
        [ viewBoard model
        ]


viewBoard : Model -> Html Msg
viewBoard model =
    Html.div [ Attributes.class "h-full w-3/4 max-h-screen relative text-gray-600" ]
        [ Html.div [ Attributes.class "flex p-1 justify-start", Attributes.style "height" "25%" ]
            (List.map
                (\card ->
                    Html.div [ Attributes.class "imageContainer border-small border-transparent hover:border-yellow-600" ]
                        [ Html.div []
                            [ Html.img [ Attributes.src cardBack ] []

                            -- , Html.span [] [ Html.text "blabla" ]
                            ]
                        ]
                )
                model.they.hand
                ++ [ Html.div [ Attributes.class "flex-grow playerStats text-right", Attributes.style "font-size" "200%" ]
                        [ Html.div [] [ Html.text <| String.fromInt model.you.health ++ "/20 Health ❤️" ]
                        , Html.div [] [ Html.text <| String.fromInt model.you.sanity ++ "/20 Sanity 🧠" ]
                        , Html.div [] [ Html.text <| String.fromInt model.you.wisdom ++ "/" ++ String.fromInt model.turn ++ " Wisdom 📖" ]
                        ]
                   ]
            )
        , Html.div [ Attributes.class "flex p-1 justify-center text-gray-900", Attributes.style "height" "50%"]
            (List.map
                (\mcard ->
                    case mcard of
                        Nothing ->
                            Html.div [ Attributes.class "imageContainer border-small border-transparent" ]
                                [ Html.div []
                                    [ Html.img [ Attributes.src cardBack ] []
                                    ]
                                ]

                        Just card ->
                            Html.div [ Attributes.class "imageContainer border-small border-transparent" ]
                                [ Html.div []
                                    [ Html.img [ Attributes.src card.art ] []
                                    , Html.span [ Attributes.class "text ", Attributes.style "font-size" "200%"  ]
                                        [ Html.button [Attributes.class "block"] [ Html.text "+1: Stab" ]
                                        , Html.button [Attributes.class "block"] [ Html.text "0: Learn" ]
                                        , Html.button [Attributes.class "block"] [ Html.text "-5: Kill" ]
                                        ]
                                    ]
                                ]
                )
                [ Maybe.map cardDetails model.they.summon, Maybe.map cardDetails model.you.summon ]
            )
        , Html.div [ Attributes.class "flex p-1 justify-end text-gray-900", Attributes.style "height" "25%" ]
            (Html.div [ Attributes.class "flex-grow playerStats text-gray-600 ", Attributes.style "font-size" "200%" ]
                [ Html.div [] [ Html.text <| "❤️ Health " ++ String.fromInt model.you.health ++ "/20" ]
                , Html.div [] [ Html.text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ++ "/20" ]
                , Html.div [] [ Html.text <| "📖 Wisdom " ++ String.fromInt model.you.wisdomUsed ++ "/" ++ String.fromInt model.you.wisdom]
                , Html.div [ Attributes.class "text-blue-600 hover:text-blue-300", Events.on "pointerup" (Decode.succeed <| SubmitScheme) ] [ Html.text <| "✨ Enact scheme" ]
                ]
                :: List.indexedMap
                    (\i { card, selected } ->
                        let
                            details =
                                Card.cardDetails card
                        in
                        Html.div
                            [ Attributes.class "imageContainer border-small"
                            , Attributes.class
                                (if selected then
                                    "border-yellow-300 border-opacity-75"

                                 else
                                    "border-transparent"
                                )
                            , Events.on "pointerup" (Decode.succeed <| SelectCard i)
                            ]
                            [ Html.div []
                                [ Html.img [ Attributes.src details.art ] []
                                , Html.span [ Attributes.class "name" ] [ Html.text details.name ]
                                , Html.span [ Attributes.class "text" ] [ Html.text details.text ]
                                , Html.span [ Attributes.class "cost" ] [ Html.text <| String.fromInt details.cost ]
                                ]
                            ]
                    )
                    model.you.hand
            )
        ]



-- UPDATE


type Msg
    = Place
    | Restart
    | SelectCard Int
    | SubmitScheme
    | DealYouHand (List Card)
    | DealTheyHand (List Card)
    | DealYouCard Card
    | DealTheyCard Card


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
            ( { model | you = playCards you }
            , Random.generate DealYouCard Card.random
            )

        DealYouCard c ->
            ( { model | you = dealCard you c }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


playCards : Player -> Player
playCards ({ hand , wisdom} as player) =
    { player
        | hand = List.filter (\held -> not held.selected) <| hand
        , wisdom = wisdom + 1
        , wisdomUsed = 0 
    }


id x =
    x


dealHand : { a | hand : List { card : b, selected : Bool } } -> List b -> { a | hand : List { card : b, selected : Bool } }
dealHand player cards =
    { player | hand = List.map (\c -> { card = c, selected = False }) <| cards }


dealCard ({ hand } as player) c =
    { player | hand = hand ++ [ { card = c, selected = False } ] }


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
        | wisdomUsed = List.sum <| List.map (\h -> (cardDetails h.card).cost) <| List.filter .selected hand
    }


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
