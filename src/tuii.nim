import std/terminal
import tables
import std/[os, strutils]

type
  ColorLevel = enum
    clBasic16
    clAnsi256
    clTrueColor

  Color8Enum* = enum
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  
  Color16Enum* = enum
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

proc detectColorLevel(): ColorLevel =
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

# Set     Reset
# \e[1m   \e[22m  bold
# \e[2m   \e[22m  dim/faint
# \e[3m   \e[23m  italic
# \e[4m   \e[24m  underline
# \e[5m   \e[25m  blinking
# \e[7m   \e[27m  inverse/reverse
# \e[8m   \e[28m  hidden/invisible
# \e[9m   \e[29m  strikethrough

# Styles are simple too:
# \e[{style_1};{style_2};...{style_n}m

# 8-16 colors
# \e[{style};{foreground};{background}m

# 256 Colors
# \e[38;5;{ID}m   FOREGROUND
# \e[48;5;{ID}m   BACKGROUND
#
# 0-7 are standard colors
# 8-15 are high-intensity colors
# 16-231 are 6^6 cube (216 colors)
# 232-255 are grayscale from darker to lighter

# TRUECOLOR
# \e[38;2;{r};{g};{b}m    FOREGROUND
# \e[48;2;{r};{g};{b}m    BACKGROUND

when isMainModule:
  echo rgbToAnsi(255, 120, 9)
  echo "Some text"
  echo "Hello"
  stdout.write ansiResetCode
  discard