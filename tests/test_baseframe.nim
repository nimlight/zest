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


# test "read padding"
block:
  # have no padding
  block:
    let 
      length = 0'u32
      frameType = FrameType.Data
      flag = FlagEndStream
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 1, 0, 1, 1, 71, 174, 20]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    discard strm.readFrameHeaders
    let
      readed = strm.readPadding(frameHeaders)

    doAssert readed.isNone
    strm.close()

  # have no padding
  block:
    let 
      length = 1'u32
      frameType = FrameType.Data
      flag = FlagEndStream
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 1, 0, 1, 1, 71, 174, 20, 1]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    discard strm.readFrameHeaders
    let
      readed = strm.readPadding(frameHeaders)

    doAssert readed.isNone
    strm.close()

  # have padding of zero octet
  block:
    let 
      length = 1'u32
      frameType = FrameType.Data
      flag = FlagPadded
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 1, 0, 8, 1, 71, 174, 20, 0, 1]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    discard strm.readFrameHeaders
    let
      readed = strm.readPadding(frameHeaders)

    doAssert readed.get == Padding(0)
    strm.close()

  # have padding of one octet
  block:
    let 
      length = 2'u32
      frameType = FrameType.Data
      flag = FlagPadded
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 2, 0, 8, 1, 71, 174, 20, 1, 99, 99, 0]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    discard strm.readFrameHeaders
    let
      readed = strm.readPadding(frameHeaders)

    doAssert readed.get == Padding(1)
    strm.close()

  # have padding of six octets
  block:
    let 
      length = 7'u32
      frameType = FrameType.Data
      flag = FlagPadded
      streamId = StreamId(21474836'u32)
      frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
      serialize = [0'u8, 0, 7, 0, 8, 1, 71, 174, 20, 6, 99, 99, 99, 
                   99, 99, 99, 99, 0, 0, 0, 0, 0, 0]

    var str = fromByteSeq(serialize)
    let 
      strm = newStringStream(move(str))

    # frameheaders of nine octets
    discard strm.readFrameHeaders
    let
      readed = strm.readPadding(frameHeaders)

    doAssert readed.get == Padding(6)
    strm.close()
