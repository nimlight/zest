discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:refc; --gc:arc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/baseframe
import ../src/zest/frame/windowupdateframe


block:
  doAssertRaises(ValueError):
    discard initWindowUpdateFrame(StreamId(12), windowSizeIncrement = 0'u32)


# streamId
block:
  let streamId = @[StreamId(0), StreamId(1), StreamId(2), StreamId(666), StreamId(2333)]
  for idx in streamId:
    let windowUpdateFrame = initWindowUpdateFrame(idx, 12'u32)
    doAssert windowUpdateFrame.serialize.fromByteSeq.
                               newStringStream.readWindowUpdateFrame == windowUpdateFrame


# windowSizeIncrement
block:
  let windowSizeIncrement = @[1'u32, 2'u32, 666'u32, 2233'u32]
  for idx in windowSizeIncrement:
    let windowUpdateFrame = initWindowUpdateFrame(StreamId(12), idx)
    doAssert windowUpdateFrame.serialize.fromByteSeq
                              .newStringStream.readWindowUpdateFrame == windowUpdateFrame
