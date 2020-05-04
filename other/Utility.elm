module Utility exposing(depth, size)

import Term exposing(Term(..))

--
-- FUNCTIONS ON TERMS
--


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
