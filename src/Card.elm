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
            , art = "images/cards/Wands01.jpg"
            , effect = [ GainSanity (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        W2 ->
            { name = "Dominion"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands02.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W3 ->
            { name = "Foresight"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands03.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W4 ->
            { name = "Perfection"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands04.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W5 ->
            { name = "Conflict"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands05.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W6 ->
            { name = "Pride"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands06.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W7 ->
            { name = "Conviction"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands07.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W8 ->
            { name = "Change"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands08.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W9 ->
            { name = "Stamina"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands09.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W10 ->
            { name = "Oppression"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands10.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W11 ->
            { name = "Discovery"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands11.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W12 ->
            { name = "Energy"
            , cost = 3
            , text = "Gain 1 sanity"
            , art = "images/cards/Wands12.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W13 ->
            { name = "Vibrance"
            , cost = 4
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands13.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        W14 ->
            { name = "Visions"
            , cost = 4
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands14.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            }

        S1 ->
            { name = "Justice"
            , cost = 1
            , text = "Deal 1 damage. Draw a card."
            , art = "images/cards/Swords01.jpg"
            , effect = [ Damage (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        S2 ->
            { name = "Stalemate"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords02.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S3 ->
            { name = "Betrayal"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords03.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S4 ->
            { name = "Truce"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords04.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S5 ->
            { name = "Defeat"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "images/cards/Swords05.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S6 ->
            { name = "Science"
            , cost = 2
            , text = "Deal 2 damage for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "images/cards/Swords06.jpg"
            , effect = [ Damage (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        S7 ->
            { name = "Uselessness"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "images/cards/Swords07.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S8 ->
            { name = "Confusion"
            , cost = 2
            , text = "Deal 2 damage for every card in their scheme."
            , art = "images/cards/Swords08.jpg"
            , effect = [ Damage (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        S9 ->
            { name = "Cruelty"
            , cost = 2
            , text = "Deal 3 damage."
            , art = "images/cards/Swords09.jpg"
            , effect = [ Damage (\_ _ -> 3) ]
            }

        S10 ->
            { name = "Martyrdom"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "images/cards/Swords10.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S11 ->
            { name = "Curiousity"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "images/cards/Swords11.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S12 ->
            { name = "Haste"
            , cost = 3
            , text = "Deal 2 damage."
            , art = "images/cards/Swords12.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S13 ->
            { name = "Perception"
            , cost = 4
            , text = "Deal 2 damage."
            , art = "images/cards/Swords13.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        S14 ->
            { name = "Intellect"
            , cost = 4
            , text = "Deal 2 damage."
            , art = "images/cards/Swords14.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            }

        C1 ->
            { name = "Intuition"
            , cost = 1
            , text = "Gain 1 wisdom. Draw a card."
            , art = "images/cards/Cups01.jpg"
            , effect = [ GainWisdom (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        C2 ->
            { name = "Connection"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups02.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C3 ->
            { name = "Overflow"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups03.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C4 ->
            { name = "Apathy"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups04.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C5 ->
            { name = "Regret"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups05.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C6 ->
            { name = "Innocence"
            , cost = 2
            , text = "Gain 2 wisdom for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "images/cards/Cups06.jpg"
            , effect = [ GainWisdom (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        C7 ->
            { name = "Wishful Thinking"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups07.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C8 ->
            { name = "Weariness"
            , cost = 2
            , text = "Gain 2 wisdom for every card in their scheme."
            , art = "images/cards/Cups08.jpg"
            , effect = [ GainWisdom (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        C9 ->
            { name = "Wish Fulfillment"
            , cost = 2
            , text = "Deal 3 wisdom."
            , art = "images/cards/Cups09.jpg"
            , effect = [ GainWisdom (\_ _ -> 3) ]
            }

        C10 ->
            { name = "Alignment"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups10.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C11 ->
            { name = "Synchronicity"
            , cost = 3
            , text = "Other cards in your scheme cost 1 less to cast."
            , art = "images/cards/Cups11.jpg"
            , effect = [ CostMod (\_ this other -> if this /= other then -1 else 0) ]
            }

        C12 ->
            { name = "Charm"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups12.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C13 ->
            { name = "Compassion"
            , cost = 4
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups13.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        C14 ->
            { name = "Balance"
            , cost = 4
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups14.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            }

        P1 ->
            { name = "Intuition"
            , cost = 1
            , text = "Gain 1 life. Draw a card."
            , art = "images/cards/Pents01.jpg"
            , effect = [ GainHealth (\_ _ -> 1), Draw (\_ _ -> 1) ]
            }

        P2 ->
            { name = "Connection"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents02.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P3 ->
            { name = "Overflow"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents03.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P4 ->
            { name = "Apathy"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents04.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P5 ->
            { name = "Regret"
            , cost = 2
            , text = "Gain 2 life."
            , art = "images/cards/Pents05.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P6 ->
            { name = "Innocence"
            , cost = 2
            , text = "Gain 2 life for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "images/cards/Pents06.jpg"
            , effect = [ GainHealth (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            }

        P7 ->
            { name = "Wishful Thinking"
            , cost = 2
            , text = "Gain 2 life."
            , art = "images/cards/Pents07.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P8 ->
            { name = "Weariness"
            , cost = 2
            , text = "Gain 2 life for every card in their scheme."
            , art = "images/cards/Pents08.jpg"
            , effect = [ GainHealth (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            }

        P9 ->
            { name = "Wish Fulfillment"
            , cost = 2
            , text = "Deal 3 life."
            , art = "images/cards/Pents09.jpg"
            , effect = [ GainHealth (\_ _ -> 3) ]
            }

        P10 ->
            { name = "Alignment"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents10.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P11 ->
            { name = "Synchronicity"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents11.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P12 ->
            { name = "Charm"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents12.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P13 ->
            { name = "Compassion"
            , cost = 4
            , text = "Gain 2 life."
            , art = "images/cards/Pents13.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            }

        P14 ->
            { name = "Balance"
            , cost = 4
            , text = "Gain 2 life."
            , art = "images/cards/Pents14.jpg"
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
