module Main exposing (main)

import Browser exposing (Document)
import Browser.Events
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
    , summon : Maybe Card
    }


type State
    = Playing
    | Settling
    | GameOver


type alias Card =
    { name : String
    , cost : Int
    , text : String
    , art : String
    }


w1 : Card
w1 =
    { name = "Inspiration"
    , cost = 1
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/1/11/Wands01.jpg"
    }


w2 : Card
w2 =
    { name = "Dominion"
    , cost = 1
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/0/0f/Wands02.jpg"
    }


w3 : Card
w3 =
    { name = "Foresight"
    , cost = 1
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/f/ff/Wands03.jpg"
    }


w4 : Card
w4 =
    { name = "Perfection"
    , cost = 1
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/a/a4/Wands04.jpg"
    }


w5 : Card
w5 =
    { name = "Conflict"
    , cost = 2
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/9/9d/Wands05.jpg"
    }


w6 : Card
w6 =
    { name = "Pride"
    , cost = 2
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/3/3b/Wands06.jpg"
    }


w7 : Card
w7 =
    { name = "Conviction"
    , cost = 2
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/e/e4/Wands07.jpg"
    }


w8 : Card
w8 =
    { name = "Change"
    , cost = 2
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/6/6b/Wands08.jpg"
    }


w9 : Card
w9 =
    { name = "Stamina"
    , cost = 2
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/e/e7/Wands09.jpg"
    }


w10 : Card
w10 =
    { name = "Oppression"
    , cost = 3
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/0/0b/Wands10.jpg"
    }


w11 : Card
w11 =
    { name = "Discovery"
    , cost = 3
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/6/6a/Wands11.jpg"
    }


w12 : Card
w12 =
    { name = "Energy"
    , cost = 3
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/1/16/Wands12.jpg"
    }


w13 : Card
w13 =
    { name = "Vibrance"
    , cost = 4
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/0/0d/Wands13.jpg"
    }


w14 : Card
w14 =
    { name = "Visions"
    , cost = 4
    , text = "bla"
    , art = "https://upload.wikimedia.org/wikipedia/en/c/ce/Wands14.jpg"
    }


allCards : List Card
allCards =
    [ w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14 ]


cardBack =
    "public/images/back.jpg"


init : Value -> ( Model, Cmd Msg )
init _ =
    ( { you =
            { hand = List.take 7 allCards
            , selected = []
            , health = 20
            , sanity = 20
            , wisdom = 1
            , summon = Just w14
            }
      , they =
            { hand = List.take 7 allCards
            , selected = []
            , health = 20
            , sanity = 20
            , wisdom = 1
            , summon = Nothing
            }
      , turn = 1
      , state = Playing
      }
      -- , Random.generate Spawn Tetrimino.random
    , Cmd.none
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
    Html.div [ Attributes.class "h-full w-3/4 max-h-screen relative text-gray-900" ]
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
        , Html.div [ Attributes.class "flex p-1 justify-center", Attributes.style "height" "50%", Attributes.style "font-size" "200%" ]
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
                [ model.they.summon, model.you.summon ]
            )
        , Html.div [ Attributes.class "flex p-1 justify-end", Attributes.style "height" "25%" ]
            (Html.div [ Attributes.class "flex-grow playerStats ", Attributes.style "font-size" "200%" ]
                [ Html.div [] [ Html.text <| "❤️ Health " ++ String.fromInt model.you.health ++ "/20" ]
                , Html.div [] [ Html.text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ++ "/20" ]
                , Html.div [] [ Html.text <| "📖 Wisdom " ++ String.fromInt model.you.wisdom ++ "/" ++ String.fromInt model.turn ]
                , Html.div [ Attributes.class "text-blue-600 hover:text-blue-300", Events.on "pointerup" (Decode.succeed <| SubmitScheme) ] [ Html.text <| "✨ Enact scheme" ]
                ]
                :: List.map
                    (\card ->
                        Html.div
                            [ Attributes.class "imageContainer border-small hover:border-yellow-600"
                            , Attributes.class
                                (if List.member card model.you.selected then
                                    "border-blue-600"

                                 else
                                    "border-transparent"
                                )
                            , Events.on "pointerup" (Decode.succeed <| SelectCard card)
                            ]
                            [ Html.div []
                                [ Html.img [ Attributes.src card.art ] []
                                , Html.span [ Attributes.class "name" ] [ Html.text card.name ]
                                , Html.span [ Attributes.class "text" ] [ Html.text card.text ]
                                , Html.span [ Attributes.class "cost" ] [ Html.text <| String.fromInt card.cost ]
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ you } as model) =
    case msg of
        SelectCard card ->
            ( { model | you = selectCard you card }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


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
