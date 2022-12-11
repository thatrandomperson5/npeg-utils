import npeg
import std/unittest
import npeg_utils/indent
test "can parse":
  type OC = tuple[kind: string, s: string, indent: int]
  let testParser = peg("tblock", o: seq[OC]):
    name <- >(+Alpha) * ":":
      o.add ("name", $1, indent())
    value <- >(+Alnum):
      o.add ("value", $1, indent())
    tcontent <-  (ib.Line(name) * ib.Block(tblock)) | ib.Line(value)
    tblock <- +tcontent

  var o = newSeq[OC]()
  const testStr = """Foo:
    FooBar:
        Bar
        Bar2
    Bar3
Fooo:
    Barr
    Foooo:
        Bar4
Bar5"""
  echo testStr
  let r = testParser.match(testStr, o)
  assert r.ok
  echo o
