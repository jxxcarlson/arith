# Extending `arith`
`arith` is a lovely little language, but it lacks a bit of expressiveness. In this lesson we want to remedy that by extending the language.

## Adding a `Term` constructor
There are various options to construct an option. There are the _base_ options: `T`, `F` and `Zero`. And then there are the once that build up complex expression by combining terms: `Succ`, `Pred`, `IsZero` and `IfExpr`.

We would like to add an option here. One that expresses _addition_. We would like to write `add succ succ 0 suc 0` and have that evaluate `3`.

We start by adding a corresponding contructor in `Term`: `Add`. Add will accept two parameters, both other terms.

#### Exercises
Add a `Add Term Term` option to the `Type` enumeration in `Term.elm`.

## Update `stringValue`
Adding a new contructor option to `Term` will break things. The reason for this is that Elm checks if all possible cases are covered in a pattern matched.

One of the things the compiler is warning us about is `stringValue`. This function is responsible for providing a representation of a `Term`.

Luckily we know how we would want to represent a term `Add a b`. It is `add` followed by the representaitions of `a` and `b`.

#### Exercises
Add a case for `Add` in the pattern match on `Term` in `stringValue` and provide an implementation.

## Update `eval`
We now know how to represent a `Add` term, but we would also like to know to what such a term evaluates to. Since we are trying to express addition, we can express that in our `eval` function in `Interpreter.elm`.

If we would want to evaluate a term `Add a b`, we would have to evaluate the sub-terms `a` and `b`, they should both be numeric and we should add their values.

#### Exercises
1. Add a case for `Add` in the pattern match on `Term` in `eval` and provide an implementation.
2. Implement helpfull error handling by reporting which arguments is not numeric.

## Update `typeCheck`
In the previous section we already mentioned the types of the argument.

> ... they should both be **numeric** ...

We can extend the `typeCheck` functin in `TypeCheck.elm` to reflect this insight. 

An `Add a b` term is well-typed if both it's arguments have type `N`, then the type is `N` it self.

#### Exercises
Add a case for `Add` in the pattern match on `Term` in `typeCheck` and provide an implementation.

## Create a parser for `Add`
We have satisfied the compiler, and with it ourselves. But we still aren't able to use a the new addition. We need a parser for that.

One of the great benefits of using `elm/parser` is that it allows you to focus on the problem at hand. I.e. how to parse source code into an `Add` Term. Later we can incorporate the different parsers in the bigger picture.

From the section on `stringValue` we learned the syntax for an `Add` term: `add a b`, where `a` and `b` are the presentations of other terms. We can now express that in our parser.

A parser for an `Add` term is to recognize a symbol `add` followed by a `term` which serves as first argument, followed by another `term` which serves as second argument.

#### Exercises
Create a parser for an `Add` term.

## Using the parser for `Add`
Eventhough we have created a parser for an `Add` term, we still are not using it. For that we should incorporate it our existing code.

Since `Add` is a term a good spot for it is in the parser `term`. It is defined as an _one of_ a bunch of other parser for terms, preceded by spaces. Our `add` parser will fit right in.

There is a slight caveat. Just like the `IfExpr` parser, our `Add` parser is defined in terms of `term`. If we would add `add` directly to the list of alternatives Elm would complain


```
Detected problems in 1 module.
-- CYCLIC DEFINITION ---------------------------------------------- src/Term.elm

The `add` definition is causing a very tricky infinite loop.

98| add =
    ^^^
The `add` value depends on itself through the following chain of definitions:

    ┌─────┐
    │    add
    │     ↓
    │    term
    └─────┘

Hint: The root problem is often a typo in some variable name, but I recommend
reading <https://elm-lang.org/0.19.1/bad-recursion> for more detailed advice,
especially if you actually do want mutually recursive values.
```

The advice to [read bad-recursion](https://elm-lang.org/0.19.1/bad-recursion#tricky-recursion) is pretty solid and explains what is going on.

Luckily, the `elm/parser` catered for this. Precisely with the [`lazy` parser](https://elm-lang.org/0.19.1/bad-recursion), just as for the case with `ifExpr` parser.

#### Exercises
1. Add the `Add` parser to the list of alternatives in the `term` parser.
2. Build the project and fire up the repl. Tryout the new "addition".

## Exercises
1. Extend the `arith` language with _multiplication_.
2. If you wanted to extend the `arith` so that it is possible to write `add 2 1`, how would you do that? Could you do that without extending `Term`? (Hint: there is a [number parser](https://package.elm-lang.org/packages/elm/parser/latest/Parser#number) that can be used with a function that turns an `Int` into a `Term` by applying the right amount of `Succ` to `Zero.)