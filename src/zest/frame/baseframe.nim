import options, streams, bitops
import ./errorcodes, ./flags, ./basetypes

export errorcodes, flags, basetypes, options, streams, bitops

const
  FrameDefaultMaxLen* = 16384 # 2 ^ 14
  FrameAllowedMaxLen* = 16777215 # 2 ^ 24 - 1 


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
  Frame* = object of RootObj
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


proc readPriority*(stream: StringStream, headers: FrameHeaders): Option[Priority] {.inline.} =
  ## Reads priority
  result = none(Priority)
  case headers.frameType
  of FrameType.Headers:
    if headers.flag.contains(FlagHeadersPriority) and canReadNBytes(stream, 5):
      var 
        priority: Priority
        streamId = stream.readUint32
      priority.exclusive = streamId.testBit(31)
      streamId.clearBit(31)
      priority.streamId = StreamId(streamId)
      priority.weight = stream.readUint8
      result = some(priority)
  else:
    raise FrameError(msg: "Frames shouldn't have priority.")
