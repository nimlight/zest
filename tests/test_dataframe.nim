discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:refc; --gc:arc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams, strformat


import ../src/zest/frame/baseframe
import ../src/zest/frame/dataframe


# test "read payload"
block:
  # have no payload
  block:
    let 
      length = 0'u32
      frameType = FrameType.Data
      flag = FlagDataEndStream
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 0, 0, 1, 1, 71, 174, 20]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    let 
      headers = strm.readFrameHeaders
      padding = strm.readPadding(frameHeaders)

    doAssert strm.readPayload(headers.length, padding) == []
    strm.close()

  # have payload of one octet
  block:
    let 
      length = 2'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 2, 0, 8, 1, 71, 174, 20, 0, 99]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    let 
      headers = strm.readFrameHeaders
      padding = strm.readPadding(frameHeaders)

    doAssert strm.readPayload(headers.length, padding) == [99'u8]
    strm.close()

  # have payload of six octets
  block:
    let 
      length = 8'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 8, 0, 8, 1, 71, 174, 20, 1, 99, 99, 99, 99, 99, 99, 0]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    let 
      headers = strm.readFrameHeaders
      padding = strm.readPadding(frameHeaders)
      data = strm.readPayload(headers.length, padding)
    
    doAssert data == [99'u8, 99, 99, 99, 99, 99], fmt"{data} != "
    strm.close()


# padding is too large
block:
  let 
    # length = 7'u32
    # frameType = FrameType.Data
    # flag = FlagDataPadded
    # streamId = StreamId(21474836'u32)
    # payload = [99'u8, 99]
    serialize = [99'u8, 99, 0, 0, 0, 0]

  var str = fromByteSeq(serialize)
  let 
    strm = newStringStream(move(str))
    headers = initFrameHeaders(7'u32, FrameType.Data, FlagDataPadded, StreamId(21474836))
  doAssertRaises(ConnectionError):
    discard DataFrame.read(headers, strm)
  strm.close()


block:
  let 
    length = 1'u32
    frameType = FrameType.Data
    streamId = StreamId(21474836'u32)
    payload = @[1'u8]
    padding = none(Padding)
    dataFrame = initDataFrame(streamId, payload, padding, true)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 1, 0, 1, 1, 71, 174, 20, 1]

  var str = fromByteSeq([1'u8])
  let 
    headers = initFrameHeaders(length, frameType, Flag(1), streamId)
    strm = newStringStream(move(str))
    readed = DataFrame.read(headers, strm)

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert not readed.isPadded
  doAssert readed.isStreamEnded
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.isNone
  doAssert readed.payload == payload
  strm.close()


# test "empty payload"
block:
  let 
    length = 0'u32
    frameType = FrameType.Data
    streamId = StreamId(21474836'u32)
    payload: seq[byte] = @[]
    padding = none(Padding)
    dataFrame = initDataFrame(streamId, payload, padding, true)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 0, 0, 1, 1, 71, 174, 20]

  var str = fromByteSeq([])
  let 
    headers = initFrameHeaders(length, frameType, Flag(1), streamId)
    strm = newStringStream(move(str))
    readed = DataFrame.read(headers, strm)

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert not readed.isPadded
  doAssert readed.isStreamEnded
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.isNone
  doAssert readed.payload == payload
  strm.close()


# test "padding"
block:
  let 
    length = 19'u32
    frameType = FrameType.Data
    streamId = StreamId(21474836'u32)
    payload = @[1'u8, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    padding = some(Padding(8))
    dataFrame = initDataFrame(streamId, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 19, 0, 8, 1, 71, 174, 20, 8, 1, 2,
                         3, 4, 5, 6, 7, 8, 9, 10, 0, 0, 0, 0, 0, 0, 0, 0],
                         fmt"{serialize} != "

  var str = fromByteSeq([8'u8, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0, 0, 0, 0, 0, 0, 0])
  let 
    headers = initFrameHeaders(length, frameType, Flag(8), streamId)
    strm = newStringStream(move(str))
    readed = DataFrame.read(headers, strm)

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert not readed.isStreamEnded
  doAssert readed.isPadded
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.get == padding.get, fmt"{readed.padding.get.int} != {padding.get.int}"
  doAssert readed.payload == payload
  strm.close()


# test "pad length is zero"
block:
  let 
    length = 5'u32
    frameType = FrameType.Data
    streamId = StreamId(21474836'u32)
    payload = @[1'u8, 3, 7, 8]
    padding = some(Padding(0))
    dataFrame = initDataFrame(streamId, payload, padding)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 5, 0, 8, 1, 71, 174, 20, 0, 1, 3, 7, 8]

  var str = fromByteSeq([0'u8, 1, 3, 7, 8])
  let 
    headers = initFrameHeaders(length, frameType, Flag(8), streamId)
    strm = newStringStream(move(str))
    readed = DataFrame.read(headers, strm)

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert readed.isPadded
  doAssert not readed.isStreamEnded
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.get == padding.get
  doAssert readed.payload == payload
  strm.close()


# test "flags contain padded and endStream"
block:
  let 
    length = 5'u32
    frameType = FrameType.Data
    streamId = StreamId(21474836'u32)
    payload = @[1'u8, 3, 7, 8]
    padding = some(Padding(0))
    dataFrame = initDataFrame(streamId, payload, padding, endStream = true)
    serialize = dataFrame.serialize

  doAssert serialize == [0'u8, 0, 5, 0, 9, 1, 71, 174, 20, 0, 1, 3, 7, 8]

  var str = fromByteSeq([0'u8, 1, 3, 7, 8])
  let 
    headers = initFrameHeaders(length, frameType, Flag(9), streamId)
    strm = newStringStream(move(str))
    readed = DataFrame.read(headers, strm)

  doAssert readed.headers.length == length, fmt"{readed.headers.length} != {length}"
  doAssert readed.headers.frameType == frameType
  doAssert readed.isPadded
  doAssert readed.isStreamEnded
  doAssert readed.headers.streamId == streamId
  doAssert readed.padding.get == padding.get
  doAssert readed.payload == payload
  strm.close()
