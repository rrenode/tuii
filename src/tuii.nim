##
## This problem domain is vast and in many areas unstandardized.
##  
##  We have to consider:
##    \|-> User's Color Capacity - with envs that are at least partly standardized
##    \|-> Term's Color Capacity - 
##              which is not standardized and has several pieces:
##                - term emulator (config/internal)
##                - native term (system level APIs; some use envs)
##    \|-> Term's default colors
##
## ENV's to Support (based on Python's Typer):
## `TERM` - "dumb" or "unknown" will disable color/style and some 
##    features that require moving the cursor, such as progress bars.
## 
## `FORCE_COLOR` - if set and non-empty,
##    then color/styles will be enabled regardless of the value of TERM.
## 
## `NO_COLOR` - if set, disables all color in the output. NO_COLOR takes 
##    precedence over FORCE_COLOR.
## 
## `COLUMNS` - overrides auto-detection of visible width
## 
## `LINES` - overrides auto-detection of visible height

import std/[os, strutils, terminal]

type
  ColorLevel = enum
    clBasic16
    clAnsi256
    clTrueColor

  Color8* = enum
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  
  ColorBright* = enum
    brightBlack
    brightRed
    bightGreen
    brightYellow
    brightBlue
    brightMagenta
    brightCyan
    brightWhite
  
  RGBColor* = object
    r: int
    g: int
    b: int

proc fgId(clr: Color8): int =
  case clr
  of Color8.black: 30
  of Color8.red: 31
  of Color8.green: 32
  of Color8.yellow: 33
  of Color8.blue: 34
  of Color8.magenta: 35
  of Color8.cyan: 36
  of Color8.white: 37
  else: 39

proc bgId(clr: Color8): int =
  case clr
  of Color8.black: 40
  of Color8.red: 41
  of Color8.green: 42
  of Color8.yellow: 43
  of Color8.blue: 44
  of Color8.magenta: 45
  of Color8.cyan: 46
  of Color8.white: 47
  else: 49

proc fgId(clr: ColorBright): int =
  case clr
  of ColorBright.black: 90
  of ColorBright.red: 91
  of ColorBright.green: 92
  of ColorBright.yellow: 93
  of ColorBright.blue: 94
  of ColorBright.magenta: 95
  of ColorBright.cyan: 96
  of ColorBright.white: 97
  else: 39

proc bgId(clr: ColorBright): int =
  case clr
  of ColorBright.black: 100
  of ColorBright.red: 101
  of ColorBright.green: 102
  of ColorBright.yellow: 103
  of ColorBright.blue: 104
  of ColorBright.magenta: 105
  of ColorBright.cyan: 106
  of ColorBright.white: 107
  else: 49

proc detectColorLevel(): ColorLevel =
  ## std/terminal doesn't play nice with Windows
  let colorterm = getEnv("COLORTERM", "").toLowerAscii
  let term = getEnv("TERM", "").toLowerAscii

  if colorterm in ["truecolor", "24bit"]:
    return clTrueColor

  if "256color" in term:
    return clAnsi256

  clBasic16

var termColorLevel: ColorLevel = detectColorLevel()

proc rgbToAnsi(r, g, b: int): string =
  return "\x1B[38;2;" & $r & ";" & $g & ";" & $b & "m"

# ESC
# \e      - idk
# \u001b  - UNICODE
# \x1B    - Hexadecimal
# \033    - Octal 

# RESETS
# \e[39m - reset foreground
# \e[49m - reset background
# \e[0m  - reset everything

#[
┌─────┬───────┬──────────────────┐
│ Set │ Reset │      Style       │
├─────┼───────┼──────────────────┤
│   1 │    22 │ bold             │
│   2 │    22 │ dim/faint        │
│   3 │    23 │ italic           │
│   4 │    24 │ underline        │
│   5 │    25 │ blinking         │
│   7 │    27 │ inverse/reverse  │
│   8 │    28 │ hidden/invisible │
│   9 │    29 │ strikethrough    │
└─────┴───────┴──────────────────┘
]#

# Styles are simple too:
# \e[{style_1};{style_2};...{style_n}m

# 8-16 colors
# \e[{style};{foreground};{background}m <-- technically order of these doesn't matter

# 256 Colors
# The omly order that matters is 256 and truecolor.
# \e[38;5;{ID}m   FOREGROUND (note the prefix of 38;5)
# \e[48;5;{ID}m   BACKGROUND (note the prefix of 48;5)
#
# 0-7 are standard colors
# 8-15 are high-intensity colors
# 16-231 are 6^6 cube (216 colors)
# 232-255 are grayscale from darker to lighter

# TRUECOLOR
# \e[38;2;{r};{g};{b}m    FOREGROUND (note the prefix of 38;2)
# \e[48;2;{r};{g};{b}m    BACKGROUND (note the prefix of 48;2)

when isMainModule:
  echo rgbToAnsi(255, 120, 9)
  echo "Some text"
  echo "Hello"
  stdout.write ansiResetCode
  discard