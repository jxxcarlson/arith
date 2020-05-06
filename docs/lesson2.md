## Chomping

A more low-level operation is "chomping". "chomping" here means consuming characters, moving along in the input string, but not actually doing anything with the consumed characters. The chomping parsers all have type `Parser ()`, not e.g. `Parser String` like you might expect. We'll get back to this later.

The `chompIf` parser will chomp exactly one character if the predicate (a `Char -> Bool` function) is true for the next character of the input.

```elm
chompIf : (Char -> Bool) -> Parser () 
```

The `chompWhile` parser will continually chomp characters if the condition remains true.

```elm
chompWhile : (Char -> Bool) -> Parser () 
```

### Examples

Chomping a positive integer. 

```elm
chompInteger : Parser ()
chompInteger =
    chompIf Char.isDigit
        |. chompWhile Char.isDigit
```

An integer needs to consist of at least one digit, hence the `chompIf`. But after that it can be arbitrarily long, so `chompWhile` keeps chomping as long as the next character is a digit.

Similarly required whitespace (so, one or more spaces) can be chomped using:
```elm
isSpace : Char -> Bool
isSpace c = 
    c == ' ' || c == '\n' || c == '\r'

chompRequiredSpace : Parser ()
chompRequiredSpace =
    chompIf isSpace
        |. chompWhile isSpace 
```

## Working with the parsed string

The chomping parsers don't give direct access to the string that they parse. Sometimes you want that though!

The `getChompedString` function gives the string that is consumed by the given parser.

```elm
getChompedString : Parser a -> Parser String
```

For insance, to not only chomp a sequence of digits, but also get its integer value, we can use `getChompedString` and `String.fromInt`.

```elm
chompInteger : Parser ()
chompInteger =
    chompIf Char.isDigit
        |. chompWhile Char.isDigit

integer : Parser Int
integer =
    chompInteger
        |> getChompedString 
        |> Parser.map (\digits ->
            digits 
                |> String.fromInt
                |> Maybe.withDefault 0
        )
```

The `withDefault` is safe because the input to `String.fromInt` is always a sequence of digits.

## Repeating parsers

Repeating a parser a fixed number of times is straightforward with the `succeed`/pipeline pattern: 

```elm
succeed Tuple.pair
    |= myParser
    |= myParser
```

But what if you want to parse a list of numbers, a block of statements, or a file of definitions. It is unknown up-front how often the parser should be repeated. For arbitrary repitition, the parser package exposes

```elm
type Step state a 
    = Loop state
    | Done a

loop : state -> (state -> Parser (Step state a)) -> Parser a
```

Which can be used like so to parse a list of something, in this case statements:

```elm
statements : Parser (List Stmt)
statements =
  loop [] statementsHelp

statementsHelp : List Stmt -> Parser (Step (List Stmt) (List Stmt))
statementsHelp revStmts =
  oneOf
    [ succeed (\stmt -> Loop (stmt :: revStmts))
        |= statement
        |. spaces
        |. symbol ";"
        |. spaces
    , succeed (Done (List.reverse revStmts)))
    ]
```

This will try to parse a statement. If it succeeds, the newly parsed statement is added to the accumulator `resStmts`. The `Loop` variant indicates that the parser should attempt to parse another statement. When parsing a statement eventually fails, the `Done` variant is used to stop the looping. The most-recently parsed statement (that occurrs last in the input) is at the head of the `revStmts` list, so it has to be reversed. 

Wait, why not use recursion? isn't that how we FP programmers usually solve looping? It is, but because `Parser` is an opaque type (it does not expose its variants), we cannot write tail-recursive functions with it. That means that recursive function calls must grow the stack, which is slow and can cause a stack overflow. Instead, `Parser.loop` is a tail-recursive function, and we must suply it with a stepper function. 

## Parser errors

When a parser fails, it produces a `List DeadEnd`, where `DeadEnd` is defined as:

```elm
type alias DeadEnd =
    { row : Int
    , col : Int
    , problem : Problem
    }
```

So a dead end is a problem and a location at which it occurs. Note that `row` and `col` start at 1, like in text editors. `Problem` for the `Parser` module is defined as: 

```elm
type Problem
    = ExpectingInt
    | ExpectingHex
    | ExpectingOctal
    | ExpectingBinary
    | ExpectingFloat
    | ExpectingNumber
    | ExpectingVariable
    | ExpectingSymbol String
    | ExpectingKeyword String

    | ExpectingEnd
    | UnexpectedChar
    | BadRepeat

    | Expecting String
    | Problem String
```

The `ExpectingInt` (hex, octal, etc.) problems are thrown by their respective parser. The others are: 

* `ExpectingEnd`: caused by `Parser.end` when the end of the input has not been reached yet.
* `UnexpectedChar`: caused by `chompIf`, e.g. `run (chompIf (\c -> c == 'a')) "bbb"`.
* `BadRepeat`: not used any more

Two variants are useful for simple custom errors.

* `Expecting String` when you expect a specific character or group of characters but did not find it.
* `Problem String` when anything else is wrong. 

```elm
run (chompIf (\c -> c == 'x')) "yyy"
    --> [ { row = 1, col = 1, problem = UnexpectedChar } ]

run Parser.end "nonempty"
    --> [ { row = 1, col = 1, problem = ExpectingEnd } ]

oneTwo = 
    oneOf
        [ symbol "one"
        , symbol "two"
        ]

run oneTwo "three"
    --> [ { row = 1, col = 1, problem = ExpectingSymbol "one" }
    --> , { row = 1, col = 1, problem = ExpectingSymbol "two" }
    --> ]
```

### Creating your own problems

*insert joke here*

When the parser ends up in an invalid state, you can report a problem yourself with `Parser.problem`:

```elm
myProblem =
    Parser.problem (Problem "something is wrong")

run myProblem "whatever"
    --> [ { row = 1, col = 1, problem = Problem "something is wrong" } ]
```

Reporting a problem can also be used to validate what you've just parsed:

```elm
evenInt : Parser Int
evenInt =
    Parser.int
        |> Parser.andThen (\number ->
            if (number |> modBy 2) == 0 then
                Parser.succeed number
            else
                Parser.problem (Expecting "an even integer, found odd")
        )
```
