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


# test "empty payload"
block:
  let 
    length = 0'u32
    frameType = FrameType.Data
    flag = FlagDataEndStream
    streamId = StreamId(21474836'u32)
    frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
    payload: seq[byte] = @[]
    padding = none(Padding)
    dataFrame = initDataFrame(frameHeaders, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 0, 0, 1, 1, 71, 174, 20]

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


# test "padding"
block:
  let 
    length = 1'u32
    frameType = FrameType.Data
    flag = FlagDataPadded
    streamId = StreamId(21474836'u32)
    frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
    payload = @[1'u8]
    padding = some(Padding(8))
    dataFrame = initDataFrame(frameHeaders, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 1, 0, 8, 1, 71, 174, 20, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0]

  var str = fromByteSeq(serialize)
  let 
    strm = newStringStream(move(str))
    readed = strm.readDataFrame

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert readed.headers.flag == flag
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.get.int == 8
  doAssert readed.payload == payload
  strm.close()


# test "pad length is zero"
block:
  let 
    length = 3'u32
    frameType = FrameType.Data
    flag = FlagDataPadded
    streamId = StreamId(21474836'u32)
    frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
    payload = @[1'u8, 3, 7]
    padding = some(Padding(0))
    dataFrame = initDataFrame(frameHeaders, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 3, 0, 8, 1, 71, 174, 20, 0, 1, 3, 7]

  var str = fromByteSeq(serialize)
  let 
    strm = newStringStream(move(str))
    readed = strm.readDataFrame

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert readed.headers.flag == flag
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.get.int == 0
  doAssert readed.payload == payload
  strm.close()
