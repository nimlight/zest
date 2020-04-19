import ./baseframe


type
  # +-------------------------------+
  # |       Identifier (16)         |
  # +-------------------------------+-------------------------------+
  # |                        Value (32)                             |
  # +---------------------------------------------------------------+
  SettingsFrame* = object of Frame
    headerTableSize*: Option[uint32]
    enablePush*: Option[uint32]
    maxConcurrentStreams*: Option[uint32]
    initialWindowSize*: Option[uint32]
    maxFrameSize*: Option[uint32]
    maxHeaderListSize*: Option[uint32]


proc isAck*(flag: Flag): bool {.inline.} =
  # Whether contains ack flag.
  flag.contains(FlagSettingsAck)

proc initSettingsFrame*(streamId: StreamId, flag: Flag, headerTableSize = none(uint32),
                        enablePush = none(uint32), maxConcurrentStreams = none(uint32),
                        initialWindowSize = none(uint32), maxFrameSize = none(uint32),
                        maxHeaderListSize = none(uint32)): SettingsFrame =
  ## Initiates SettingsFrame.
  var length = 9'u32

  if headerTableSize.isSome:
    inc(length, 6)

  if enablePush.isSome:
    inc(length, 6)

  if maxConcurrentStreams.isSome:
    inc(length, 6)

  if initialWindowSize.isSome:
    inc(length, 6)

  if maxFrameSize.isSome:
    inc(length, 6)
  
  if maxHeaderListSize.isSome:
    inc(length, 6)

  if length != 9 and flag.isAck:
    raise newException(ValueError, "Settings must be empty if ACK flag is set.")

  let headers = initFrameHeaders(length = length, frameType = FrameType.Settings,
                                 flag = flag, streamId = streamId)


  result = SettingsFrame(headers: headers, headerTableSize: headerTableSize,
                         enablePush: enablePush, maxConcurrentStreams: maxConcurrentStreams,
                         initialWindowSize: initialWindowSize, maxFrameSize: maxFrameSize,
                         maxHeaderListSize: maxHeaderListSize)
