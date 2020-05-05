# What is this about?

An Elm implementation of the little language "arith" described in  *Types and Programming Languages,* Chapter 3.  


## Files

- **Term.elm:** the function `parse : String -> Result (List Parser.DeadEnd) Term`

- **Interpreter.elm:** the function `eval : Term -> Value`

- **TypeCheck.elm:** the function `typeCheck : Term -> Maybe Type_`

- **Utility.elm:** the functions `depth, nodeCount, stringValue`.  
Convenient, but not needed for the above

- **Main.elm:** a headless Elm app for implementing a repl

- **repl.js:** a Javascript program which sets up communication between `Main.elm` and the console.

## Operation of the repl  

```
$ cd src
$ sh make.sh
$ node repl.js

> succ succ 0
2

> succ succ false
Not typable
```



## References

- *Types and Programming Languages*, by Benjamin Pierce

- A [Medium article](https://medium.com/@jxxcarlson/implementing-the-mini-language-arith-in-elm-a522f9a7101) on Arith and implementation of a parser for it in Elm.
