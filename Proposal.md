# Proposal


## Learning goal

To learn to write parsers in Elm.

## Title

*Writing Parsers in Elm*

## Pitch to organizers

Parsers have a reputation of being scary/hard.  They are not, and the goal is for every participant to come away from the workshop with enough experience to write parsers on their own.  I've spent a good deal of time working with the elm/parser library in various projects, so I think I could do a reasonable job of this. I've also recruited three people to help with workshop; if it is approved, we will develop the workshop materials and program together.  There will be some material that participants can look at in advance if they wish.


## Outline

The workshop will consist of the following parts:

1. **Intro.** What is a parser and what are they used for.  Will give a few examples, e.g, parsing dates, parsing expressions in a _very_ simple language, like the `Arith` language of *Types and Programming Languages* (15 minutes)

2. **Basics.** We will learn to use primitive parsers in `elm/parser` and to combine them to form more complex parsers: `oneOf` for alternatives, parser pipelines for sequencing, etc.  All this in the context of examples and short exercises to be done by the participants to extend the range of the examples (45 minutes)

3. **Break.** 10 minutes

4. The `Arith` language, or something similar.  This is the toy language of Benjamin Pierce's *Types and Programming Languages* (TAPL). While the topic may seem far-out, it is quite limited in scope and self-contained.  Additionally, the code needed to implement the parser, interpreter and main program to provide the command-line interface is very small (81, 67, 37 loc respectively). Small is good when time is limited.  There is also a 17-line JS program needed for the CLI. (45 minutes)

5. **Break.** 10 min

6. **Extend** the language or create a new one.  We will have suggested extensions that participants can work on, but if some one has an idea of their own, they will be encouraged to pursue it (within reason: it should not be so ambitious as to be impossible to do in the remaining time). 2 hours.

The above may change a bit as our team of four discusses the program, but this is the general idea.
