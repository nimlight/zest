import ./baseframe


type
  # +-+-------------------------------------------------------------+
  # |R|                  Last-Stream-ID (31)                        |
  # +-+-------------------------------------------------------------+
  # |                      Error Code (32)                          |
  # +---------------------------------------------------------------+
  # |                  Additional Debug Data (*)                    |
  # +---------------------------------------------------------------+
  GoAwayFrame* = object of Frame
    lastStreamId*: StreamId
    errorCode*: ErrorCode
    debugData*: seq[byte]

proc initGoAwayFrame*(lastStreamId: StreamId, errorCode: ErrorCode, debugData: seq[byte]): GoAwayFrame =
  # Initiates GoAwayFrame
  let 
    length = 4 + 4 + debugData.len
    headers = initFrameHeaders(length = uint32(length), frameType = FrameType.GoAway,
                               flag = Flag(0), streamId = StreamId(0))

  GoAwayFrame(headers: headers, lastStreamId: lastStreamId, errorCode: errorCode, debugData: debugData)

proc serialize*(frame: GoAwayFrame): seq[byte] {.inline.} =
  # Serializes GoAwayFrame.
  result = newSeqofCap[byte](9 + frame.headers.length)
  result.add frame.headers.serialize

  var lastStreamId = frame.lastStreamId.uint32
  lastStreamId.clearBit(31)
  result.add lastStreamId.serialize

  result.add frame.errorCode.uint32.serialize

  result.add frame.debugData

proc readGoAwayFrame*(stream: StringStream): GoAwayFrame {.inline.} =
  # Reads GoAwayFrame.
  result.headers = stream.readFrameHeaders

  if result.headers.streamId != StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, "The stream id of GoAway frame must be zero.")

  let length = result.headers.length.int

  # read 8 bytes
  if length < 8 or not canReadNBytes(stream, length):
    raise newConnectionError(ErrorCode.FrameSize, "The length of GoAway frame must be more than 8 octets.")

  result.lastStreamId = StreamId(stream.readBEUint32)
  result.errorCode = stream.readErrorCode

  let debugDataLen = length - 8

  if debugDataLen > 0:
    var debugData = newSeq[byte](debugDataLen)
    discard stream.readData(debugData[0].addr, debugDataLen)
    result.debugData = debugData
