module TypeCheck exposing (Type_(..), toString, typeCheck, typeCheckString)

import Parser exposing (..)
import Term exposing (Term(..))



{-

   REFERENCE: Chapter 8 of *Types and Programming Languages, by Benjamin Pierce

-}


type Type_
    = B
    | N


toString : Type_ -> String
toString type_ =
    case type_ of
        B ->
            "Boolean"

        N ->
            "Nat"


{-| The function typeCheckString attempts to parse its input. If parsing
fails, Nothing is returned. If parsing succeeds, a type checker
is run on the resulting term. It the term is typable, its type,
Just B for boolean and Just N for a natural number is returned.
If the term is not typable, the Nothing is returned.

> typeCheckString "succ zero"
> Nothing : Maybe Type\_

> typeCheckString "succ 0"
> Just N : Maybe Type\_

> typeCheckString "succ false"
> Nothing : Maybe Type\_

> typeCheckString "if iszero 0 then true else false"
> Just B : Maybe Type\_

> typeCheckString "if iszero 0 then true else 0"
> Nothing : Maybe Type\_

-}
typeCheckString : String -> Maybe Type_
typeCheckString str =
    (typeCheckResult << Term.parse) str


typeCheckResult : Result (List Parser.DeadEnd) Term -> Maybe Type_
typeCheckResult result =
    (Maybe.andThen typeCheck << Result.toMaybe) result


typeCheck : Term -> Maybe Type_
typeCheck term =
    case term of
        T ->
            Just B

        F ->
            Just B

        Zero ->
            Just N

        Succ term_ ->
            case typeCheck term_ of
                Just B ->
                    Nothing

                Just N ->
                    Just N

                Nothing ->
                    Nothing

        Pred term_ ->
            case typeCheck term_ of
                Just B ->
                    Nothing

                Just N ->
                    Just N

                Nothing ->
                    Nothing

        IsZero term_ ->
            case typeCheck term_ of
                Just B ->
                    Nothing

                Just N ->
                    Just B

                Nothing ->
                    Nothing

        IfExpr t1 t2 t3 ->
            case ( typeCheck t1, typeCheck t2, typeCheck t3 ) of
                ( Just B, Just B, Just B ) ->
                    Just B

                ( Just B, Just N, Just N ) ->
                    Just N

                _ ->
                    Nothing
