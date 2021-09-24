module MCTS exposing (..)

import List exposing (concat, concatMap, filter, foldl, indexedMap, length, map, sum)
import List.Extra exposing (..)
import Maybe exposing (withDefault)
import Random exposing (Seed)
import Random.List as Random


explorationParameter : Float
explorationParameter =
    -- sqrt 2
    1.41421356237


type Node a
    = Node
        { model : a
        , t : Float
        , w : Float
        , children : Maybe (List (Node a))
        }


select : Float -> List (Node a) -> ( Maybe (Node a), List (Node a) )
select t children =
    let
        ln_t_N =
            logBase e t

        score (Node child) =
            (child.w / child.t) + (explorationParameter * sqrt (ln_t_N / child.t))
    in
    selectMaxBy score children


selectMaxBy : (a -> comparable) -> List a -> ( Maybe a, List a )
selectMaxBy f ls =
    case ls of
        [] ->
            ( Nothing, ls )

        e :: r ->
            let
                ( rmaxm, rrest ) =
                    selectMaxBy f r
            in
            case rmaxm of
                Nothing ->
                    ( Just e, r )

                Just rmax ->
                    if f rmax > f e then
                        ( Just rmax, e :: rrest )

                    else
                        ( Just e, r )


type alias Game a =
    { expandChildren : a -> List a
    , playerRandom : Seed -> a -> ( a, Seed )
    , playRound : Seed -> a -> ( a, Seed )
    , gameResult : a -> ( Bool, Bool )
    , fuddle : Seed -> a -> ( a, Seed )
    }


run : Node a -> Int -> Seed -> Game a -> Node a
run (Node node) times seed0 game =
    if times <= 0 then
        Node node

    else
        let
            ( fuddledModel, seed1 ) =
                game.fuddle seed0 node.model

            fuddledNode =
                { node | model = fuddledModel }
        in
        run (logScores (expand (Node fuddledNode) seed1 game)) (times - 1) seed1 game


logScores : Node a -> Node a
logScores ((Node { w, t }) as n) =
    let
        ( _, n_ ) =
            ( Debug.log "Score" { r = w / t, t = t }, n )
    in
    n_


makeNode : a -> Node a
makeNode model =
    Node
        { model = model
        , t = 0
        , w = 0
        , children = Nothing
        }


getNode (Node node) =
    node


expand : Node a -> Random.Seed -> Game a -> Node a
expand (Node node) seed0 game =
    case node.children of
        Nothing ->
            let
                expandedChildren =
                    game.expandChildren node.model

                playedChildren =
                    expandedChildren
                        |> map
                            (\c ->
                                Node
                                    { model = c
                                    , t = 1
                                    , w = playout c seed0 game
                                    , children = Nothing
                                    }
                            )
            in
            Node
                { node
                    | children = Just playedChildren
                    , t = sum <| map .t <| map getNode <| playedChildren
                    , w = sum <| map .w <| map getNode <| playedChildren
                }

        Just someChildren ->
            case select node.t someChildren of
                ( Nothing, _ ) ->
                    Debug.log "never happens?" (Node node)

                ( Just selected, rest ) ->
                    let
                        expanded =
                            expand selected seed0 game :: rest
                    in
                    Node
                        { node
                            | children = Just <| expanded
                            , t = sum <| map .t <| map getNode <| expanded
                            , w = sum <| map .w <| map getNode <| expanded
                        }


playout : a -> Random.Seed -> Game a -> Float
playout model seed0 game =
    let
        ( modelPlayerPlayed, seed1 ) =
            game.playerRandom seed0 model

        ( modelSettled, seed2 ) =
            game.playRound seed1 modelPlayerPlayed
    in
    case game.gameResult modelSettled of
        ( True, True ) ->
            -- Draw
            1

        ( False, True ) ->
            -- Loss
            0

        ( True, False ) ->
            -- Win
            1

        ( False, False ) ->
            let
                ( ( modelNextMoveRandom, _ ), seed3 ) =
                    Random.step (Random.choose (game.expandChildren modelSettled)) seed2

                modelNextMove =
                    modelNextMoveRandom |> withDefault modelSettled
            in
            -- barf modelNextMove
            1.0 * playout modelNextMove seed3 game


barf a =
    Debug.todo (Debug.toString a)
