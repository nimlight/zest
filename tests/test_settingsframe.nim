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
      settingsFrame = initSettingsFrame()

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
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  # settings with ack and payload is not zero
  block:
    doAssertRaises(ValueError):
      discard initSettingsFrame(flag = FlagSettingsAck)

    doAssertRaises(ConnectionError):
      discard @[0'u8, 0, 6, 4, 1, 0, 0, 0, 0, 0, 1, 0, 0, 24, 10].fromByteSeq.newStringStream.readSettingsFrame

  # The length of A SETTINGS frame must be a multiple of 6 octets.
  block:
    doAssertRaises(ConnectionError):
      discard @[0'u8, 0, 7, 4, 0, 0, 0, 0, 0, 0, 1, 0, 0, 24, 10, 3].fromByteSeq.newStringStream.readSettingsFrame

  # Incomplete SETTINGS frame
  block:
    doAssertRaises(ConnectionError):
      discard @[0'u8, 0, 6, 4, 0, 0, 0, 0, 0, 0, 1, 0, 0, 24].fromByteSeq.newStringStream.readSettingsFrame

  #stream id is not zero
  block:
    discard @[0'u8, 0, 0, 4, 0, 0, 0, 0, 0].fromByteSeq.newStringStream.readSettingsFrame
    doAssertRaises(ConnectionError):
      discard @[0'u8, 0, 0, 4, 0, 0, 0, 0, 1].fromByteSeq.newStringStream.readSettingsFrame

  # settings with no ack and default settings
  block:
    let
      settingsFrame = initSettingsFrame(flag = Flag(0))

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
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


block:
  block:
    doAssertRaises(ValueError):
      discard initSettingsFrame(Flag(0), initialWindowSize = some(2147483648'u32))

    doAssertRaises(ValueError):
      discard initSettingsFrame(Flag(0), maxFrameSize = some(21'u32))

    doAssertRaises(ValueError):
      discard initSettingsFrame(Flag(0), maxFrameSize = some(16777216'u32))

  block:
    let settingsFrame = initSettingsFrame(Flag(0), none(uint32), none(bool), 
                      none(uint32), none(uint32), none(uint32), none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


# headerTableSize
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), headerTableSize = none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), headerTableSize = some(0'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), headerTableSize = some(1'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), headerTableSize = some(666'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), headerTableSize = some(high(uint32)))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

# enablePush
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), enablePush = none(bool))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), enablePush = some(false))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), enablePush = some(true))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


# maxConcurrentStreams
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxConcurrentStreams = none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxConcurrentStreams = some(0'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxConcurrentStreams = some(1'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxConcurrentStreams = some(106'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxConcurrentStreams = some(high(uint32)))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


# initialWindowSize
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), initialWindowSize = none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), initialWindowSize = some(22345'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), initialWindowSize = some(2147483647'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


# maxFrameSize
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxFrameSize = none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxFrameSize = some(17000'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxFrameSize = some(16777214'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame


# maxHeaderListSize
block:
  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxHeaderListSize = none(uint32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxHeaderListSize = some(0'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxHeaderListSize = some(1'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxHeaderListSize = some(666'u32))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame

  block:
    let settingsFrame = initSettingsFrame(Flag(0), maxHeaderListSize = some(high(uint32)))
    doAssert settingsFrame.serialize.fromByteSeq.newStringStream.readSettingsFrame == settingsFrame
