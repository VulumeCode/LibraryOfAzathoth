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
            , cardType = W
            }

        W2 ->
            { name = "Dominion"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands02.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W3 ->
            { name = "Foresight"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands03.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W4 ->
            { name = "Perfection"
            , cost = 1
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands04.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W5 ->
            { name = "Conflict"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands05.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W6 ->
            { name = "Pride"
            , cost = 2
            , text = "Gain 2 sanity for every card in your scheme."
            , art = "images/cards/Wands06.jpg"
            , effect = [ GainSanity (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            , cardType = W
            }

        W7 ->
            { name = "Conviction"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands07.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W8 ->
            { name = "Change"
            , cost = 2
            , text = "Gain 2 sanity for every card in your opponent's scheme."
            , art = "images/cards/Wands08.jpg"
            , effect = [ GainSanity  (\_ they -> 2 * (List.length <| List.filter .selected they.hand))]
            , cardType = W
            }

        W9 ->
            { name = "Stamina"
            , cost = 2
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands09.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W10 ->
            { name = "Oppression"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands10.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W11 ->
            { name = "Discovery"
            , cost = 3
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands11.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W12 ->
            { name = "Energy"
            , cost = 3
            , text = "Gain 1 sanity"
            , art = "images/cards/Wands12.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W13 ->
            { name = "Vibrance"
            , cost = 4
            , text = "Gain 1 sanity."
            , art = "images/cards/Wands13.jpg"
            , effect = [ GainSanity (\_ _ -> 1) ]
            , cardType = W
            }

        W14 ->
            { name = "Visions"
            , cost = 4
            , text = "Other Wand cards cost 3 less to cast.<br>Gain 1 sanity."
            , art = "images/cards/Wands14.jpg"
            , effect = 
                [ CostMod
                    (\_ this other ->
                        if this /= other && (other.card |> cardDetails |> .cardType) == W then
                            -3

                        else
                            0
                    )
                , GainSanity (\_ _ -> 1)
                ]
            , cardType = W
            }

        S1 ->
            { name = "Justice"
            , cost = 1
            , text = "Deal 1 damage. Draw a card."
            , art = "images/cards/Swords01.jpg"
            , effect = [ Damage (\_ _ -> 1), Draw (\_ _ -> 1) ]
            , cardType = S
            }

        S2 ->
            { name = "Stalemate"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords02.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            , cardType = S
            }

        S3 ->
            { name = "Betrayal"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords03.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            , cardType = S
            }

        S4 ->
            { name = "Truce"
            , cost = 1
            , text = "Deal 2 damage."
            , art = "images/cards/Swords04.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            , cardType = S
            }

        S5 ->
            { name = "Defeat"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "images/cards/Swords05.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            , cardType = S
            }

        S6 ->
            { name = "Science"
            , cost = 2
            , text = "Deal 2 damage for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "images/cards/Swords06.jpg"
            , effect = [ Damage (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            , cardType = S
            }

        S7 ->
            { name = "Uselessness"
            , cost = 2
            , text = "Deal 2 damage."
            , art = "images/cards/Swords07.jpg"
            , effect = [ Damage (\_ _ -> 2) ]
            , cardType = S
            }

        S8 ->
            { name = "Confusion"
            , cost = 2
            , text = "Deal 2 damage for every card in your opponent's scheme."
            , art = "images/cards/Swords08.jpg"
            , effect = [ Damage (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            , cardType = S
            }

        S9 ->
            { name = "Cruelty"
            , cost = 2
            , text = "Deal 3 damage."
            , art = "images/cards/Swords09.jpg"
            , effect = [ Damage (\_ _ -> 3) ]
            , cardType = S
            }

        S10 ->
            { name = "Martyrdom"
            , cost = 3
            , text = "Deal 2 damage to yourself and 5 damage to your opponent."
            , art = "images/cards/Swords10.jpg"
            , effect = [ Damage (\_ _ -> 5) , GainHealth (\_ _ -> -2)]
            , cardType = S
            }

        S11 ->
            { name = "Curiousity"
            , cost = 3
            , text = "Deal 4 damage."
            , art = "images/cards/Swords11.jpg"
            , effect = [ Damage (\_ _ -> 4) ]
            , cardType = S
            }

        S12 ->
            { name = "Haste"
            , cost = 3
            , text = "Deal 5 damage. You lose 1 intellect."
            , art = "images/cards/Swords12.jpg"
            , effect = [ Damage (\_ _ -> 5), GainWisdom (\_ _ -> -1)]
            , cardType = S
            }

        S13 ->
            { name = "Perception"
            , cost = 4
            , text = "Deal damage equal to your influence."
            , art = "images/cards/Swords13.jpg"
            , effect = [ Damage (\you _ -> you.summon |> Maybe.map .influence |> Maybe.withDefault 0) ]
            , cardType = S
            }

        S14 ->
            { name = "Intellect"
            , cost = 4
            , text = "Other Sword cards cost 3 less to cast.<br>Deal 1 damage."
            , art = "images/cards/Swords14.jpg"
            , effect =
                [ CostMod
                    (\_ this other ->
                        if this /= other && (other.card |> cardDetails |> .cardType) == S then
                            -3

                        else
                            0
                    )
                , Damage (\_ _ -> 1)
                ]
            , cardType = S
            }

        C1 ->
            { name = "Intuition"
            , cost = 1
            , text = "Gain 1 wisdom. Draw a card."
            , art = "images/cards/Cups01.jpg"
            , effect = [ GainWisdom (\_ _ -> 1), Draw (\_ _ -> 1) ]
            , cardType = C
            }

        C2 ->
            { name = "Connection"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups02.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C3 ->
            { name = "Overflow"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups03.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C4 ->
            { name = "Apathy"
            , cost = 1
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups04.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C5 ->
            { name = "Regret"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups05.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C6 ->
            { name = "Innocence"
            , cost = 2
            , text = "Gain 2 wisdom for every card in your scheme.<hr><i>Baboom!</i>"
            , art = "images/cards/Cups06.jpg"
            , effect = [ GainWisdom (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            , cardType = C
            }

        C7 ->
            { name = "Wishful Thinking"
            , cost = 2
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups07.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C8 ->
            { name = "Weariness"
            , cost = 2
            , text = "Gain 2 wisdom for every card in your opponent's scheme."
            , art = "images/cards/Cups08.jpg"
            , effect = [ GainWisdom (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            , cardType = C
            }

        C9 ->
            { name = "Wish Fulfillment"
            , cost = 2
            , text = "Gain 3 wisdom."
            , art = "images/cards/Cups09.jpg"
            , effect = [ GainWisdom (\_ _ -> 3) ]
            , cardType = C
            }

        C10 ->
            { name = "Alignment"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups10.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C11 ->
            { name = "Synchronicity"
            , cost = 3
            , text = "Other cards cost 1 less to cast."
            , art = "images/cards/Cups11.jpg"
            , effect =
                [ CostMod
                    (\_ this other ->
                        if this /= other then
                            -1

                        else
                            0
                    )
                ]
            , cardType = C
            }

        C12 ->
            { name = "Charm"
            , cost = 3
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups12.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C13 ->
            { name = "Compassion"
            , cost = 4
            , text = "Gain 2 wisdom."
            , art = "images/cards/Cups13.jpg"
            , effect = [ GainWisdom (\_ _ -> 2) ]
            , cardType = C
            }

        C14 ->
            { name = "Balance"
            , cost = 4
            , text = "Other Cup cards cost 3 less to cast.<br>Gain 1 wisdom."
            , art = "images/cards/Cups14.jpg"
            , effect =
                [ CostMod
                    (\_ this other ->
                        if this /= other && (other.card |> cardDetails |> .cardType) == C then
                            -3

                        else
                            0
                    )
                , GainWisdom (\_ _ -> 1)
                ]
            , cardType = C
            }

        P1 ->
            { name = "Manifestation"
            , cost = 1
            , text = "Gain 1 life. Draw a card."
            , art = "images/cards/Pents01.jpg"
            , effect = [ GainHealth (\_ _ -> 1), Draw (\_ _ -> 1) ]
            , cardType = P
            }

        P2 ->
            { name = "Adapt"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents02.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P3 ->
            { name = "Collaborate"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents03.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P4 ->
            { name = "Security"
            , cost = 1
            , text = "Gain 2 life."
            , art = "images/cards/Pents04.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P5 ->
            { name = "Poverty"
            , cost = 2
            , text = "Gain 2 life."
            , art = "images/cards/Pents05.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P6 ->
            { name = "Generosity"
            , cost = 2
            , text = "Gain 2 life for every card in your scheme.<hr><i>A momentary abatement...</i>"
            , art = "images/cards/Pents06.jpg"
            , effect = [ GainHealth (\you _ -> 2 * (List.length <| List.filter .selected you.hand)) ]
            , cardType = P
            }

        P7 ->
            { name = "Profit"
            , cost = 2
            , text = "Gain life equal to your wisdom."
            , art = "images/cards/Pents07.jpg"
            , effect = [ GainHealth (\you _ -> you.wisdom) ]
            , cardType = P
            }

        P8 ->
            { name = "Education"
            , cost = 2
            , text = "Gain 2 life for every card in your opponent's scheme."
            , art = "images/cards/Pents08.jpg"
            , effect = [ GainHealth (\_ they -> 2 * (List.length <| List.filter .selected they.hand)) ]
            , cardType = P
            }

        P9 ->
            { name = "Gratitude"
            , cost = 2
            , text = "Gain 3 life."
            , art = "images/cards/Pents09.jpg"
            , effect = [ GainHealth (\_ _ -> 3) ]
            , cardType = P
            }

        P10 ->
            { name = "Wealth"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents10.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P11 ->
            { name = "Enterprise"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents11.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P12 ->
            { name = "Habit"
            , cost = 3
            , text = "Gain 2 life."
            , art = "images/cards/Pents12.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P13 ->
            { name = "Abundance"
            , cost = 4
            , text = "Gain 2 life."
            , art = "images/cards/Pents13.jpg"
            , effect = [ GainHealth (\_ _ -> 2) ]
            , cardType = P
            }

        P14 ->
            { name = "Discipline"
            , cost = 4
            , text = "Other Sigil cards cost 3 less to cast.<br>Gain 1 wisdom."
            , art = "images/cards/Pents14.jpg"
            , effect =
                [ CostMod
                    (\_ this other ->
                        if this /= other && (other.card |> cardDetails |> .cardType) == P then
                            -3

                        else
                            0
                    )
                , GainSanity (\_ _ -> 1)
                ]
            , cardType = P
            }

        M0 ->
            { name = "The Fool"
            , cost = 1
            , text = ""
            , art = "images/cards/RWS_Tarot_00_Fool.jpg"
            , effect = [ Summon M0 ]
            , cardType = M
            }

        M1 ->
            { name = "The Magician"
            , cost = 2
            , text = ""
            , art = "images/cards/RWS_Tarot_01_Magician.jpg"
            , effect = [ Summon M1 ]
            , cardType = M
            }

        M2 ->
            { name = "The High Priestess"
            , cost = 4
            , text = ""
            , art = "images/cards/RWS_Tarot_02_High_Priestess.jpg"
            , effect = [ Summon M2 ]
            , cardType = M
            }

        M3 ->
            { name = "The Empress"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_03_Empress.jpg"
            , effect = [ Summon M3 ]
            , cardType = M
            }

        M4 ->
            { name = "Cthulhu Sleeping"
            , cost = 6
            , text = "When summoned, you and your opponent lose all sanity."
            , art = "images/cards/RWS_Tarot_04_Emperor.jpg"
            , effect = [ Summon M4, GainSanity (\you _ -> -(you.sanity) + you.wisdomUsed ) ] --TODO
            , cardType = M
            }

        M5 ->
            { name = "Nyarlathotep"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_05_Hierophant.jpg"
            , effect = [ Summon M5 ]
            , cardType = M
            }

        M6 ->
            { name = "The Lovers"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_06_Lovers.jpg"
            , effect = [ Summon M6 ]
            , cardType = M
            }

        M7 ->
            { name = "The Chariot"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_07_Chariot.jpg"
            , effect = [ Summon M7 ]
            , cardType = M
            }

        M8 ->
            { name = "Strength"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_08_Strength.jpg"
            , effect = [ Summon M8 ]
            , cardType = M
            }

        M9 ->
            { name = "The Hermit"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_09_Hermit.jpg"
            , effect = [ Summon M9 ]
            , cardType = M
            }

        M10 ->
            { name = "Wheel of Fortune"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_10_Wheel_of_Fortune.jpg"
            , effect = [ Summon M10 ]
            , cardType = M
            }

        M11 ->
            { name = "Justice"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_11_Justice.jpg"
            , effect = [ Summon M11 ]
            , cardType = M
            }

        M12 ->
            { name = "The Hanged Man"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_12_Hanged_Man.jpg"
            , effect = [ Summon M12 ]
            , cardType = M
            }

        M13 ->
            { name = "Death"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_13_Death.jpg"
            , effect = [ Summon M13 ]
            , cardType = M
            }

        M14 ->
            { name = "Temperance"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_14_Temperance.jpg"
            , effect = [ Summon M14 ]
            , cardType = M
            }

        M15 ->
            { name = "The Devil"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_15_Devil.jpg"
            , effect = [ Summon M15 ]
            , cardType = M
            }

        M16 ->
            { name = "The Tower"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_16_Tower.jpg"
            , effect = [ Summon M16 ]
            , cardType = M
            }

        M17 ->
            { name = "The Star"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_17_Star.jpg"
            , effect = [ Summon M17 ]
            , cardType = M
            }

        M18 ->
            { name = "Gibbous Moon"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_18_Moon.jpg"
            , effect = [ Summon M18 ]
            , cardType = M
            }

        M19 ->
            { name = "The Sun"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_19_Sun.jpg"
            , effect = [ Summon M19 ]
            , cardType = M
            }

        M20 ->
            { name = "Judgement"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_20_Judgement.jpg"
            , effect = [ Summon M20 ]
            , cardType = M
            }

        M21 ->
            { name = "The World"
            , cost = 4
            , text = "Summon ~."
            , art = "images/cards/RWS_Tarot_21_World.jpg"
            , effect = [ Summon M21 ]
            , cardType = M
            }


allCards : List Card
allCards =
    [ W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21 ]


random : Random.Generator Card
random =
    Random.uniform W1 [ W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, M0, M1, M2, M3, M4 ]


cardBack =
    "images/back.jpg"
