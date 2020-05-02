module Term exposing (Term(..), Value, eval, evalString, parse, stringOfValue, stringValue)

import Parser exposing (..)


type Term
    = T
    | F
    | Zero
    | Succ Term
    | Pred Term
    | IsZero Term
    | IfExpr Term Term Term


stringOfValue : Value -> String
stringOfValue val =
    case val of
        Numeric i ->
            String.fromInt i

        Boolean b ->
            if b then
                "true"

            else
                "false"

        Error str ->
            str


type Value
    = Numeric Int
    | Boolean Bool
    | Error String


{-| parse and evalate a string:

    > evalString "if iszero succ 0 then 0 else succ 0"
      Numeric 1 : Result String Value

    > evalString "if iszero succ 0 then 0 else succ 1"
      Error ("Parse error") : Value

    > evalString "if succ iszero succ 0 then 0 else succ 0"
      Error ("If-then-else: expecting boolean value") : Value

-}
evalString : String -> Value
evalString str =
    case run term str of
        Ok ast ->
            eval ast

        Err _ ->
            Error "Parse error"


{-| Find the value of a term:

    > eval (Pred (Succ Zero))
    Numeric 0 : Value

-}
eval : Term -> Value
eval t =
    case t of
        Zero ->
            Numeric 0

        Succ a ->
            case eval a of
                Numeric b ->
                    Numeric (b + 1)

                _ ->
                    Error "succ expects numeric value"

        Pred a ->
            case eval a of
                Numeric b ->
                    if b == 0 then
                        Numeric 0

                    else
                        Numeric (b - 1)

                _ ->
                    Error "pred expects numeric value"

        F ->
            Boolean False

        T ->
            Boolean True

        IsZero a ->
            case eval a of
                Numeric b ->
                    Boolean (b == 0)

                _ ->
                    Error "iszero expects a numeric value"

        IfExpr a b c ->
            case eval a of
                Boolean v ->
                    case v of
                        True ->
                            eval b

                        False ->
                            eval c

                _ ->
                    Error "If-then-else: expecting boolean value"


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



--
-- FUNCTIONS ON TERMS
--


{-| Find the size of a term, i.e., the number of nodes
considered as a tree.
-}
size : Term -> Int
size t =
    case t of
        T ->
            1

        F ->
            1

        Zero ->
            1

        Succ a ->
            1 + size a

        Pred a ->
            1 + size a

        IsZero a ->
            1 + size a

        IfExpr a b c ->
            1 + size a + size b + size c


{-| Find the depth of a term, i.e., its depth considered
as a tree.
-}
depth : Term -> Int
depth t =
    case t of
        F ->
            1

        T ->
            1

        Zero ->
            1

        Succ a ->
            1 + depth a

        Pred a ->
            1 + depth a

        IsZero a ->
            1 + depth a

        IfExpr a b c ->
            1 + (List.maximum [ depth a, depth b, depth c ] |> Maybe.withDefault 0)



--
-- PARSER
--


{-| parse a string in the langauge `arith`. If successful return
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
