module Summon exposing (..)

import Card exposing (cardDetails)
import Debug
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Value)
import Maybe exposing (withDefault)
import Types exposing (..)


getSummonDetails : Card -> Maybe SummonDetails
getSummonDetails card =
    case card |> Card.cardDetails |> .cardType of
        M ->
            Just <| summonDetails card

        _ ->
            Nothing


summonDetails : Card -> SummonDetails
summonDetails card =
    case card of
        M0 ->
            { -- "The Fool"
              card = card
            , influence = 5
            , effects = [ SummonEffect -1 [ GainSanity (\_ _ -> 1) ] (text "Gain 1 sanity.") True ]
            }

        M1 ->
            { -- "The Magician"
              card = card
            , influence = 3
            , effects =
                [ SummonEffect 1 [ Draw (\_ _ -> 1) ] (text "Draw a card.") True
                , SummonEffect -2 [ PreventDraw (\_ _ -> 1) ] (text "Opponent draws one card less.") False
                ]
            }

        M2 ->
            { -- "The High Priestess"
              card = card
            , influence = 1
            , effects =
                [ SummonEffect 0 [ GainIntellect (\_ _ -> 1) ] (text "Gain one intellect.") True
                ]
            }

        M3 ->
            { -- "The Empress"
              card = card
            , influence = 1
            , effects =
                [ SummonEffect 0 [ GainVitality (\_ _ -> 1) ] (text "Gain one vitality.") True
                ]
            }

        M4 ->
            { -- "Cthulhu Sleeping"
              card = card
            , influence = 4
            , effects =
                [ SummonEffect 2 [ GainSanity (\_ _ -> -1) ] (text "Lose one sanity.") True
                , SummonEffect -6 [ PreventDraw (\_ _ -> 10) ] (text "Banish all summons. Opponent discards all summon cards.") False --TODO
                ]
            }

        M5 ->
            { -- "Nyarlathotep"
              card = card
            , influence = 4
            , effects =
                [ SummonEffect 1 [ Damage (\_ _ -> 1) ] (text "Deal one damage.") True
                , SummonEffect -6 [ PreventDraw (\_ _ -> 10) ] (text "Banish Nyarlathotep, then take control of your opponent's summon.") False --TODO
                ]
            }

        M6 ->
            { -- "The Lovers"
              card = card
            , influence = 4
            , effects =
                [ SummonEffect -1 [  ] (text "Opponent loses 1 influence.") True --TODO InfluenceDamage (\_ _ -> 1)
                ]
            }

        M7 ->
            { -- "The Chariot"
              card = card
            , influence = 1
            , effects =
                [ SummonEffect 1 [] (Html.i [] [ text "Charge" ]) True
                , SummonEffect 0 [ Damage (\you _ -> you.summon |> Maybe.map .influence |> withDefault 0) ] (text "Deal damage equal to your influence.") False
                , SummonEffect -3
                    [ CostMod
                        (\_ _ other ->
                            if (other.card |> cardDetails |> .cardType) == M then
                                -3

                            else
                                0
                        )
                    ]
                    (text "Summon cards cost 3 less to cast.")
                    False
                ]
            }

        M8 ->
            { -- "Strength"
              card = card
            , influence = 8
            , effects =
                [ SummonEffect 0 [] (Html.i [] [ text "Stand your ground" ]) True
                , SummonEffect -2 [ Damage (\you _ -> you.summon |> Maybe.map .influence |> withDefault 0) ] (text "Deal damage equal to your influence.") False
                ]
            }

        M9 ->
            { -- "The Hermit"
              card = card
            , influence = 4
            , effects =
                [ SummonEffect 1 [ GainIntellect (\_ _ -> 1) ] (text "Gain 1 intellect") True
                , SummonEffect -5 [ Draw (\_ _ -> 5) ] (text "Discard your hand, then draw 5 cards.") False -- TODO  Discard (\_ _ _ -> True),
                ]
            }

        M10 ->
            { -- "Wheel of Fortune"
              card = card
            , influence = 2
            , effects =
                [ SummonEffect 1 [ Draw (\_ _ -> 1) ] (text "Draw a card") True
                , SummonEffect -5 [ GainVitality (\_ _ -> 10) ] (text "Gain 10 vitality.") False -- TODO
                ]
            }

        M11 ->
            { -- "Justice"
              card = card
            , influence = 2
            , effects =
                [ SummonEffect 0 [ Damage (\_ they -> they.intellectUsed) ] (text "Deal damage equal to your opponent's spent intellect.") True
                , SummonEffect -2 [ Damage (\you _ -> you.intellectUsed) ] (text "Deal damage equal to your spent intellect.") False -- TODO
                ]
            }

        _ ->
            summonDetails M0



-- M12 ->
--     { name = "The Hanged Man"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_12_Hanged_Man.jpg"
--     , effect = [ Summon M12 ]
--     , cardType = M
--     }
-- M13 ->
--     { name = "Death"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_13_Death.jpg"
--     , effect = [ Summon M13 ]
--     , cardType = M
--     }
-- M14 ->
--     { name = "Temperance"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_14_Temperance.jpg"
--     , effect = [ Summon M14 ]
--     , cardType = M
--     }
-- M15 ->
--     { name = "The Devil"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_15_Devil.jpg"
--     , effect = [ Summon M15 ]
--     , cardType = M
--     }
-- M16 ->
--     { name = "The Tower"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_16_Tower.jpg"
--     , effect = [ Summon M16 ]
--     , cardType = M
--     }
-- M17 ->
--     { name = "The Star"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_17_Star.jpg"
--     , effect = [ Summon M17 ]
--     , cardType = M
--     }
-- M18 ->
--     { name = "Gibbous Moon"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_18_Moon.jpg"
--     , effect = [ Summon M18 ]
--     , cardType = M
--     }
-- M19 ->
--     { name = "The Sun"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_19_Sun.jpg"
--     , effect = [ Summon M19 ]
--     , cardType = M
--     }
-- M20 ->
--     { name = "Judgement"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_20_Judgement.jpg"
--     , effect = [ Summon M20 ]
--     , cardType = M
--     }
-- M21 ->
--     { name = "The World"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_21_World.jpg"
--     , effect = [ Summon M21 ]
--     , cardType = M
--     }
