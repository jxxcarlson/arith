module Term exposing (Term(..), parse, stringValue, term)

import Parser exposing (..)


type Term
    = T
    | F
    | Zero
    | Succ Term
    | Pred Term
    | IsZero Term
    | IfExpr Term Term Term


{-| parse a string in the language `arith`. If successful return
a value Ok Term. Otherwise return a value `Err String`

NOTE: This parser will parse the longest valid prefix in an
input string. For example, "parse 0 == parse 0 succ".

-}
parse : String -> Result (List Parser.DeadEnd) Term
parse str =
    run term str


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
            , lazy (\_ -> ifExpr)
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
    symbol "succ"
        |> andThen (\_ -> term)
        |> map (\t -> Succ t)


pred : Parser Term
pred =
    symbol "pred"
        |> andThen (\_ -> term)
        |> map (\t -> Pred t)


iszero : Parser Term
iszero =
    symbol "iszero"
        |> andThen (\_ -> term)
        |> map (\t -> IsZero t)


ifExpr : Parser Term
ifExpr =
    succeed IfExpr
        |. symbol "if"
        |= term
        |. spaces
        |. symbol "then"
        |= term
        |. spaces
        |. symbol "else"
        |= term


{-| Compute the string corresponding to a term.

    > stringValue (Pred (Succ Zero))
      "pred succ 0 " : String

-}
stringValue : Term -> String
stringValue t =
    case t of
        Zero ->
            "0 "

        Succ a ->
            "succ " ++ stringValue a

        Pred a ->
            "pred " ++ stringValue a

        F ->
            "False "

        T ->
            "True "

        IsZero a ->
            "iszero " ++ stringValue a

        IfExpr a b c ->
            "if " ++ stringValue a ++ "then " ++ stringValue b ++ "else " ++ stringValue c
