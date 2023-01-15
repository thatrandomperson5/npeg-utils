import npeg
import std/unittest
import npeg_utils/indent
test "Test valid":
  let testParser = peg("tinput"):
    name <- >(+Alpha) * ":"
    value <- >(+Alnum) * !":"
    tcontent <-  (ib.Line(name) * ib.Block(tblock)) | ib.Line(value)
    tblock <- +tcontent
    tinput <- tblock * !1
  const testStr = """Foo:
    BarForward
    FooBar:
        Bar
        Bar2
    Bar3
Fooo:
    Barr
    Foooo:
        Bar4
Bar5"""
  resetIndent()
  echo testStr
  let r = testParser.match(testStr)
  doAssert r.ok

test "Test invalid":
  let testParser = peg("tinput"):
    name <- >(+Alpha) * ":"
    value <- >(+Alnum) * !":"
    tcontent <-  (ib.Line(name) * ib.Block(tblock)) | ib.Line(value)
    tblock <- +tcontent
    tinput <- tblock * !1
  const testStr = """Foo:
    FooBar:
        Bar
        Bar2
    Bar3
Fooo:
    Barr
    Foooo:
Bar5"""
  resetIndent()
  echo testStr
  let r = testParser.match(testStr)
  doAssert not r.ok

test "Test Values":
  type OC = tuple[kind: string, s: string, indent: int]
  let testParser = peg("tinput", o: seq[OC]):
    name <- >(+Alpha) * ":":
      o.add ("name", $1, indent())
    value <- >(+Alnum) * !":":
      o.add ("value", $1, indent())
    tcontent <-  (ib.Line(name) * ib.Block(tblock)) | ib.Line(value)
    tblock <- +tcontent
    tinput <- tblock * !1

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
  resetIndent()
  echo testStr
  let r = testParser.match(testStr, o)
  echo o
  doAssert r.ok

