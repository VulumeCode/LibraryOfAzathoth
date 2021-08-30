module Main exposing (..)

import Browser exposing (Document)
import Browser.Events
import Card exposing (..)
import Dict
import Html exposing (Html)
import Html.Attributes as Attributes exposing (selected)
import Html.Events as Events
import Json.Decode as Decode exposing (Value)
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
    Html.div [ Attributes.class "h-full w-3/4 max-h-screen relative " ]
        [ Html.div [ Attributes.class "flex p-1 justify-start", Attributes.style "height" "25%" ]
            (List.map
                (viewTheirCard (model.state == Settling))
                model.they.hand
                ++ [ Html.div [ Attributes.class "flex-grow playerStats text-right text-gray-600", Attributes.style "font-size" "200%" ]
                        [ Html.div [] [ Html.text <| String.fromInt model.they.health ++ "/20 Health ❤️" ]
                        , Html.div [] [ Html.text <| String.fromInt model.they.sanity ++ "/20 Sanity 🧠" ]
                        , Html.div [] [ Html.text <| String.fromInt model.they.wisdomUsed ++ "/" ++ String.fromInt model.they.wisdom ++ " Wisdom 📖" ]
                        ]
                   ]
            )
        , Html.div [ Attributes.class "flex p-1 justify-center text-gray-900", Attributes.style "height" "50%" ]
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
                                    , Html.span [ Attributes.class "text ", Attributes.style "font-size" "200%" ]
                                        [ Html.button [ Attributes.class "block" ] [ Html.text "+1: Stab" ]
                                        , Html.button [ Attributes.class "block" ] [ Html.text "0: Learn" ]
                                        , Html.button [ Attributes.class "block" ] [ Html.text "-5: Kill" ]
                                        ]
                                    ]
                                ]
                )
                [ Maybe.map cardDetails model.they.summon, Maybe.map cardDetails model.you.summon ]
            )
        , Html.div [ Attributes.class "you flex p-1  text-gray-900", Attributes.style "height" "25%" ]
            [ Html.div [ Attributes.class "flex-none playerStats text-gray-600 mr-8 ", Attributes.style "font-size" "200%" ]
                [ Html.div [] [ Html.text <| "❤️ Health " ++ String.fromInt model.you.health ++ "/20" ]
                , Html.div [] [ Html.text <| "🧠 Sanity " ++ String.fromInt model.you.sanity ++ "/20" ]
                , Html.div [] [ Html.text <| "📖 Wisdom " ++ String.fromInt model.you.wisdomUsed ++ "/" ++ String.fromInt model.you.wisdom ]
                , Html.div
                    (if schemeValid model.you then
                        [ Attributes.class "text-blue-600 hover:text-blue-300", Events.on "pointerup" (Decode.succeed <| SubmitScheme) ]

                     else
                        [ Attributes.class "text-red-600" ]
                    )
                    [ Html.text <| "✨ Play scheme" ]
                ]
            , Html.div [ Attributes.class "flex-grow hand " ] <|
                List.indexedMap
                    (\i { card, selected } ->
                        let
                            details =
                                Card.cardDetails card
                        in
                        Html.div
                            [ Attributes.class "imageContainer"
                            , Events.on "pointerup" (Decode.succeed <| SelectCard i)
                            ]
                            [ Html.div [Attributes.class
                                (if selected then
                                    "border-yellow-300 border-opacity-75"

                                 else
                                    "border-transparent"
                                )]
                                [ Html.img [ Attributes.src details.art ] []
                                , Html.span [ Attributes.class "name" ] [ Html.text details.name ]
                                , Html.span [ Attributes.class "text" ] [ Html.text details.text ]
                                , Html.span [ Attributes.class "cost" ] [ Html.text <| String.fromInt details.cost ]
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
        Html.div
            [ Attributes.class "imageContainer border-small"
            , Attributes.class "border-transparent"
            ]
            [ Html.div []
                [ Html.img [ Attributes.src details.art ] []
                , Html.span [ Attributes.class "name" ] [ Html.text details.name ]
                , Html.span [ Attributes.class "text" ] [ Html.text details.text ]
                , Html.span [ Attributes.class "cost" ] [ Html.text <| String.fromInt details.cost ]
                ]
            ]

    else
        Html.div [ Attributes.class "imageContainer border-small border-transparent" ]
            [ Html.div []
                [ Html.img [ Attributes.src cardBack ] []

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
            ( { model | state = Settling } |> randomAI
            , Process.sleep 2000
                |> Task.perform (\_ -> SettleSchemes)
            )

        SettleSchemes ->
            ( model |> settleSchemes
            , Cmd.batch
                [ Random.generate DealYouCard Card.random
                , Random.generate DealTheyCard Card.random
                ]
            )

        DealYouCard c ->
            ( { model | you = dealCard you c }
            , Cmd.none
            )

        DealTheyCard c ->
            ( { model | they = dealCard they c }
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
                        List.map (\option -> updateCosts { they | hand = option }) <|
                            possibleHands they.hand
    }


settleSchemes : Model -> Model
settleSchemes ({ you, they } as model) =
    let
        getScheme hand =
            List.map (\c -> cardDetails c.card) <| List.filter (\held -> held.selected) <| hand

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

                        _ ->
                            total
                )
                { damage = 0 }
            <|
                List.concatMap .effect scheme

        yourEffect =
            getEffect you they yourScheme

        theirEffect =
            getEffect they you theirScheme
    in
    { model
        | you = { you | health = you.health - theirEffect.damage } |> playCards
        , they = { they | health = they.health - yourEffect.damage } |> playCards
        , state = Settling
    }



-- { model | you = playCards you }


playCards : Player -> Player
playCards ({ hand, wisdom, wisdomUsed, sanity } as player) =
    { player
        | hand = List.filter (\held -> not held.selected) <| hand
        , wisdom = wisdom + 1
        , wisdomUsed = 0
        , sanity = sanity - wisdomUsed
    }
        |> drainSanityFromHealth


drainSanityFromHealth : { a | sanity : number, health : number } -> { a | sanity : number, health : number }
drainSanityFromHealth player =
    if player.sanity >= 0 then
        player

    else
        { player
            | sanity = 0
            , health = player.health + player.sanity
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
