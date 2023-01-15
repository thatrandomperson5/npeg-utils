# npeg-utils
A collection of [npeg](https://github.com/zevv/npeg) utils. 
# Docs
* [`astc`](https://thatrandomperson5.github.io/npeg-utils/astc)
* [`indent`](https://thatrandomperson5.github.io/npeg-utils/indent)
# Tutorial
This tutorial builds a parser for a indented-data file format. This tutorial assumes you know the basics of npeg
## Part 1-Indent parser
First, add the basics:
```nim
import npeg, npeg_utils/[indent, astc]

let parser = peg("stmt"):
  # Parser goes here!
```
Then we can work on the parser, the data file will be a string, key-value, type format:
```
Key:
  IndentedValue
  IndentedKey:
    OtherValue
Value
```
So, first, we need to describe the key and value:
```nim
Data <- +Alnum # One or more numbers/letters
Key <- Data * ":" # Data and a colon
Value <- Data * !":" # Data, and for saftey, explicit not colon
```
The next step is indentation! We will be using `ib.Line` and `ib.Block`.
```nim
KeyBlock <- ib.Line(Key) * ib.Block(stmt)
```
The code above parses a properly indented line and then a further indented block with the main stmt.
Now we can move on to the main stmt.
```nim
stmt <- +(ib.Line(Value) | KeyBlock)
```
This parses a value or a indented key block! This should now parse the example above.