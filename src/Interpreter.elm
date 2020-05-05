module Interpreter exposing (eval, evalString, stringOfValue)

import Parser exposing (run)
import Term exposing (Term(..), term)


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
