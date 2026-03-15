# [red]Some text[/red]
# \e[1;91m

# [#fc0000]Some text[/#fc0000]
# [#fc0000]Some text[/]
# [bg:#fc0000]Some text[/]


# [blue][bg:#fc0000]Some [/]text[/]

import chroma
import std/strutils

let c = "ff0000"
let g = parseHex(c)
let gb = g.toHtmlRgb()

let s = "[blue][bg:red]Some [/]text[/]"
# \e[0;34;41mSome

type NotImplementedError = object of CatchableError

type
  TokenType* = enum
    tkOpen, tkClose, tkText

  Token* = object
    kind: TokenType
    data: string

proc parse(s: string): seq[Token] =
  var eof: bool = false
  var curPos: int = 0
  var curChar: char = s[curPos]
  var curS: string = ""

  proc advance(n: int = 1) =
    curPos += n
    if curPos >= s.len:
      eof = true
      return
    curChar = s[curPos]
  
  var tokens: seq[Token]
  
  proc readText() =
    if curS.len > 0:
      tokens.add(Token(kind:TokenType.tkText, data:curS))
      curS = ""

  proc parseOpenStyle() =
    advance()
    var eot: bool = false
    while not eot:
      if curChar == ']':
        advance()
        eot = true
      else:
        curS = curS & curChar
        advance()
    tokens.add(Token(kind:TokenType.tkOpen, data:curS))

  proc parseCloseStyle() =
    advance(2)
    var eot: bool = false
    while not eot:
      if curChar == ']':
        advance()
        eot = true
      else:
        curS = curS & curChar
        advance()
    tokens.add(Token(kind:TokenType.tkClose, data:curS))

  proc parseOpenTag() =
    # First save cur string
    if curPos-1 > -1 and s[curPos - 1] == '/':
      raise newException(NotImplementedError, "Style escape not implemented yet.")
    if curPos + 1 < s.len and s[curPos + 1] == '/':
      parseCloseStyle()
    else:
      parseOpenStyle()
    curS = ""

  while not eof:
    if curChar == '[':
      readText()
      parseOpenTag()
    else:
      # Assume text
      curS = curS & curChar
      advance()
  return tokens

proc fgNameAnsiId(clr: string): int =
  case clr
  of "blue": 34
  of "red": 31
  else: 39

proc bgNameAnsiId(clr: string): int =
  case clr
  of "blue": 44
  of "red": 41
  else: 49

proc buildStack(stack: seq[string]): string =
  var bg = 49
  var fg = 39

  for s in stack:
    if s.startsWith("bg:"):
      bg = bgNameAnsiId(s.split(":")[1])
    elif s.startsWith("fg:"):
      fg = fgNameAnsiId(s.split(":")[1])
    else:
      fg = fgNameAnsiId(s)

  return "\e[" & $fg & ";" & $bg & "m"

let tokens = parse(s)
echo tokens
var stack: seq[string] = @[]

for tok in tokens:
  case tok.kind
  of tkOpen:
    stack.add(tok.data)
  of tkClose:
    if stack.len > 0:
      discard stack.pop()
  of tkText:
    stdout.write buildStack(stack)
    stdout.write tok.data
    stdout.write "\e[0m"