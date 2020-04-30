import streams, bitops


import ../base/flags, ../base/bytes, ../base/errorcodes


export flags, bytes


type
  FrameError* = ref object of CatchableError
  ConnectionError* = ref object of CatchableError
    errorCode: ErrorCode

  StreamError* = ref object of CatchableError
    errorCode: ErrorCode

  StreamId* = distinct uint32

  FrameType* {.pure.} = enum
    Data = 0'u8
    Headers = 1'u8
    Priority = 2'u8
    RstStream = 3'u8
    Settings = 4'u8
    PushPromise = 5'u8
    Ping = 6'u8
    GoAway = 7'u8
    WindowUpdate = 8'u8
    Continuation = 9'u8

  Settings* {.pure.} = enum
    HeaderTableSize = 1'u16
    EnablePush = 2'u16
    MaxConcurrentStreams = 3'u16
    InitialWindowSize = 4'u16
    MaxFrameSize = 5'u16
    MaxHeaderListSize = 6'u16


  # +-----------------------------------------------+
  # |                 Length (24)                   |
  # +---------------+---------------+---------------+
  # |   Type (8)    |   Flags (8)   |
  # +-+-------------+---------------+-------------------------------+
  # |R|                 Stream Identifier (31)                      |
  # +=+=============================================================+
  # https://tools.ietf.org/html/rfc7540#section-4

  FrameHeaders* = object ## All frames begin with a fixed 9-octet headers.
    length: uint32 # 2 ^ 14 ~ 2 ^ 24 - 1
    frameType: FrameType
    flag: Flag
    streamId: StreamId

  # Padding octets that contain no application semantic value.
  # Padding octets MUST be set to zero when sending. A receiver is
  # not obligated to verify padding but MAY treat non-zero padding as
  # a connection error of type PROTOCOL_ERROR.
  Padding* = distinct uint8 ## Padding is present if the PADDED flag is set.

  # The weight of the stream is always in the range [0, 255], 
  # Add one to the value to obtain a weight between 1 and 256.
  # So that the value fits into a ``uint8`` .
  Priority* = object
    streamId*: StreamId ## The dependency stream id.
    weight*: uint8      ## The weight for the stream. 
    exclusive*: bool    ## True if the stream dependency is exclusive(value = 1).


proc `==`*(self, other: StreamId): bool {.borrow.}
proc serialize*(streamId: StreamId): array[4, byte] {.borrow.}
proc `==`*(self, other: Padding): bool {.borrow.}


proc `length`*(headers: FrameHeaders): uint32 {.inline.} =
  headers.length

proc `frameType`*(headers: FrameHeaders): FrameType {.inline.} =
  headers.frameType

proc `flag`*(headers: FrameHeaders): Flag {.inline.} =
  headers.flag

proc `streamId`*(headers: FrameHeaders): StreamId {.inline.} =
  headers.streamId

proc newConnectionError*(errorCode: ErrorCode, msg: string): ConnectionError {.inline.} =
  ## Creates a ConnectionError.
  ConnectionError(errorCode: errorCode, msg: msg)

proc newStreamError*(errorCode: ErrorCode, msg: string): StreamError {.inline.} =
  ## Creates a StreamError.
  StreamError(errorCode: errorCode, msg: msg)

proc initPriority*(streamId: StreamId, weight: uint8, exclusive: bool): Priority {.inline.} =
  ## Initiates a Priority.
  Priority(streamId: streamId, weight: weight, exclusive: exclusive)

proc initFrameHeaders*(length: uint32, frameType: FrameType, 
                       flag: Flag, streamId: StreamId): FrameHeaders {.inline.} =
  ## Initiates a FrameHeaders.
  FrameHeaders(length: length, frameType: frameType, flag: flag, streamId: streamId)

proc serialize*(headers: FrameHeaders): seq[byte] =
  ## Serializes the fields of the frame header.
  result = newSeqUninitialized[byte](9)
  result[0] = byte(headers.length shr 16)
  result[1] = byte(headers.length shr 8)
  result[2] = byte(headers.length)
  result[3] = byte(headers.frameType)
  result[4] = byte(headers.flag)
  var streamId = uint32(headers.streamId)
  streamId.clearBit(31)
  result[5 .. 8] = serialize(streamId)

# big endian
proc readFrameHeaders*(stream: StringStream): FrameHeaders =
  ## Reads the fields of the frame header.

  # read 9 bytes
  if not canReadNBytes(stream, 9):
    raise newStreamError(ErrorCode.FrameSize, "The length of FrameHeaders frame must be more than 9 octets.")

  # read length
  # 24-bit 0000 00
  result.length = uint32(stream.readBEUint16) shl 8'u32 + uint32(stream.readUint8)
  
  # read frame type
  let frameType = stream.readUint8
  if frameType >= 10'u8:
    raise newStreamError(ErrorCode.Protocol, "Unknown frame.")
  else:
    result.frameType = FrameType(frameType)

  # read flag
  result.flag = Flag(stream.readUint8)

  # read streamId
  var streamId = stream.readBEUint32
  streamId.clearBit(31)
  result.streamId = StreamId(streamId)
