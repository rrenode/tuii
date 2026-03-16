# This little script is meant to determine, the best it can,
#   what is compatible with the current terminal.
# Not an easy task apparently.
# Most in here is more to be used as a guide to inform
#   display decision, not the determinate.

import std/[os, terminal, unicode, strutils]

proc envLocale(): string =
  let lcAll = getEnv("LC_ALL")
  if lcAll.len > 0:
    return lcAll
  getEnv("LANG")

proc supportsUtf8(): bool =
  let loc = envLocale().toUpperAscii()
  "UTF-8" in loc or "UTF8" in loc

proc isRedirected(): bool =
  not isatty(stdout)

proc supportsUnicode(): bool =
  ## Best effort... 
  ## I don't really consider this as reliable...
  isatty(stdout) and supportsUtf8()

proc supportsEmoji(): bool =
  supportsUnicode()

when isMainModule:
  echo "[WARN] This is based on assumptions and is a best guess."
  echo "The values may not reflect the capabilities of a terminal."
  echo "\nCapability Assumptions:"
  echo "  |- utf-8 support: ", supportsUtf8()
  echo "  |- stdout redirected: ", isRedirected()
  echo "  |- unicode support: ", supportsUnicode()
  echo "  |- emoji support: ", supportsEmoji()