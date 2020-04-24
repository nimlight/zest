import options, streams, bitops
import ./errorcodes, ./flags, ./basetypes


export errorcodes, flags, basetypes, options, streams, bitops


type
  # +-----------------------------------------------+
  # |                 Length (24)                   |
  # +---------------+---------------+---------------+
  # |   Type (8)    |   Flags (8)   |
  # +-+-------------+---------------+-------------------------------+
  # |R|                 Stream Identifier (31)                      |
  # +=+=============================================================+
  # |                   Frame Payload (0...)                      ...
  # +---------------------------------------------------------------+
  # https://tools.ietf.org/html/rfc7540#section-4
  Frame* = object of RootObj ## The base object of all frames
    headers*: FrameHeaders


# Pad length can be zero or None.
# If zero, a frame will include pad length field(increased in size by one octet),
# else won't have this field.
proc readPadding*(stream: StringStream, headers: FrameHeaders): Option[Padding] {.inline.} =
  ## Reads pad length.
  result = none(Padding)
  case headers.frameType
  of FrameType.Data:
    if headers.flag.contains(FlagDataPadded) and canReadNBytes(stream, 1):
      result = some(stream.readUint8.Padding)
  of FrameType.Headers:
    if headers.flag.contains(FlagHeadersPadded) and canReadNBytes(stream, 1):
      result = some(stream.readUint8.Padding)
  of FrameType.PushPromise:
    if headers.flag.contains(FlagPushPromisePadded) and canReadNBytes(stream, 1):
      result = some(stream.readUint8.Padding)
  else:
    raise FrameError(msg: "Frames shouldn't have padding.")

template readPriorityInternal(stream: StringStream, headers: FrameHeaders): Option[Priority] =
  var 
    priority: Priority
    streamId = stream.readBEUint32
  priority.exclusive = streamId.testBit(31)
  streamId.clearBit(31)
  priority.streamId = StreamId(streamId)

  # A stream cannot depend on itself.  An endpoint MUST treat this as a
  # stream error (Section 5.4.2) of type PROTOCOL_ERROR.
  if priority.streamId == headers.streamId:
    raise newStreamError(ErrorCode.Protocol, "A stream cannot depend on itself.")

  priority.weight = stream.readUint8
  some(priority)

proc readPriority*(stream: StringStream, headers: FrameHeaders): Option[Priority] {.inline.} =
  ## Reads priority.
  result = none(Priority)
  case headers.frameType
  of FrameType.Headers:
    if headers.flag.contains(FlagHeadersPriority) and canReadNBytes(stream, 5):
      result = stream.readPriorityInternal(headers)
  of FrameType.Priority:
    if canReadNBytes(stream, 5):
      result = stream.readPriorityInternal(headers)
  else:
    raise FrameError(msg: "Frames shouldn't have priority.")

proc readErrorCode*(stream: StringStream): ErrorCode {.inline.} =
  # Reads frame ErrorCode.

  let errorCode = stream.readBEUint32

  if errorCode >= 14'u32:
    raise newStreamError(ErrorCode.Protocol, "Unknown ErrorCode.")
  else:
    result = ErrorCode(errorCode)
