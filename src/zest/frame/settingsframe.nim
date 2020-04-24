import ./baseframe
import ./constants


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
    headerTableSize: Option[uint32]
    enablePush: Option[bool]
    maxConcurrentStreams: Option[uint32]
    initialWindowSize: Option[uint32]
    maxFrameSize: Option[uint32]
    maxHeaderListSize: Option[uint32]


proc `headerTableSize`*(frame: SettingsFrame): Option[uint32] {.inline.} =
  frame.headerTableSize

proc `enablePush`*(frame: SettingsFrame): Option[bool] {.inline.} =
  frame.enablePush

proc `maxConcurrentStreams`*(frame: SettingsFrame): Option[uint32] {.inline.} =
  frame.maxConcurrentStreams

proc `initialWindowSize`*(frame: SettingsFrame): Option[uint32] {.inline.} =
  frame.initialWindowSize

proc `maxFrameSize`*(frame: SettingsFrame): Option[uint32] {.inline.} =
  frame.maxFrameSize

proc `maxHeaderListSize`*(frame: SettingsFrame): Option[uint32] {.inline.} =
  frame.maxHeaderListSize

proc isAck*(flag: Flag): bool {.inline.} =
  # Whether contains ack flag.
  flag.contains(FlagSettingsAck)


proc initSettingsFrame*(hasAckFlag: bool = false, headerTableSize = some(4096'u32),
                        enablePush = some(true), maxConcurrentStreams = none(uint32),
                        initialWindowSize = some(65_535'u32), maxFrameSize = some(16_384'u32),
                        maxHeaderListSize = none(uint32)): SettingsFrame =
  ## Initiates SettingsFrame.
  
  if hasAckFlag:
    let headers = initFrameHeaders(length = 0'u32, frameType = FrameType.Settings,
                                  flag = FlagSettingsAck, streamId = StreamId(0))
    return SettingsFrame(headers: headers)

  var length = 0'u32

  if headerTableSize.isSome:
    inc(length, 6)

  if enablePush.isSome:
    inc(length, 6)

  if maxConcurrentStreams.isSome:
    inc(length, 6)

  if initialWindowSize.isSome:
    if initialWindowSize.get.int > MaxInitialWindowSize:
      raise newException(ValueError, "Values is above the maximum flow-control window size.")

    inc(length, 6)

  if maxFrameSize.isSome:
    let size = maxFrameSize.get.int
    if size < MaxDefaultFrameSize or size > MaxAllowedFrameSize:
      raise newException(ValueError, "Size must be between default and allowed frame size.")
    inc(length, 6)
  
  if maxHeaderListSize.isSome:
    inc(length, 6)

  let headers = initFrameHeaders(length = length, frameType = FrameType.Settings,
                                 flag = Flag(0), streamId = StreamId(0))

  result = SettingsFrame(headers: headers, headerTableSize: headerTableSize,
                         enablePush: enablePush, maxConcurrentStreams: maxConcurrentStreams,
                         initialWindowSize: initialWindowSize, maxFrameSize: maxFrameSize,
                         maxHeaderListSize: maxHeaderListSize)

proc serialize*(frame: SettingsFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the SettingsFrame.

  result = newSeqOfCap[byte](9 + frame.headers.length.int)

  # serialize frameHeaders.
  result.add frame.headers.serialize

  if frame.headerTableSize.isSome:
    result.add Settings.HeaderTableSize.uint16.serialize
    result.add frame.headerTableSize.get.serialize

  if frame.enablePush.isSome:
    result.add Settings.EnablePush.uint16.serialize
    result.add frame.enablePush.get.uint32.serialize

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

proc read*(self: type[SettingsFrame], headers: FrameHeaders, stream: StringStream): SettingsFrame {.inline.} =
  ## Reads the fields of the SettingsFrame.
  
  assert headers.frameType == FrameType.Settings, "FrameType must be SettingsStream."

  # read frame header
  result.headers = headers

  # SETTINGS frames always apply to a connection, never a single stream.
  # The stream identifier for a SETTINGS frame MUST be zero (0x0).  If an
  # endpoint receives a SETTINGS frame whose stream identifier field is
  # anything other than 0x0, the endpoint MUST respond with a connection
  # error (Section 5.4.1) of type PROTOCOL_ERROR.
  if result.headers.streamId != StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, 
                             "The stream identifier for a SETTINGS frame MUST be zero (0x0).")

  # When this bit is set, the payload of the SETTINGS frame MUST be empty.
  # Receipt of a SETTINGS frame with the ACK flag set and a length
  # field value other than 0 MUST be treated as a connection error
  # (Section 5.4.1) of type FRAME_SIZE_ERROR.
  if result.headers.flag.isAck:
    if result.headers.length != 0:
      raise newConnectionError(ErrorCode.FrameSize, "Settings must be empty if ACK flag is set.")
    else:
      # return default Settings with ack flag
      return

  # A SETTINGS frame with a length other than a multiple of 6 octets MUST
  # be treated as a connection error (Section 5.4.1) of type
  # FRAME_SIZE_ERROR.
  if result.headers.length mod 6 != 0:
    raise newConnectionError(ErrorCode.FrameSize, 
                             "The length of A SETTINGS frame must be a multiple of 6 octets.")

  # The SETTINGS frame affects connection state.  A badly formed or
  # incomplete SETTINGS frame MUST be treated as a connection error
  # (Section 5.4.1) of type PROTOCOL_ERROR.
  if not canReadNBytes(stream, result.headers.length.int):
    raise newConnectionError(ErrorCode.Protocol, "Incomplete SETTINGS frame")
  
  let size = result.headers.length div 6
  for i in 0 ..< size:
    let
      settingsId = stream.readBEUint16
      settingsValue = stream.readBEUint32
    
    case settingsId
    of 1'u16:
      result.headerTableSize = some(settingsValue)
    of 2'u16:
      case settingsValue
      of 0'u32:
        result.enablePush = some(false)
      of 1'u32:
        result.enablePush = some(true)
      else:
        raise newConnectionError(ErrorCode.Protocol, "EnablePush must be 0 or 1.")
    of 3'u16:
      result.maxConcurrentStreams = some(settingsValue)
    of 4'u16:
      # Values above the maximum flow-control window size of 2^31-1 MUST
      # be treated as a connection error (Section 5.4.1) of type
      # FLOW_CONTROL_ERROR.
      if settingsValue.int > MaxInitialWindowSize:
        raise newConnectionError(ErrorCode.FlowControl, 
                                 "Values is above the maximum flow-control window size.")
      else:
        result.initialWindowSize = some(settingsValue)
    of 5'u16:
      if settingsValue.int < MaxDefaultFrameSize or settingsValue.int > MaxAllowedFrameSize:
        raise newConnectionError(ErrorCode.Protocol, "Size must be between default and allowed frame size.")
      else:
        result.maxFrameSize = some(settingsValue)
    of 6'u16:
      result.maxHeaderListSize = some(settingsValue)
    else:
      discard
