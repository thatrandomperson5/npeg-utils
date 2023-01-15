import npeg
# Inspired by the example

## ================
## Indents in npeg
## ================
##
## Grammar `ib`
## ============
##
## `EOL <- "\r\n" | "\n" | "\r" | !1`
##
## `whitespace <- *Blank`
##
## `Indent <- >whitespace`
##     Ensure that the indent has increased, add to indent stack
##
## `Dedent <- >whitespace`
##     Ensure that the indent has decreased, pop from the indent stack
##
## `Static <- >whitespace`
##     Ensure that the indent has not changed
##
## `Line(content) <- ib.Static * content * ib.EOL`
##     Properly formatted indent-checked line. Content is the line parser
##
## `Block(content) <- &ib.Indent * content * (&ib.Dedent | !1)`
##     Properly formatted indented block. Content is ensured to be intdented
##

var indentStack* = newSeq[int]()

proc resetIndent*() = 
  ## Remove all indent data
  
  indentStack = newSeq[int]()

template indent*(): int = indentStack.len
  ## Get the current indent level

template top*[T](s: seq[T]): T = 
  ## A utility to find the top-most item of a seq
  
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
    discard indentStack.pop

  Static <- >whitespace:
    validate len($0) == indentStack.top
  Line(content) <- ib.Static * content * ib.EOL
  Block(content) <- &ib.Indent * content * (&ib.Dedent | !1)
    