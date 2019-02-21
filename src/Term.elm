module Term exposing (..)

import Parser exposing (..)


type Term
    = T
    | F
    | Zero
    | Succ Term
    | Pred Term
    | IsZero Term
    | Cond Term Term Term



--
-- PARSER
--


term : Parser Term
term =
    succeed identity
        |. spaces
        |= oneOf
            [ true
            , false
            , zero
            , succ
            , pred
            , iszero
            , lazy (\_ -> cond)
            ]


true : Parser Term
true =
    succeed T
        |. symbol "true"


false : Parser Term
false =
    succeed F
        |. symbol "false"


zero : Parser Term
zero =
    succeed Zero
        |. symbol "0"


succ : Parser Term
succ =
    symbol "succ" |> andThen (\_ -> term) |> map (\t -> Succ t)


pred : Parser Term
pred =
    symbol "pred" |> andThen (\_ -> term) |> map (\t -> Pred t)


iszero : Parser Term
iszero =
    symbol "iszero" |> andThen (\_ -> term) |> map (\t -> IsZero t)


cond : Parser Term
cond =
    succeed Cond
        |. symbol "if"
        |= term
        |. spaces
        |. symbol "then"
        |= term
        |. spaces
        |. symbol "else"
        |= term
