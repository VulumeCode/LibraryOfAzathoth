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


type alias CardDetails =
    { name : String
    , cost : Int
    , text : String
    , art : String
    }


cardDetails : Card -> CardDetails
cardDetails card =
    case card of
        W1 ->
            { name = "Inspiration"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/11/Wands01.jpg"
            }

        W2 ->
            { name = "Dominion"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0f/Wands02.jpg"
            }

        W3 ->
            { name = "Foresight"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/ff/Wands03.jpg"
            }

        W4 ->
            { name = "Perfection"
            , cost = 1
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a4/Wands04.jpg"
            }

        W5 ->
            { name = "Conflict"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9d/Wands05.jpg"
            }

        W6 ->
            { name = "Pride"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/3b/Wands06.jpg"
            }

        W7 ->
            { name = "Conviction"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e4/Wands07.jpg"
            }

        W8 ->
            { name = "Change"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6b/Wands08.jpg"
            }

        W9 ->
            { name = "Stamina"
            , cost = 2
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e7/Wands09.jpg"
            }

        W10 ->
            { name = "Oppression"
            , cost = 3
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0b/Wands10.jpg"
            }

        W11 ->
            { name = "Discovery"
            , cost = 3
            , text = "Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6a/Wands11.jpg"
            }

        W12 ->
            { name = "Energy"
            , cost = 3
            , text = "Gain 1 📖 Wisdom"
            , art = "https://upload.wikimedia.org/wikipedia/en/1/16/Wands12.jpg"
            }

        W13 ->
            { name = "Vibrance"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0d/Wands13.jpg"
            }

        W14 ->
            { name = "Visions"
            , cost = 4
            , text = "Do stuff."
            , art = "https://upload.wikimedia.org/wikipedia/en/c/ce/Wands14.jpg"
            }


allCards : List Card
allCards =
    [ W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14 ]


random : Random.Generator Card
random =
    Random.uniform W1 [ W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14 ]


cardBack =
    "public/images/back.jpg"
