discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; --gc:refc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams, strformat


import ../src/zest/frame/basetypes


# test "frame headers"
block:
  let 
    length = 16777215'u32
    frameType = FrameType.Data
    flag = FlagDataPadded
    streamId = StreamId(21474836'u32)
  let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

  var serialize = frameHeaders.serialize
  doAssert serialize == @[255'u8, 255, 255, 0, 8, 1, 71, 174, 20]

  var str = "\xFF\xFF\xFF\x00\x08\x01\x47\xAE\x14"
  let 
    strm = newStringStream(move(str))
    readed = strm.readFrameHeaders
  doAssert readed.length == length
  doAssert readed.frameType == frameType
  doAssert readed.flag == flag
  doAssert readed.streamId == streamId
  strm.close()

# test "length"
block:
  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 0'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[0'u8, 0, 0, 0, 8, 0, 0, 0, 1]

    var str = "\x00\x00\x00\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 257'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[0'u8, 1, 1, 0, 8, 0, 0, 0, 1]

    var str = "\x00\x01\x01\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 233'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[0'u8, 0, 233, 0, 8, 0, 0, 0, 1]

    var str = "\x00\x00\xE9\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

# test "frameType"
block:
  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Headers
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 1, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x01\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.PushPromise
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 5, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x05\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Unknown
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 10, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x0A\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

# test "flag"
block:
  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Data
      flag = FlagDataEndStream
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 0, 1, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x00\x01\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Headers
      flag = FlagHeadersEndStream
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 1, 1, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x01\x01\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Headers
      flag = FlagHeadersEndHeaders
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 1, 4, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x01\x04\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Headers
      flag = FlagHeadersPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 1, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x01\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Headers
      flag = FlagHeadersPriority
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 1, 32, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x01\x20\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = high(uint32) shr 8'u32
      frameType = FrameType.Data
      flag = Flag(0)
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    
    doAssert serialize == @[255'u8, 255, 255, 0, 0, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x00\x00\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    
    doAssert readed.length == length, fmt"{readed.length} != {length}"
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

# test streamId
block:
  block:
    let 
      length = 16777215'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(0'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 0, 0, 0, 0]

    var str = "\xFF\xFF\xFF\x00\x08\x00\x00\x00\x00"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    doAssert readed.length == length
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 16777215'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(1'u32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 0, 0, 0, 1]

    var str = "\xFF\xFF\xFF\x00\x08\x00\x00\x00\x01"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    doAssert readed.length == length
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 16777215'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = StreamId(high(uint32) shr 1)
    let frameHeaders = initFrameHeaders(length, frameType, flag, streamId)

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 127, 255, 255, 255]

    var str = "\xFF\xFF\xFF\x00\x08\x7F\xFF\xFF\xFF"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    doAssert readed.length == length
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == streamId
    strm.close()

  block:
    let 
      length = 16777215'u32
      frameType = FrameType.Data
      flag = FlagDataPadded
      streamId = high(uint32)
    let frameHeaders = initFrameHeaders(length, frameType, flag, StreamId(streamId))

    var serialize = frameHeaders.serialize
    doAssert serialize == @[255'u8, 255, 255, 0, 8, 127, 255, 255, 255]

    var str = "\xFF\xFF\xFF\x00\x08\x7F\xFF\xFF\xFF"
    let 
      strm = newStringStream(move(str))
      readed = strm.readFrameHeaders
    doAssert readed.length == length
    doAssert readed.frameType == frameType
    doAssert readed.flag == flag
    doAssert readed.streamId == StreamId(streamId shr 1'u32)
    strm.close()
