# Tutorial
import npeg, npeg_utils/[indent, astc]

let parser = peg("stmt"):
  Data <- +Alnum # One or more numbers/letters
  Key <- Data * ":" # Data and a colon
  Value <- Data * !":" # Data, and for saftey, explicit not colon

  KeyBlock <- ib.Line(Key) * ib.Block(stmt)
  stmt <- +(ib.Line(Value) | KeyBlock)

const testStr = """
Key:
  IndentedValue
  IndentedKey:
    OtherValue
Value"""

doAssert parser.match(teststr).ok