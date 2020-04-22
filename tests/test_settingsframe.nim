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
import ../src/zest/frame/settingsframe


import ./utils

# settingsFrame
block:
  # settings with ack
  block:
    let
      settingsFrame = initSettingsFrame(hasAckFlag = true)
      headers = settingsFrame.headers

    doAssert settingsFrame.headers.flag.isAck
    doAssert settingsFrame.headers.length == 0'u32
    doAssert settingsFrame.headers.streamId == StreamId(0) 
    doAssert settingsFrame.headers.frameType == FrameType.Settings
    doAssert settingsFrame.headerTableSize.isNone
    doAssert settingsFrame.enablePush.isNone
    doAssert settingsFrame.maxConcurrentStreams.isNone
    doAssert settingsFrame.initialWindowSize.isNone
    doAssert settingsFrame.maxFrameSize.isNone
    doAssert settingsFrame.maxHeaderListSize.isNone
    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  # settings with ack and payload is not zero
  block:
    let headers = [0'u8, 0, 6, 4, 1, 0, 0, 0, 0].fromByteSeq.newStringStream.readFrameHeaders
    doAssertRaises(ConnectionError):
      discard SettingsFrame.read(headers, @[0'u8, 1, 0, 0, 24, 10].fromByteSeq.newStringStream)

  # The length of A SETTINGS frame must be a multiple of 6 octets.
  block:
    let headers = [0'u8, 0, 7, 4, 0, 0, 0, 0, 0].fromByteSeq.newStringStream.readFrameHeaders
    doAssertRaises(ConnectionError):
      discard SettingsFrame.read(headers, @[0'u8, 1, 0, 0, 24, 10, 3].fromByteSeq.newStringStream)

  # Incomplete SETTINGS frame
  block:
    let headers = [0'u8, 0, 6, 4, 0, 0, 0, 0, 0].fromByteSeq.newStringStream.readFrameHeaders
    doAssertRaises(ConnectionError):
      discard SettingsFrame.read(headers, @[0'u8, 1, 0, 0, 24].fromByteSeq.newStringStream)

  #stream id is not zero
  block:
    let headers = @[0'u8, 0, 0, 4, 0, 0, 0, 0, 0].fromByteSeq.newStringStream.readFrameHeaders
    discard SettingsFrame.read(headers, [].fromByteSeq.newStringStream)

  block:
    let headers = @[0'u8, 0, 0, 4, 0, 0, 0, 0, 1].fromByteSeq.newStringStream.readFrameHeaders
    doAssertRaises(ConnectionError):
      discard SettingsFrame.read(headers, [].fromByteSeq.newStringStream)

  # settings with no ack and default settings
  block:
    let
      settingsFrame = initSettingsFrame(hasAckFlag = false)
      headers = settingsFrame.headers

    doAssert not settingsFrame.headers.flag.isAck
    doAssert settingsFrame.headers.length == 24'u32
    doAssert settingsFrame.headers.streamId == StreamId(0) 
    doAssert settingsFrame.headers.frameType == FrameType.Settings
    doAssert settingsFrame.headerTableSize.isSome
    doAssert settingsFrame.enablePush.isSome
    doAssert settingsFrame.maxConcurrentStreams.isNone
    doAssert settingsFrame.initialWindowSize.isSome
    doAssert settingsFrame.maxFrameSize.isSome
    doAssert settingsFrame.maxHeaderListSize.isNone
    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


block:
  block:
    doAssertRaises(ValueError):
      discard initSettingsFrame(hasAckFlag = false, initialWindowSize = some(2147483648'u32))

    doAssertRaises(ValueError):
      discard initSettingsFrame(hasAckFlag = false, maxFrameSize = some(21'u32))

    doAssertRaises(ValueError):
      discard initSettingsFrame(hasAckFlag = false, maxFrameSize = some(16777216'u32))

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = false, none(uint32), none(bool), 
                      none(uint32), none(uint32), none(uint32), none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


# headerTableSize
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, headerTableSize = none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, headerTableSize = some(0'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, headerTableSize = some(1'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, headerTableSize = some(666'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, headerTableSize = some(high(uint32)))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

# enablePush
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, enablePush = none(bool))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, enablePush = some(false))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, enablePush = some(true))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


# maxConcurrentStreams
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxConcurrentStreams = none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxConcurrentStreams = some(0'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxConcurrentStreams = some(1'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxConcurrentStreams = some(106'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxConcurrentStreams = some(high(uint32)))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


# initialWindowSize
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, initialWindowSize = none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, initialWindowSize = some(22345'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, initialWindowSize = some(2147483647'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


# maxFrameSize
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxFrameSize = none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxFrameSize = some(17000'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxFrameSize = some(16777214'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame


# maxHeaderListSize
block:
  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxHeaderListSize = none(uint32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxHeaderListSize = some(0'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxHeaderListSize = some(1'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxHeaderListSize = some(666'u32))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame

  block:
    let 
      settingsFrame = initSettingsFrame(hasAckFlag = true, maxHeaderListSize = some(high(uint32)))
      headers = settingsFrame.headers

    doAssert SettingsFrame.read(headers, settingsFrame.serialize[9 .. ^1]
                                                      .fromByteSeq.newStringStream) == settingsFrame
