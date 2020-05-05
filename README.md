# What is this about?

An Elm implementation of the little language "arith" described in  *Types and Programming Languages,* Chapter 3.  


## Files

- **Term.elm:** the function `parse : String -> Result (List Parser.DeadEnd) Term`

- **Interpreter.elm:** the function `eval : Term -> Value`

- **TypeCheck.elm:** the function `typeCheck : Term -> Maybe Type_`

- **Main.elm:** a headless Elm app for implementing a repl

- **repl.js:** a Javascript program which sets up communication between `Main.elm` and the console.


## References

- *Types and Programming Languages, by Benjamin Pierce

- A [Medium article](https://medium.com/@jxxcarlson/implementing-the-mini-language-arith-in-elm-a522f9a7101) on Arith and implementation of a parser for it in Elm.
