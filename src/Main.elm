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
import List exposing (append, concat, concatMap, filter, foldl, indexedMap, length, map, sortBy, sum)
import List.Extra exposing (lift2, maximumBy)
import MCTS
import Maybe exposing (andThen, withDefault)
import Maybe.Extra as Maybe exposing (orElse)
import Process
import Random exposing (Seed)
import Random.List as Random
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
    { deck = []
    , hand = []
    , vitality = 20
    , sanity = 20
    , intellect = 1
    , intellectUsed = 0
    , summon = Nothing
    , dead = False
    , lich = False
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
    , Cmd.batch
        [ Random.generate DealYouHand (Random.choices handSize Card.allCards)
        , Random.generate DealTheyHand (Random.choices handSize Card.allCards)
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
                [ div [] [ text <| String.fromInt model.they.intellectUsed ++ "/" ++ String.fromInt model.they.intellect ++ " Intellect 📜" ]
                , div [] [ text <| String.fromInt model.they.sanity ++ ifElse model.they.lich " Madness 💀" " Sanity 🧠" ]
                , div [] [ text <| String.fromInt model.they.vitality ++ " Vitality 🖤" ]
                ]
            ]
        , div [ class "flex p-1 justify-center text-gray-900 summons", style "height" "50%" ]
            [ viewSummon False revealThey model.they.summon, viewSummon True True model.you.summon ]
        , div [ class "you flex p-1  text-gray-900", style "height" "25%" ]
            [ div [ class "flex-none playerStats text-gray-600 ", style "font-size" "200%" ]
                [ div [] [ text <| "📜 Intellect " ++ String.fromInt model.you.intellectUsed ++ "/" ++ String.fromInt model.you.intellect ]
                , div [] [ text <| ifElse model.you.lich "💀 Madness " "🧠 Sanity " ++ String.fromInt model.you.sanity ++ " › " ++ String.fromInt predicted.sanity ]
                , div [] [ text <| "🖤 Vitality " ++ String.fromInt model.you.vitality ++ " › " ++ String.fromInt predicted.vitality ]
                , case ( schemeValid model.you, predicted.vitality > 0 ) of
                    ( Err reason, _ ) ->
                        div [ class "text-red-600 tooltip" ] [ text <| "❌ Invalid scheme", tooltip (text <| reason) ]

                    ( _, False ) ->
                        div [ class "text-green-600 hover:text-green-300 tooltip", attrIf playing (on "pointerup" (Decode.succeed <| SubmitScheme)) ] [ text <| "💀 Ritual suicide", tooltip lichWarning ]

                    ( Ok (), True ) ->
                        div [ class "text-blue-600 hover:text-blue-300", attrIf playing (on "pointerup" (Decode.succeed <| SubmitScheme)) ] [ text <| "✨ Play scheme" ]
                ]
            , div [ class "flex-grow hand " ] <|
                map
                    (viewCard (model.state == Playing))
                    model.you.hand
            ]
        ]


lichWarning : Html msg
lichWarning =
    Html.div [] [ text <| "Gain enough life to survive this turn and become a lich.", Html.br [] [], text <| "Liches are permanently insane." ]


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
                    , Html.span [ class "name", style "font-size" "200%" ] [ text <| cdetails.name, Html.br [] [], text <| "[" ++ String.fromInt influence ++ "]" ]
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


viewCard : Bool -> Held -> Html Msg
viewCard interactive { card, selected, cost, index } =
    let
        details =
            Card.cardDetails card
    in
    div
        [ class "imageContainer"
        , if interactive then
            on "pointerup" (Decode.succeed <| SelectCard index)

          else
            none
        , classIf selected "selected"
        ]
        [ div
            [ class
                "border-transparent"
            ]
            [ img [ Attributes.src details.art ] []
            , Html.span [ class "name" ]
                ((text <| String.fromInt cost ++ " " ++ details.name)
                    :: (Maybe.map
                            (\sd ->
                                [ Html.br [] [], text <| "[" ++ String.fromInt sd.influence ++ "]" ]
                            )
                            (getSummonDetails card)
                            |> withDefault []
                       )
                )
            , Html.span [ class "text" ]
                (Parser.toVirtualDom (Parser.run details.text |> Result.withDefault [ Parser.Comment "String" ])
                    ++ (Maybe.map
                            (\sd ->
                                viewSummonEffects False False sd.effects
                            )
                            (getSummonDetails card)
                            |> withDefault []
                       )
                )
            ]
        ]


viewTheirCard : Bool -> Bool -> Held -> Html Msg
viewTheirCard gameOver settling ({ selected } as held) =
    if True || (selected && settling) || gameOver then
        viewCard False held

    else
        div [ class "imageContainer" ]
            [ div [ class "border-transparent" ]
                [ img [ Attributes.src cardBack ] []
                ]
            ]



-- UPDATE


type Msg
    = Restart
    | SelectCard Int
    | SelectEffect Int
    | SubmitScheme
    | RandomAI Seed
    | SettleSchemes
    | DealYouHand ( List Card, List Card )
    | DealTheyHand ( List Card, List Card )
    | DealYouCards ( List Card, List Card )
    | DealTheyCards ( List Card, List Card )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ you, they } as model) =
    case msg of
        Restart ->
            initGame

        SelectCard card ->
            with { model | you = selectCard you card }

        SelectEffect i ->
            with { model | you = selectEffect you i }

        DealYouHand dealt ->
            with { model | you = dealHand you dealt }

        DealTheyHand dealt ->
            with { model | they = dealHand they dealt }

        SubmitScheme ->
            withBatch model
                [ Random.generate RandomAI Random.independentSeed ]

        RandomAI seed ->
            withBatch ({ model | state = Settling } |> mtcsAI seed)
                [ Process.sleep 2000 |> Task.perform (\_ -> SettleSchemes) ]

        SettleSchemes ->
            withBatchBy (model |> settleSchemes)
                (\settled ->
                    [ Random.generate DealYouCards (Random.choices settled.you.draw settled.you.deck)
                    , Random.generate DealTheyCards (Random.choices settled.they.draw settled.they.deck)
                    ]
                )

        DealYouCards cs ->
            with { model | you = dealCards you cs }

        DealTheyCards cs ->
            with { model | they = dealCards they cs }


withBatch model commands =
    ( model, Cmd.batch commands )


withBatchBy model f =
    ( model, Cmd.batch (f model) )


with model =
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


possibleSummonEffects : Maybe SummonDetails -> List (Maybe SummonDetails)
possibleSummonEffects summon =
    case summon of
        Nothing ->
            [ Nothing ]

        Just ({ effects } as aSummon) ->
            effects
                |> map
                    (\chosen -> Just { aSummon | effects = effects |> map (\effect -> { effect | selected = effect == chosen }) })


optionsAI : Model -> List Player
optionsAI ({ they } as model) =
    filter (schemeValid >> isOk) <|
        lift2 (\h s -> updateCosts { they | hand = h, summon = s })
            (possibleHands they.hand)
            (possibleSummonEffects they.summon)


randomAI : Seed -> Model -> Model
randomAI seed ({ they } as model) =
    let
        options =
            optionsAI model

        ( ( choice, _ ), _ ) =
            Random.step (Random.choose options) seed
    in
    { model
        | they = choice |> withDefault they
    }


randomYou : Seed -> Model -> ( Model, Seed )
randomYou seed0 ({ you } as model) =
    let
        options =
            filter (schemeValid >> isOk) <|
                lift2 (\h s -> updateCosts { you | hand = h, summon = s })
                    (possibleHands you.hand)
                    (possibleSummonEffects you.summon)

        ( ( choice, _ ), seed1 ) =
            Random.step (Random.choose options) seed0
    in
    ( { model
        | you = choice |> withDefault you
      }
    , seed1
    )


mtcsAI : Seed -> Model -> Model
mtcsAI seed0 ({ they, you } as model) =
    let
        fuddle s0 m =
            let
                ( fuddledHand, s1 ) =
                    Random.step (Random.choices (you.hand |> length) Card.allCards) s0
            in
            ( { m | you = dealHand m.you fuddledHand }, s1 )

        root =
            MCTS.Node
                { model = model
                , t = 0
                , w = 0
                , children = Nothing
                }

        expandChildren : Model -> List Model
        expandChildren m =
            m |> optionsAI >> map (\p -> { m | they = p })

        playRound : Seed -> Model -> ( Model, Seed )
        playRound s0 m =
            let
                settledModel =
                    settleSchemes m

                ( theyDrew, s1 ) =
                    Random.step (Random.choices settledModel.they.draw settledModel.they.deck) s0

                ( youDrew, s2 ) =
                    Random.step (Random.choices settledModel.you.draw settledModel.you.deck) s1
            in
            ( { settledModel
                | you = dealCards settledModel.you youDrew
                , they = dealCards settledModel.they theyDrew
              }
            , s2
            )

        (MCTS.Node rootFinal) =
            MCTS.run root
                10
                seed0
                { expandChildren = expandChildren
                , playerRandom = randomYou
                , playRound = playRound
                , gameResult = \m -> ( m.you.dead, m.they.dead )
                , fuddle = fuddle
                }

        chosenMove =
            case rootFinal.children |> andThen (maximumBy (\(MCTS.Node c) -> c.w / c.t)) of
                Just (MCTS.Node chosenModel) ->
                    Debug.log "Move" chosenModel.model.they

                Nothing ->
                    Debug.log "Nothing" model.they
    in
    { model | they = chosenMove }


settleSchemes : Model -> Model
settleSchemes ({ you, they } as model) =
    let
        newYou =
            playCards you |> calcPlayerInsaneAdvantage

        newThey =
            playCards they |> calcPlayerInsaneAdvantage

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

                        GainIntellect f ->
                            { total | gainIntellect = total.gainIntellect + f from to }

                        GainSanity f ->
                            { total | gainSanity = total.gainSanity + f from to }

                        GainVitality f ->
                            { total | gainVitality = total.gainVitality + f from to }

                        Summon m ->
                            { total | summon = Just (summonDetails m) }

                        PreventDraw f ->
                            { total | preventDraw = total.preventDraw + f from to }

                        _ ->
                            total
                )
                { summon = Nothing, damage = 0, draw = 0, gainIntellect = 0, gainSanity = 0, gainVitality = 0, preventDraw = 0, influenceDamage = 0 }
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
            { newYou
                | vitality = newYou.vitality - theirEffectTotal.damage + yourEffectTotal.gainVitality
                , draw = newYou.draw + yourEffectTotal.draw - theirEffectTotal.preventDraw
                , intellect = newYou.intellect + yourEffectTotal.gainIntellect
                , sanity = newYou.sanity + yourEffectTotal.gainSanity
                , summon = yourEffectTotal.summon |> orElse newYou.summon
                , lich = newYou.lich || newYou.vitality <= 0
            }
                |> calcPlayerDead
        , they =
            { newThey
                | vitality = newThey.vitality - yourEffectTotal.damage + theirEffectTotal.gainVitality
                , draw = newThey.draw + theirEffectTotal.draw - yourEffectTotal.preventDraw
                , intellect = newThey.intellect + theirEffectTotal.gainIntellect
                , sanity = newThey.sanity + theirEffectTotal.gainSanity
                , summon = theirEffectTotal.summon |> orElse newThey.summon
                , lich = newThey.lich || newThey.vitality <= 0
            }
                |> calcPlayerDead
        , state = Playing
        , turn = model.turn + 1
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
playCards ({ hand, intellect, intellectUsed, sanity, draw, summon, deck } as player) =
    { player
        | hand = filter (\held -> not held.selected) <| hand
        , deck = deck ++ map .card (filter (\held -> held.selected) <| hand)
        , intellect = intellect + 1
        , intellectUsed = 0
        , sanity = sanity - intellectUsed
        , draw = draw + 1
        , summon = summon |> andThen playSummon
    }
        |> updateCosts
        |> drainSanityFromVitality


playSummon : SummonDetails -> Maybe SummonDetails
playSummon summon =
    let
        calcInfluence =
            summon.influence + (summon.effects |> filter .selected |> map .cost |> sum)
    in
    if calcInfluence <= 0 then
        Nothing

    else
        Just
            { summon
                | influence = calcInfluence
            }


drainSanityFromVitality : { a | sanity : number, vitality : number } -> { a | sanity : number, vitality : number }
drainSanityFromVitality player =
    if player.sanity >= 0 then
        player

    else
        { player
            | sanity = 0
            , vitality = player.vitality + player.sanity
        }


calcPlayerDead : Player -> Player
calcPlayerDead player =
    { player
        | dead = player.vitality <= 0
    }


isInsane player =
    not player.dead
        && (player.lich || player.sanity <= 0)


calcPlayerInsaneAdvantage : Player -> Player
calcPlayerInsaneAdvantage player =
    if isInsane player then
        { player
            | draw = player.draw + 1
        }

    else
        player


id x =
    x


dealHand : Player -> ( List Card, List Card ) -> Player
dealHand player ( dealt, deck ) =
    { player
        | deck = deck
        , hand = sortHand <| map (\c -> { card = c, selected = False, cost = (cardDetails c).cost, index = -1 }) <| dealt
        , draw = 0
    }


dealCards : Player -> ( List Card, List Card ) -> Player
dealCards ({ hand } as player) ( dealt, deck ) =
    { player
        | deck = deck
        , hand = sortHand <| append hand (map (\c -> { card = c, selected = False, cost = (cardDetails c).cost, index = -1 }) dealt)
        , draw = 0
    }


sortHand : List Held -> List Held
sortHand hand =
    indexedMap (\i c -> { c | index = i }) <| sortBy (\h -> cardDetails h.card |> .cost) <| sortBy (\h -> cardDetails h.card |> .name) hand


selectCard : Player -> Int -> Player
selectCard ({ hand } as player) i =
    { player
        | hand =
            map
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
    filter (\held -> held.selected) <| hand


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
        , intellectUsed = sum <| map (\h -> h.cost) <| filter .selected updatedHand
    }


schemeValid : Player -> Result String ()
schemeValid player =
    if player.intellectUsed > player.intellect then
        Err "Not enough intellect."

    else if (length <| filter (\c -> (cardDetails c.card).cardType == Types.M) (getScheme player.hand)) > 1 then
        Err "More then one summon selected."

    else if player.summon |> Maybe.map (\s -> s.influence + (s.effects |> filter .selected |> map .cost |> sum) < 0) |> withDefault False then
        Err "Not enough influence."

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
