module Term exposing (..)

-- (eval, term, size, depth)

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
-- RUN
--
{- }
   > ev "if iszero succ 0 then 0 else succ 0"
   Ok (Numeric 1) : Result String Value

   > ev "if iszero succ 0 then 0 else succ 1"
   Err ("parser error") : Result String Value

   > ev "if succ iszero succ 0 then 0 else succ 0"
   Ok Error : Result String Value
-}


ev : String -> Result String Value
ev str =
    case run term str of
        Ok ast ->
            Ok (eval ast)

        Err _ ->
            Err "parser error"



--
-- EVALUATOR
--


type Value
    = Numeric Int
    | Boolean Bool
    | Error


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
                    Error

        Pred a ->
            case eval a of
                Numeric b ->
                    Numeric (b - 1)

                _ ->
                    Error

        F ->
            Boolean False

        T ->
            Boolean True

        IsZero a ->
            case eval a of
                Numeric b ->
                    Boolean (b == 0)

                _ ->
                    Error

        Cond a b c ->
            case eval a of
                Boolean v ->
                    case v of
                        True ->
                            eval b

                        False ->
                            eval c

                _ ->
                    Error



--
-- FUNCTIONS
--


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

        Cond a b c ->
            1 + size a + size b + size c


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

        Cond a b c ->
            1 + (List.maximum [ depth a, depth b, depth c ] |> Maybe.withDefault 0)



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
