discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; --gc:arc --d:release"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams


import ../src/zest/frame/baseframe
import ../src/zest/frame/goawayframe


# lastStreamId
block:
  let
    id = [0, 1, 2, 3, 888, 999]
  for idx in id:
    let goAwayFrame = initGoAwayFrame(StreamId(idx), ErrorCode.No, debugData = @[1'u8, 2])
    doAssert goAwayFrame.serialize.fromByteSeq.newStringStream.readGoAwayFrame == goAwayFrame


# ErrorCode
block:
  for idx in 0 .. 13:
    let goAwayFrame = initGoAwayFrame(StreamId(2333), ErrorCode(idx), debugData = @[1'u8, 2])
    doAssert goAwayFrame.serialize.fromByteSeq.newStringStream.readGoAwayFrame == goAwayFrame


# debugData
block:
  block:
    let goAwayFrame = initGoAwayFrame(StreamId(2333), ErrorCode.Protocol, debugData = @[])
    doAssert goAwayFrame.serialize.fromByteSeq.newStringStream.readGoAwayFrame == goAwayFrame

  block:
    let goAwayFrame = initGoAwayFrame(StreamId(2333), ErrorCode.Protocol, debugData = @[1'u8])
    doAssert goAwayFrame.serialize.fromByteSeq.newStringStream.readGoAwayFrame == goAwayFrame

  block:
    let goAwayFrame = initGoAwayFrame(StreamId(2333), ErrorCode.Protocol, 
                                      debugData = @[1'u8, 9, 7, 5, 6, 7, 8])
    doAssert goAwayFrame.serialize.fromByteSeq.newStringStream.readGoAwayFrame == goAwayFrame
