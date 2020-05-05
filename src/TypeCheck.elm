module TypeCheck exposing (Type_(..), typeCheck, typeCheckString)

import Term exposing(Term(..))

import Parser exposing (..)

type Type_
    = B
    | N

{-|

  > typeCheckString "succ zero"
  Nothing : Maybe Type_

  > typeCheckString "succ 0"
  Just N : Maybe Type_

  > typeCheckString "succ false"
  Nothing : Maybe Type_

  > typeCheckString "if iszero 0 then true else false"
  Just B : Maybe Type_

  > typeCheckString "if iszero 0 then true else 0"
  Nothing : Maybe Type_

-}
typeCheckString : String -> Maybe Type_
typeCheckString str =
  (typeCheckResult << Term.parse) str

typeCheckResult : Result (List Parser.DeadEnd) Term -> Maybe Type_
typeCheckResult result =
  case result of
    Err _ -> Nothing
    Ok term -> typeCheck term

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
            if typeCheck t1 /= Just B then
                Nothing

            else if typeCheck t2 == typeCheck t3 then
                typeCheck t3

            else
                Nothing
