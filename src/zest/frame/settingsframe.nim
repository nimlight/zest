import ./baseframe


type
  # +-------------------------------+
  # |       Identifier (16)         |
  # +-------------------------------+-------------------------------+
  # |                        Value (32)                             |
  # +---------------------------------------------------------------+

  SettingsFrame* = object of Frame
    ## The SETTINGS frame (type=0x4) conveys configuration parameters that
    ## affect how endpoints communicate, such as preferences and constraints
    ## on peer behavior.
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
  var length = 0'u32

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

  if length != 0 and flag.isAck:
    raise newException(ValueError, "Settings must be empty if ACK flag is set.")

  let headers = initFrameHeaders(length = length, frameType = FrameType.Settings,
                                 flag = flag, streamId = streamId)


  result = SettingsFrame(headers: headers, headerTableSize: headerTableSize,
                         enablePush: enablePush, maxConcurrentStreams: maxConcurrentStreams,
                         initialWindowSize: initialWindowSize, maxFrameSize: maxFrameSize,
                         maxHeaderListSize: maxHeaderListSize)

proc serialize*(frame: SettingsFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the SettingsFrame.

  result = newSeqOfCap[byte](9 + frame.headers.length)

  if frame.headerTableSize.isSome:
    result.add Settings.HeaderTableSize.uint16.serialize
    result.add frame.headerTableSize.get.serialize

  if frame.enablePush.isSome:
    result.add Settings.EnablePush.uint16.serialize
    result.add frame.enablePush.get.serialize

  if frame.maxConcurrentStreams.isSome:
    result.add Settings.MaxConcurrentStreams.uint16.serialize
    result.add frame.maxConcurrentStreams.get.serialize

  if frame.initialWindowSize.isSome:
    result.add Settings.InitialWindowSize.uint16.serialize
    result.add frame.initialWindowSize.get.serialize

  if frame.maxFrameSize.isSome:
    result.add Settings.MaxFrameSize.uint16.serialize
    result.add frame.maxFrameSize.get.serialize
  
  if frame.maxHeaderListSize.isSome:
    result.add Settings.MaxHeaderListSize.uint16.serialize
    result.add frame.maxHeaderListSize.get.serialize

proc readSettingsFrame*(stream: StringStream): SettingsFrame {.inline.} =
  ## Reads the fields of the SettingsFrame.
  
  # read frame header
  result.headers = stream.readFrameHeaders
