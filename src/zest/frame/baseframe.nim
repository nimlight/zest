import options, streams
import ./errorcodes, ./flags, ./basetypes

export errorcodes, flags, basetypes, options, streams

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
    payload*: seq[byte]


# Pad length can be zero or None.
# If zero, a frame will include pad length field(increased in size by one octet),
# else won't have this field.
proc readPadding*(stream: StringStream, headers: FrameHeaders): Option[Padding] =
  ## Reads pad length.
  result = none(Padding)
  if headers.flag == FlagDataPadded:
    if canReadNBytes(stream, 1):
      let data = stream.readUint8
      if data != 0 and data >= headers.length:
        raise newConnectionError(errorCode = ErrorCode.Protocol, msg = "Padding is too large!")
      result = some(data.Padding)

proc readPayload*(stream: StringStream, headers: FrameHeaders): seq[byte] =
  ## Reads padding.
  let length = headers.length.int
  if canReadNBytes(stream, length):
    if length > 0:
      result = newSeq[byte](length)
      discard stream.readData(result[0].addr, length)
