# npeg-utils
A collection of [npeg](https://github.com/zevv/npeg) utils.

Install using this command:
```
nimble install https://github.com/thatrandomperson5/npeg-utils
```
# Contents

<!-- AutoContentStart -->
- [Docs](#docs)
- [Tutorial](#tutorial)
    * [Part 1-Indent parser](#part-1-indent-parser)
    * [Part 2-Gathering data](#part-2-gathering-data)
    * [Seeing the results](#seeing-the-results)

<!-- AutoContentEnd -->

# Docs
* [`astc`](https://thatrandomperson5.github.io/npeg-utils/astc)
* [`indent`](https://thatrandomperson5.github.io/npeg-utils/indent)
# Tutorial
This tutorial builds a parser for a indented-data file format. This tutorial assumes you know the basics of npeg
## Part 1-Indent parser
First, add the basics:
```nim
import npeg, npeg_utils/[indent, astc]

let parser = peg("main"):
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
main <- stmt * !1
```
This parses a value or a indented key block! This should now parse the example above.

## Part 2-Gathering data
To gather data like this in nim, we need to use a nodetree type. Put this before your parser:
```nim
type 
  MyDataKind = enum Container, Value # The kind enum

  MyData = ref object # Needs to be a ref object
    case kind: MyDataKind # Variation
    of Value:
      v: string # If it is the Value kind have a field v of type string
    of Container:
      key: string # The parsed key
      children: seq[MyData] # Its indented children

      
proc add(parent: MyData, child: MyData) = # Add an "add" proc
  parent.children.add child # Add the child to the parent node

```
And then change this line:
```nim
let parser = peg("stmt"):
```
to:
```nim
let parser = peg("stmt", ac: AdoptionCenter[MyData]):
```
We need to collect the data using the `ac` var inside the parser, 
this part of the tutorial will tell you how!

First we need to add a code block in the value definition:
```nim
  Value <- >Data * !":": # Capture the data and then handle it
    ac.add MyData(kind: Value, v: $1) # Set the data obj made from capture up for adoption
``` 
Finally we change the KeyBlock.
```nim
  Key <- >Data * ":" # Save the data
```
This captures the key for us, but we still need data. Thats what the astc module is for!
```nim
  KeyBlock <- astc.hooked(ib.Line(Key) * ib.Block(stmt)): 
    var container = MyData(kind: Container, key: $1) # Create the container and add the key
    adoptCycle(ac, container)
```
**Note:** `astc.hooked` is required to use this version of the adopt proc. Look at the docs for other versions

You may be wondering what the `adoptCycle` does? 
Well it adopts the right children (the ones parsed under it) and then puts itself up for adoption!
This system lets you build nodetrees from parsed data!

## Seeing the results
Now that the parser and data collecter is done, we still need to know how to use it!
After you add the lines of code below your project should be ready to run!
```nim
proc `$`(d: MyData): string =
  if d.kind == Value:
    return d.v
  else:
    result = d.key & "["
    for child in d.children:
      result &= $child & ", "
    result &= "]"

const testStr = """Key:
  IndentedValue
  IndentedKey:
    OtherValue
Value"""
var ac = newAdoptionCenter[MyData]()
doAssert parser.match(testStr, ac).ok
echo $ac
```
See the final version [here](https://github.com/thatrandomperson5/npeg-utils/tree/main/tests/tut2.nim)
