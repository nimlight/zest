import ./baseframe


type
  # +---------------------------------------------------------------+
  # |                                                               |
  # |                      Opaque Data (64)                         |
  # |                                                               |
  # +---------------------------------------------------------------+
  PingFrame* = object of Frame
    opaqueData: uint64


proc `opaqueData`*(frame: PingFrame): uint64 {.inline.} =
  frame.opaqueData

proc initPingFrame*(hasAckFlag: bool, opaqueData: uint64): PingFrame {.inline.} =
  ## Initiates PingFrame.
  let flag = if hasAckFlag: FlagPingAck
    else: Flag(0)

  let headers = initFrameHeaders(length = 8'u32, frameType = FrameType.Ping, 
                                 flag = flag, streamId = StreamId(0))
  PingFrame(headers: headers, opaqueData: opaqueData)

proc serialize*(frame: PingFrame): seq[byte] {.inline.} =
  ## Serializes PingFrame.
  result = newSeqofCap[byte](9 + 8)
  result.add frame.headers.serialize
  result.add frame.opaqueData.serialize

proc read*(self: type[PingFrame], headers: FrameHeaders, stream: StringStream): PingFrame {.inline.} =
  ## Reads PingFrame.
  
  assert headers.frameType == FrameType.Ping, "FrameType must be Ping."

  result.headers = headers

  # PING frames are not associated with any individual stream.  If a PING
  # frame is received with a stream identifier field value other than
  # 0x0, the recipient MUST respond with a connection error
  # (Section 5.4.1) of type PROTOCOL_ERROR

  if result.headers.streamId != StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, "The stream id of PingFrame must be zero.")

  # Receipt of a PING frame with a length field value other than 8 MUST
  # be treated as a connection error (Section 5.4.1) of type
  # FRAME_SIZE_ERROR.
  if result.headers.length != 8 or not canReadNBytes(stream, 8):
    raise newConnectionError(ErrorCode.FrameSize, "The length of Ping Frame must be 8.")

  result.opaqueData = stream.readBEUint64
