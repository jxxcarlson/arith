port module Main exposing (main)

import Interpreter
import Platform exposing (Program)
import Term
import TypeCheck



{- A simple Platform.worker program that
   acts as in interface between the repl defined in
   repl.js and your elm code.  The Elm code should
   expose a function

        transform : String -> String

    Whatever you text you enter at the command prompt
    is used as input to `transform`. The resulting
    output displayed on the screen.

    Run

       $ node repl.js

    for the repl.  The help text is defined in the string
    `helpText` below.
-}


port get : (String -> msg) -> Sub msg


port put : String -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type Msg
    = Input String


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            case input == "h\n" || input == "help\n" of
                True ->
                    ( model, put helpText )

                False ->
                    ( model, put (transform input) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    get Input


transform : String -> String
transform inp =
    case Term.parse inp of
        Err _ ->
            "Parse error"

        Ok term_ ->
            case TypeCheck.typeCheck term_ of
                Nothing ->
                    "Not typable"

                Just type_ ->
                    Interpreter.evalString inp
                        |> Interpreter.stringOfValue


helpText =
    """
This app parses, typechecks and evaluates
expressions for the mini-language "Arith"
described in Benjamin Peirce's "Types and Programming Languages."

Examples of what you can do at the command line:

    > succ succ 0
    2

    > succ false
    Not typable

    > succ "foo"
    Parse error

See the README for more info.
"""
