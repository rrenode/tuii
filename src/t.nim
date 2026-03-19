import std/[os, strutils, terminal, colors]

when defined(windows):
  import winim/lean


  # On Windows, at least Win11, the colors returned are not the same order of ansi
  # For instance: 
  #   0. the first color is black (matches ANSI); 
  #   1. the next color reported is "blue" which maps to ANSI fg34 and bg44 (x-term 4)
  const winToAnsi = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15]
  const ansiToWin = [0, 4, 2, 6, 1, 5, 3, 7, 8, 12, 10, 14, 9, 13, 11, 15]

const RS = "\e[0m"

let red = "RED:\t\t \e[31mHello!"

let boldRed = "boldRed:\t \e[1;31mHello!"

let brightRed = "brightRed:\t \e[91mHello!"

let boldBrightRed = "boldBrightRed:\t \e[1;91mHello!"

stdout.write RS & red & "\n"
stdout.write RS & boldRed & "\n"
stdout.write RS & brightRed & "\n"
stdout.write RS & boldBrightRed
stdout.write "\e[0m"

stdout.write "\n\n" & "\e[38;5;3mHello!\n" & RS
stdout.write "\e[33mHello!" & RS & "\n"

stdout.write "\e[38;2;12;12;12mtext\e[0m\n\n"

proc r*(c: Color): int =
  let (r,g,b) = extractRGB(c)
  return r

proc g*(c: Color): int =
  let (r,g,b) = extractRGB(c)
  return g

proc b*(c: Color): int =
  let (r,g,b) = extractRGB(c)
  return b

proc getNativeTermRendererColorPalette(): seq[Color] =
  ## Get's the color palette from the system's native terminal renderer
  when defined(windows):
    # On Windows, at least Win11, the colors returned are not the same order of ansi
    # See winToAnsi const...
    var info: CONSOLE_SCREEN_BUFFER_INFOEX
    info.cbSize = sizeof(info).DWORD

    let h = GetStdHandle(STD_OUTPUT_HANDLE)
    if h == INVALID_HANDLE_VALUE:
      quit("GetStdHandle failed")

    if GetConsoleScreenBufferInfoEx(h, addr info) == 0:
      quit("GetConsoleScreenBufferInfoEx failed")

    for i in 0 .. 15:
      let c = info.ColorTable[i]
      let r = int(c and 0xFF)
      let g = int((c shr 8) and 0xFF)
      let b = int((c shr 16) and 0xFF)

      let clr: Color = rgb(r, g, b)
      result.add(clr)
  else:
    # Yeah this doesn't do jack shit...
    let tty = open("/dev/tty")
    tty.write "\e]4;1;?\a"
    tty.flushFile()

    var line: string
    discard tty.readLine(line)
    echo repr(line)
    tty.close()

proc previewPalette(p: seq[Color]) = 
  for i, c in p:
    let cc = ansiForegroundColorCode(c)
    stdout.write cc
    
    echo "TermClr1: "
    echo "  |- ansi: ", repr(cc)
    echo "  |- RGB(", c.r, ",", c.g, ",", c.b, ")"
    echo "  |- Hex: ", c, "\n"
    stdout.write RS

let palette = getNativeTermRendererColorPalette()
previewPalette(palette)