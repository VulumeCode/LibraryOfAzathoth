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
    { hand : List Card
    , selected : List Card
    , health : Int
    , sanity : Int
    , wisdom : Int
    , wisdomUsed : Int
    , summon : Maybe Card
    }


initPlayer : Player
initPlayer =
    { hand = []
    , selected = []
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
                ++ [ Html.div [ Attributes.class "flex-grow text-right", Attributes.style "font-size" "200%" ]
                        [ Html.div [] [ Html.text <| String.fromInt model.you.health ++ "/20 Health ❤️" ]
                        , Html.div [] [ Html.text <| String.fromInt model.you.sanity ++ "/20 Sanity 🧠" ]
                        , Html.div [] [ Html.text <| String.fromInt model.you.wisdom ++ "/" ++ String.fromInt model.turn ++ " Wisdom 📖" ]
                        ]
                   ]
            )
        , Html.div [ Attributes.class "flex p-1 justify-center text-gray-900", Attributes.style "height" "50%", Attributes.style "font-size" "200%" ]
            (List.map
                (\mcard ->
                    case mcard of
                        Nothing ->
                            Html.div [ Attributes.class "imageContainer border-small border-transparent hover:border-yellow-600" ]
                                [ Html.div []
                                    [ Html.img [ Attributes.src cardBack ] []
                                    ]
                                ]

                        Just card ->
                            Html.div [ Attributes.class "imageContainer border-small border-transparent hover:border-yellow-600" ]
                                [ Html.div []
                                    [ Html.img [ Attributes.src card.art ] []
                                    , Html.span [ Attributes.class "text" ]
                                        [ Html.button [] [ Html.text "+1: Blabli" ]
                                        , Html.button [] [ Html.text "0: BingBong" ]
                                        , Html.button [] [ Html.text "-5: Baboom" ]
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
                , Html.div [] [ Html.text <| "📖 Wisdom " ++ String.fromInt model.you.wisdom ++ "/" ++ String.fromInt model.turn ]
                , Html.div [ Attributes.class "text-blue-600 hover:text-blue-300", Events.on "pointerup" (Decode.succeed <| SubmitScheme) ] [ Html.text <| "✨ Enact scheme" ]
                ]
                :: List.map
                    (\card ->
                        let
                            details =
                                Card.cardDetails card
                        in
                        Html.div
                            [ Attributes.class "imageContainer border-small"
                            , Attributes.class
                                (if List.member card model.you.selected then
                                    "border-blue-300"

                                 else
                                    "border-transparent"
                                )
                            , Events.on "pointerup" (Decode.succeed <| SelectCard card)
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
    | SelectCard Card
    | SubmitScheme
    | DealYouHand (List Card)
    | DealTheyHand (List Card)


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

        _ ->
            ( model, Cmd.none )


dealHand ({ hand } as player) cards =
    { player | hand = cards }


selectCard : Player -> Card -> Player
selectCard ({ selected } as you) card =
    { you
        | selected =
            if List.member card selected then
                List.filter (\c -> c /= card) selected

            else
                card :: selected
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
