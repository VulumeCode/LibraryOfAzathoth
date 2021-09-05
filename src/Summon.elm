module Summon exposing (..)

import Debug
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Value)
import Types exposing (..)


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
                [ SummonEffect 1 [ Draw (\_ _ -> 1) ] (text "Draw a card.") False
                , SummonEffect -2 [ Discard (\_ _ -> 1) ] (text "Opponent discards a card.") True
                ]
            }

        _ ->
            summonDetails M0



-- M2 ->
--     { name = "The High Priestess"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_02_High_Priestess.jpg"
--     , effect = [ Summon M2 ]
--     , cardType = M
--     }
-- M3 ->
--     { name = "The Empress"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_03_Empress.jpg"
--     , effect = [ Summon M3 ]
--     , cardType = M
--     }
-- M4 ->
--     { name = "Cthulhu Sleeping"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_04_Emperor.jpg"
--     , effect = [ Summon M4 ]
--     , cardType = M
--     }
-- M5 ->
--     { name = "Nyarlathotep"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_05_Hierophant.jpg"
--     , effect = [ Summon M5 ]
--     , cardType = M
--     }
-- M6 ->
--     { name = "The Lovers"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_06_Lovers.jpg"
--     , effect = [ Summon M6 ]
--     , cardType = M
--     }
-- M7 ->
--     { name = "The Chariot"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_07_Chariot.jpg"
--     , effect = [ Summon M7 ]
--     , cardType = M
--     }
-- M8 ->
--     { name = "Strength"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_08_Strength.jpg"
--     , effect = [ Summon M8 ]
--     , cardType = M
--     }
-- M9 ->
--     { name = "The Hermit"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_09_Hermit.jpg"
--     , effect = [ Summon M9 ]
--     , cardType = M
--     }
-- M10 ->
--     { name = "Wheel of Fortune"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_10_Wheel_of_Fortune.jpg"
--     , effect = [ Summon M10 ]
--     , cardType = M
--     }
-- M11 ->
--     { name = "Justice"
--     , cost = 4
--     , text = "Summon ~."
--     , art = "images/cards/RWS_Tarot_11_Justice.jpg"
--     , effect = [ Summon M11 ]
--     , cardType = M
--     }
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
