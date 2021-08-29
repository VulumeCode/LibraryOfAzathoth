module Card exposing (..)


import Random


type Card
    = W1
    | W2
    | W3
    | W4
    | W5
    | W6
    | W7
    | W8
    | W9
    | W10
    | W11
    | W12
    | W13
    | W14
    | S1
    | S2
    | S3
    | S4
    | S5
    | S6
    | S7
    | S8
    | S9
    | S10
    | S11
    | S12
    | S13
    | S14
    | C1
    | C2
    | C3
    | C4
    | C5
    | C6
    | C7
    | C8
    | C9
    | C10
    | C11
    | C12
    | C13
    | C14
    | P1
    | P2
    | P3
    | P4
    | P5
    | P6
    | P7
    | P8
    | P9
    | P10
    | P11
    | P12
    | P13
    | P14
    | M0
    | M1
    | M2
    | M3
    | M4
    | M5
    | M6
    | M7
    | M8
    | M9
    | M10
    | M11
    | M12
    | M13
    | M14
    | M15
    | M16
    | M17
    | M18
    | M19
    | M20
    | M21
    | M22


type alias CardDetails =
    { name : String
    , cost : Int
    , text : String
    , art : String
    , effect : List Effect
    }


type alias Player =
    { hand : List { card : Card, selected : Bool }
    , health : Int
    , sanity : Int
    , wisdom : Int
    , wisdomUsed : Int
    , summon : Maybe Card
    }

type Effect = 
    Damage (Player -> Player -> Int)
    | Draw (Player -> Player -> Int)

cardDetails : Card -> CardDetails
cardDetails card =
    case card of
        W1 ->
            { name = "Inspiration"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/11/Wands01.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W2 ->
            { name = "Dominion"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0f/Wands02.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W3 ->
            { name = "Foresight"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/ff/Wands03.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W4 ->
            { name = "Perfection"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a4/Wands04.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W5 ->
            { name = "Conflict"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9d/Wands05.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W6 ->
            { name = "Pride"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/3b/Wands06.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W7 ->
            { name = "Conviction"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e4/Wands07.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W8 ->
            { name = "Change"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6b/Wands08.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W9 ->
            { name = "Stamina"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e7/Wands09.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W10 ->
            { name = "Oppression"
            , cost = 3
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0b/Wands10.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W11 ->
            { name = "Discovery"
            , cost = 3
            , text = "Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6a/Wands11.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W12 ->
            { name = "Energy"
            , cost = 3
            , text = "Gain 1 📖 Wisdom"
            , art = "https://upload.wikimedia.org/wikipedia/en/1/16/Wands12.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W13 ->
            { name = "Vibrance"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0d/Wands13.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        W14 ->
            { name = "Visions"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/c/ce/Wands14.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S1 ->
            { name = "Justice"
            , cost = 1
            , text = "Deal 1 damage 🗡️. Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/1a/Swords01.jpg"
            , effect = [Damage (\_ _ -> 1), Draw (\_ _ -> 1)]
            }

        S2 ->
            { name = "Stalemate"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9e/Swords02.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S3 ->
            { name = "Betrayal"
            , cost = 1
            , text = "Deal 2 damage 🗡️."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/02/Swords03.jpg"
            , effect = [Damage (\_ _ -> 2)]
            }

        S4 ->
            { name = "Truce"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/b/bf/Swords04.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S5 ->
            { name = "Defeat"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/2/23/Swords05.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S6 ->
            { name = "Science"
            , cost = 2
            , text = "Deal 2 damage 🗡️ for every card in your scheme. <i>Baboom!</i>"
            , art = "https://upload.wikimedia.org/wikipedia/en/2/29/Swords06.jpg"
            , effect = [Damage (\you _ -> List.length <| List.filter .selected you.hand)]
            }

        S7 ->
            { name = "Uselessness"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/34/Swords07.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S8 ->
            { name = "Confusion"
            , cost = 2
            , text = "Deal 2 damage 🗡️ for every card in their scheme."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a7/Swords08.jpg"
            , effect = [Damage (\_ they -> List.length <| List.filter .selected they.hand)]
            }

        S9 ->
            { name = "Cruelty"
            , cost = 2
            , text = "Deal 3 damage 🗡️."
            , art = "https://upload.wikimedia.org/wikipedia/en/2/2f/Swords09.jpg"
            , effect = [Damage (\_ _ -> 3)]
            }

        S10 ->
            { name = "Martyrdom"
            , cost = 3
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d4/Swords10.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S11 ->
            { name = "Curiousity"
            , cost = 3
            , text = "Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/4/4c/Swords11.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S12 ->
            { name = "Haste"
            , cost = 3
            , text = "Gain 1 📖 Wisdom"
            , art = "https://upload.wikimedia.org/wikipedia/en/b/b0/Swords12.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S13 ->
            { name = "Perception"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d4/Swords13.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        S14 ->
            { name = "Intellect"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/33/Swords14.jpg"
            , effect = [Damage (\_ _ -> 10)]
            }

        _ ->
            Debug.todo "remove"


allCards : List Card
allCards =
    [ W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14 ]


random : Random.Generator Card
random =
    Random.uniform W1 [ W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14 ]


cardBack =
    "public/images/back.jpg"
