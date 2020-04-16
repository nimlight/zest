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
  doAssert FlagDataPadded == Flag(8)
  doAssert FlagDataPadded != FlagDataEndStream
  doAssert (FlagDataPadded and FlagDataEndStream) == Flag(0)
  doAssert (FlagDataPadded or FlagDataEndStream) == Flag(9)
  doAssert Flag(12).contains(FlagHeadersEndHeaders)
  doAssert Flag(9).contains(FlagDataPadded)
  doAssert Flag(9).contains(FlagDataEndStream)
  doAssert not Flag(9).contains(FlagHeadersEndHeaders)
  doAssert not Flag(9).contains(FlagHeadersPriority)
