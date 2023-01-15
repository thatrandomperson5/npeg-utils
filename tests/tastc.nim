import npeg_utils/astc, npeg, json, std/[parseutils, tables]


proc makeJObj(node: var JsonNode, children: seq[JsonNode]) =
  let chs = children
  doAssert (chs.len mod 2) == 0
  for i in countup(0, chs.high, 2):
    let key = chs[i]
    let value = chs[i+1]
    node.add key.getStr, value

let jsonParser = peg("doc", ac: AdoptionCenter[JsonNode]):
  S              <- *Space
  jtrue          <- "true": ac.add newJBool(true)
  jfalse         <- "false": ac.add newJBool(false)
  jnull          <- "null": ac.add newJNull()

  unicodeEscape  <- 'u' * Xdigit[4]
  escape         <- '\\' * ({ '{', '"', '|', '\\', 'b', 'f', 'n', 'r', 't' } | unicodeEscape)
  stringBody     <- ?escape * *( +( {'\x20'..'\xff'} - {'"'} - {'\\'}) * *escape)
  jstring        <- ?S * '"' * >stringBody * '"' * ?S: ac.add newJString($1)

  minus          <- '-'
  intPart        <- '0' | (Digit-'0') * *Digit
  fractPart      <- "." * +Digit
  expPart        <- ( 'e' | 'E' ) * ?( '+' | '-' ) * +Digit
  jnumber        <- >(?minus * intPart * ?fractPart * ?expPart):
    var res: int
    if parseInt($1, res) == len($1):
      ac.add newJInt(res)
    else:
      var resFloat: float
      doAssert parseFloat($1, resFloat) == len($1)
      ac.add newJFloat(resFloat)
     

  doc            <- JSON * !1
  JSON           <- ?S * ( jnumber | jobject | jarray | jstring | jtrue | jfalse | jnull ) * ?S
  jpair          <- jstring * ":" * JSON
  jobject        <- astc.hooked('{' * ( jpair * *( "," * jpair ) | ?S ) * '}'):
    var jo = newJObject()
    adoptCycle(ac, jo, makeJObj)

  jarray         <- astc.hooked("[" * ( JSON * *( "," * JSON ) | ?S ) * "]"):
    var ja = newJArray()
    adoptCycle(ac, ja)


proc NpegParseJson(json: string): JsonNode =
  var ac = newAdoptionCenter[JsonNode]()
  doAssert jsonParser.match(json, ac).ok
  return ac[0]

echo NpegParseJson("""[
"hello",
 5,
 5.5,
 null,
 ["hello", "world", true, [false]]
]""").pretty

echo NpegParseJson(readFile("tests/astc.json")).pretty