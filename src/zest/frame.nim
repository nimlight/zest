import options
import ./errorcodes, ./basetypes


const
  FrameMinLen* = 16384 # 2 ^ 14
  FrameMaxAllowedLen* = 16777215 # 2 ^ 24 - 1 


type
  # +-----------------------------------------------+ |
  # Length (24) | Flags (8) | |
  # +---------------+---------------+---------------+ | Type (8)
  # +-+-------------+---------------+-------------------------------+ |R|
  # Stream Identifier (31) Frame Payload (0...) |
  # +=+=============================================================+ |
  # ..
  # +---------------------------------------------------------------+
  # https://tools.ietf.org/html/rfc7540#section-4
  Frame* = object of RootObj
    headers*: Headers
    payload*: seq[byte]

  DataFrame* = object of Frame
    padding*: Option[Padding]

  HeadersFrame* = object of Frame
    padding*: Option[Padding]
    priority*: Option[Priority]
    headerBlockFragment*: seq[byte]

  PriorityFrame* = object of Frame
    priority*: Option[Priority]

  RstStream* = object of Frame
    errorCode: ErrorCode

  SettingsFrame* = object of Frame
    settings: Settings
    size: uint32
  
  PushPromiseFrame* = object of Frame
    padding*: Option[Padding]
    promisedStreamID*: StreamId
    headerBlockFragment*: seq[byte]

  PingFrame* = object of Frame
    opaqueData*: uint64

  GoAwayFrame* = object of Frame
    lastStreamId*: StreamId
    errorCode*: ErrorCode
    debugData*: seq[byte]

  WindowUpdateFrame* = object of Frame
    windowSizeIncrement*: uint32

  ContinuationFrame* = object of Frame
    headerBlockFragment*: seq[byte]
