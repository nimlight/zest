discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/flags


block:
  doAssert FlagPadded == Flag(8)
  doAssert FlagPadded != FlagEndStream
  doAssert (FlagPadded and FlagEndStream) == Flag(0)
  doAssert (FlagPadded or FlagEndStream) == Flag(9)
  doAssert Flag(12).contains(FlagHeadersEndHeaders)
  doAssert Flag(9).contains(FlagPadded)
  doAssert Flag(9).contains(FlagEndStream)
  doAssert not Flag(9).contains(FlagHeadersEndHeaders)
  doAssert not Flag(9).contains(FlagHeadersPriority)
