import npeg, std/[algorithm]
  
## Adoption style tree construction
## =================================

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

proc add*[T](a: var AdoptionCenter[T], node: T) = a.s.add node

proc addMarker*[T](a: AdoptionCenter[T]) = 
  a.markers.add a.len

proc failMarker*[T](a: AdoptionCenter[T]) = 
  discard a.markers.pop

proc len*[T](a: AdoptionCenter[T]): int = a.s.len

proc pop*[T](a: var AdoptionCenter[T]): T = a.s.pop

proc `[]`*[T](a: AdoptionCenter[T], i: int): T = a.s[i]

proc adopt*[T](node: var T, a: var AdoptionCenter[T], amount: int, u: User[T]=defaultUser[T]) =
  var ramount = amount
  var tmp: seq[T]
  if amount == 0:
    ramount = a.len
  for _ in 1..ramount:
    tmp.add a.pop
  u(node, tmp.reversed)

proc adopt*[T](node: var T, a: var AdoptionCenter[T], u: User[T]=defaultUser) =
  var lastNode: T
  let target = a.markers.pop
  var tmp: seq[T]
  while a.len > target:
    lastNode = a.pop
    tmp.add lastNode
  u(node, tmp.reversed)
 
template adoptCycle*(center: untyped, n: untyped, cond: untyped): untyped =
  `n`.adopt(`center`, `cond`)
  `center`.add `n`

template adoptCycle*(center: untyped, n: untyped): untyped =
  `n`.adopt(`center`)
  `center`.add `n`