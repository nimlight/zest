import ./flags, ./bytes

type
  FrameError* = object of CatchableError
  InvalidPaddingError* = object of FrameError
  UnknownFrameError* = object of FrameError
  InvalidFrameError* = object of FrameError

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
    Unknown = 7'u16

  # All frames begin with a fixed 9-octet headers
  Headers* = object
    length*: uint32 # 2 ^ 14 ~ 2 ^ 24 - 1
    frameType*: FrameType
    flag*: Flag
    streamId*: StreamId

  # Padding is present if the PADDED flag is set.
  Padding* = object
    length*: uint8
    payload*: seq[byte]

  Priority* = object
    streamId*: StreamId
    weight*: uint8
    exclusive*: bool

proc serialize*(headers: Headers): seq[byte] =
  result = newSeqUninitialized[byte](9)
  result[0] = byte(headers.length shr 16)
  result[1] = byte(headers.length shr 8)
  result[2] = byte(headers.length)
  result[3] = byte(headers.frameType)
  result[4] = byte(headers.flag)
  result[5 .. 8] = serialize(uint32(headers.streamId))
