import ./flags

type
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

  Padding* = object
    padLength*: uint8
    payload*: seq[byte]

  Priority* = object
    streamId*: StreamId
    weight*: uint8
