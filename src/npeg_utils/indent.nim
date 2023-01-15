import npeg
# Inspired by the example
var indentStack* = newSeq[int]()

proc resetIndent*() = 
    indentStack = newSeq[int]()

template indent*(): int = indentStack.len

template top*[T](s: seq[T]): T = 
    if s.high == -1:
        0
    else:
        s[s.high]




grammar "ib":
    EOL <- "\r\n" | "\n" | "\r" | !1
    whitespace <- *Blank

    Indent <- >whitespace: 
        validate len($0) > indentStack.top
        indentStack.add len($0)
    Dedent <- >whitespace:
        let delStack = len($0)
        validate delStack < indentStack.top
        while delStack < indentStack.top:
            discard indentStack.pop
    Static <- >whitespace:
        validate len($0) == indentStack.top
    Line(content) <- ib.Static * content * ib.EOL
    Block(content) <- &ib.Indent * content * (&ib.Dedent | !1)
    