# Tutorial
import npeg, npeg_utils/[indent, astc]

{.experimental: "codeReordering".}

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

let parser = peg("main", ac: AdoptionCenter[MyData]):
  Data <- +Alnum # One or more numbers/letters
  Key <- >Data * ":" # Data and a colon
  Value <- >Data * !":": # Capture the data and then handle it
    ac.add MyData(kind: Value, v: $1) # Set the data obj made from capture up for adoption

  KeyBlock <- astc.hooked(ib.Line(Key) * ib.Block(stmt)): 
    var container = MyData(kind: Container, key: $1) # Create the container and add the key
    adoptCycle(ac, container)

  stmt <- +(ib.Line(Value) | KeyBlock)
  main <- stmt * !1

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