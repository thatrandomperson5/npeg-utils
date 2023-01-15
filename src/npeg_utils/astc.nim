import npeg, std/[algorithm]
## =================================
## Adoption style tree construction 
## =================================
##
## Grammar `astc`
## ==============
##
## `bhook <- 0`
##    A before statment hook
##
## `ehook <- 0`
##    An error hook
##
## `hooked(content) <- astc.bhook * (content | astc.ehook)` 
##    Use this to properly adopt groups, just use `astc.hooked()`
##
##    **Note:** This requires the `AdoptionCenter` to be named `ac`
##

grammar "astc": # Requires `ac` naming
  bhook <- 0:
    ac.addMarker()
  ehook <- 0:
    ac.failMarker()
    validate false

  hooked(content) <- astc.bhook * (content | astc.ehook)

type 
  AdoptionCenter*[T] = ref object
    s: seq[T]
    markers: seq[int]
  User*[T] = proc (node: var T, children: seq[T])

proc defaultUser[T](node: var T, children: seq[T]) =
  for child in children:
    node.add child

proc newAdoptionCenter*[T](): AdoptionCenter[T] = AdoptionCenter[T]()
  ## Create a new AdoptionCenter type

proc add*[T](a: var AdoptionCenter[T], node: T) = a.s.add node
  ## Register a node for adoption

proc addMarker*[T](a: AdoptionCenter[T]) = 
  ## Add a marker
  a.markers.add a.len

proc failMarker*[T](a: AdoptionCenter[T]) = 
  ## Remove a marker without processing
  discard a.markers.pop

proc len*[T](a: AdoptionCenter[T]): int = a.s.len
  ## Get the length of un-adopted children

proc pop*[T](a: var AdoptionCenter[T]): T = a.s.pop
  ## Pop the un-adopted children seq

proc `[]`*[T](a: AdoptionCenter[T], i: int): T = a.s[i]
  ## Self-explanatory

proc adopt*[T](node: var T, a: var AdoptionCenter[T], amount: int, u: User[T]=defaultUser[T]) =
  ## Adopt `amount` amount of children to `node` using `u`

  var ramount = amount
  var tmp: seq[T]
  if amount == 0:
    ramount = a.len
  for _ in 1..ramount:
    tmp.add a.pop
  u(node, tmp.reversed)

proc adopt*[T](node: var T, a: var AdoptionCenter[T], u: User[T]=defaultUser) =
  ## Adopt marked amount to `node` using `u`

  var lastNode: T
  let target = a.markers.pop
  var tmp: seq[T]
  while a.len > target:
    lastNode = a.pop
    tmp.add lastNode
  u(node, tmp.reversed)
 
template adoptCycle*(center: untyped, n: untyped, cond: untyped): untyped =
  ## Equivalent to: 
  ##
  ## .. code:: nim
  ##
  ##   n.adopt(center, cond)
  ##   center.add n
  ##
  ## ..
  ## 
  ## **Note:** `n` must be var
  
  `n`.adopt(`center`, `cond`)
  `center`.add `n`

template adoptCycle*(center: untyped, n: untyped): untyped =
  `n`.adopt(`center`)
  `center`.add `n`