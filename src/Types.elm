module Types exposing (..)
import Html exposing (Html)


type alias Player =
    { hand : List Held
    , health : Int
    , sanity : Int
    , wisdom : Int
    , wisdomUsed : Int
    , summon : Maybe SummonDetails
    , dead : Bool
    , draw : Int
    }


type alias Held =
    { card : Card
    , selected : Bool
    , cost : Int
    , index : Int
    }

type alias CardDetails =
    { name : String
    , cost : Int
    , text : String
    , art : String
    , effect : List Effect
    , cardType : CardType
    }


type alias SummonDetails =
    { influence : Int
    , effects : List SummonEffect
    , card : Card
    }

type alias SummonEffect =
    { cost  : Int
    , effects : List Effect
    , text : Html Never
    , selected : Bool
    }


type Effect
    = Damage (Player -> Player -> Int)
    | Discard (Player -> Player -> Int)
    | Draw (Player -> Player -> Int)
    | GainWisdom (Player -> Player -> Int)
    | GainSanity (Player -> Player -> Int)
    | GainHealth (Player -> Player -> Int)
    | Summon Card
    | CostMod (Player -> Held -> Held -> Int)
    | Debug


type CardType
    = W
    | S
    | C
    | P
    | M


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
