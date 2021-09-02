module Card exposing (..)

import Random
import Types exposing (..)


cardDetails : Card -> CardDetails
cardDetails card =
    case card of
        W1 ->
            { name = "Inspiration"
            , cost = 1
            , text = "Gain 1 sanity. Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/11/Wands01.jpg"
            , effect = [ GainSanity (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        W2 ->
            { name = "Dominion"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0f/Wands02.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W3 ->
            { name = "Foresight"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/ff/Wands03.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W4 ->
            { name = "Perfection"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a4/Wands04.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W5 ->
            { name = "Conflict"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9d/Wands05.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W6 ->
            { name = "Pride"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/3b/Wands06.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W7 ->
            { name = "Conviction"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e4/Wands07.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W8 ->
            { name = "Change"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6b/Wands08.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W9 ->
            { name = "Stamina"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/e7/Wands09.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W10 ->
            { name = "Oppression"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0b/Wands10.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W11 ->
            { name = "Discovery"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6a/Wands11.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W12 ->
            { name = "Energy"
            , cost = 3
            , text = "Gain 1 sanity"
            , art = "https://upload.wikimedia.org/wikipedia/en/1/16/Wands12.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W13 ->
            { name = "Vibrance"
            , cost = 4
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/0d/Wands13.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W14 ->
            { name = "Visions"
            , cost = 4
            , text = "Gain 1 sanity."
            , art = "https://upload.wikimedia.org/wikipedia/en/c/ce/Wands14.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        S1 ->
            { name = "Justice"
            , cost = 1
            , text = "Deal 1 damage. Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/1a/Swords01.jpg"
            , effect = [ Damage (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        S2 ->
            { name = "Stalemate"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9e/Swords02.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S3 ->
            { name = "Betrayal"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/02/Swords03.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S4 ->
            { name = "Truce"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/b/bf/Swords04.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S5 ->
            { name = "Defeat"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/2/23/Swords05.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S6 ->
            { name = "Science"
            , cost = 2
            , text = "Deal 2 damage for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "https://upload.wikimedia.org/wikipedia/en/2/29/Swords06.jpg"
            , effect = [ Damage (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        S7 ->
            { name = "Uselessness"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/34/Swords07.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S8 ->
            { name = "Confusion"
            , cost = 2
            , text = "Deal 2 damage for every card in their scheme."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a7/Swords08.jpg"
            , effect = [ Damage (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        S9 ->
            { name = "Cruelty"
            , cost = 2
            , text = "Deal 3 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/2/2f/Swords09.jpg"
            , effect = [ Damage (\_ _ -> 3) ]
            }

        S10 ->
            { name = "Martyrdom"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d4/Swords10.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S11 ->
            { name = "Curiousity"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/4/4c/Swords11.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S12 ->
            { name = "Haste"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/b/b0/Swords12.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S13 ->
            { name = "Perception"
            , cost = 4
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d4/Swords13.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S14 ->
            { name = "Intellect"
            , cost = 4
            , text = "Deal 2 damage."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/33/Swords14.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        C1 ->
            { name = "Intuition"
            , cost = 1
            , text = "Gain 1 wisdom. Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/36/Cups01.jpg"
            , effect = [ GainWisdom (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        C2 ->
            { name = "Connection"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/f8/Cups02.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C3 ->
            { name = "Overflow"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/7/7a/Cups03.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C4 ->
            { name = "Apathy"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/35/Cups04.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C5 ->
            { name = "Regret"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d7/Cups05.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C6 ->
            { name = "Innocence"
            , cost = 2
            , text = "Gain 2 wisdom for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "https://upload.wikimedia.org/wikipedia/en/1/17/Cups06.jpg"
            , effect = [ GainWisdom (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        C7 ->
            { name = "Wishful Thinking"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/ae/Cups07.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C8 ->
            { name = "Weariness"
            , cost = 2
            , text = "Gain 2 wisdom for every card in their scheme."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/60/Cups08.jpg"
            , effect = [ GainWisdom (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        C9 ->
            { name = "Wish Fulfillment"
            , cost = 2
            , text = "Deal 3 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/2/24/Cups09.jpg"
            , effect = [ GainWisdom (\_ _ -> 3) ]
            }

        C10 ->
            { name = "Alignment"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/8/84/Cups10.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C11 ->
            { name = "Synchronicity"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/a/ad/Cups11.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C12 ->
            { name = "Charm"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/fa/Cups12.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C13 ->
            { name = "Compassion"
            , cost = 4
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/62/Cups13.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C14 ->
            { name = "Balance"
            , cost = 4
            , text = "Gain 2 wisdom."
            , art = "https://upload.wikimedia.org/wikipedia/en/0/04/Cups14.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        P1 ->
            { name = "Intuition"
            , cost = 1
            , text = "Gain 1 life. Draw a card."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/fd/Pents01.jpg"
            , effect = [ GainHealth (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        P2 ->
            { name = "Connection"
            , cost = 1
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/9f/Pents02.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P3 ->
            { name = "Overflow"
            , cost = 1
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/4/42/Pents03.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P4 ->
            { name = "Apathy"
            , cost = 1
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/3/35/Pents04.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P5 ->
            { name = "Regret"
            , cost = 2
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/9/96/Pents05.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P6 ->
            { name = "Innocence"
            , cost = 2
            , text = "Gain 2 life for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "https://upload.wikimedia.org/wikipedia/en/a/a6/Pents06.jpg"
            , effect = [ GainHealth (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        P7 ->
            { name = "Wishful Thinking"
            , cost = 2
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/6/6a/Pents07.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P8 ->
            { name = "Weariness"
            , cost = 2
            , text = "Gain 2 life for every card in their scheme."
            , art = "https://upload.wikimedia.org/wikipedia/en/4/49/Pents08.jpg"
            , effect = [ GainHealth (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        P9 ->
            { name = "Wish Fulfillment"
            , cost = 2
            , text = "Deal 3 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/f/f0/Pents09.jpg"
            , effect = [ GainHealth (\_ _ -> 3) ]
            }

        P10 ->
            { name = "Alignment"
            , cost = 3
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/4/42/Pents10.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P11 ->
            { name = "Synchronicity"
            , cost = 3
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/e/ec/Pents11.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P12 ->
            { name = "Charm"
            , cost = 3
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/d/d5/Pents12.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P13 ->
            { name = "Compassion"
            , cost = 4
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/8/88/Pents13.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P14 ->
            { name = "Balance"
            , cost = 4
            , text = "Gain 2 life."
            , art = "https://upload.wikimedia.org/wikipedia/en/1/1c/Pents14.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        _ ->
            { name = "DEBUG"
            , cost = 4
            , text = "DEBUG."
            , art = "https://placekitten.com/300/526"
            , effect = []
            }


allCards : List Card
allCards =
    [ W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14 ]


random : Random.Generator Card
random =
    Random.uniform W1 [ W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14 ]


cardBack =
    "images/back.jpg"
