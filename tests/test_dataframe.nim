discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; --gc:arc --d:release"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams, strformat


import ../src/zest/frame/baseframe
import ../src/zest/frame/dataframe


block:
  let 
    length = 1'u32
    frameType = FrameType.Data
    flag = FlagDataEndStream
    streamId = StreamId(21474836'u32)
    frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
    payload = @[1'u8]
    padding = none(Padding)
    dataFrame = initDataFrame(frameHeaders, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 1, 0, 1, 1, 71, 174, 20, 1]

  var str = fromByteSeq(serialize)
  let 
    strm = newStringStream(move(str))
    readed = strm.readDataFrame

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert readed.headers.flag == flag
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.isNone
  doAssert readed.payload == payload
  strm.close()
