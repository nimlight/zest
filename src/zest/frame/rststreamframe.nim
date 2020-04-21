import ./baseframe


type
  # +---------------------------------------------------------------+
  # |                        Error Code (32)                        |
  # +---------------------------------------------------------------+
  RstStreamFrame* = object of Frame
    errorCode*: ErrorCode


proc initRstStreamFrame*(streamId: StreamId, errorCode: ErrorCode): RstStreamFrame {.inline.} =
  ## Initiates RstStreamFrame.
  let headers = initFrameHeaders(length = 4'u32, frameType = FrameType.RstStream,
                                 flag = Flag(0), streamId = streamId)

  RstStreamFrame(headers: headers, errorCode: errorCode)

proc serialize*(frame: RstStreamFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the RstStreamFrame.
  
  # headers + errorCode
  result = newSeqOfCap[byte](9 + 4)
  result.add frame.headers.serialize
  result.add frame.errorCode.uint32.serialize

proc readRstStreamFrame*(stream: StringStream): RstStreamFrame {.inline.} =
  ## Reads the fields of the RstStreamFrame.
  
  # read frame header
  result.headers = stream.readFrameHeaders

  # A RST_STREAM frame with a length other than 4 octets MUST be treated
  # as a connection error (Section 5.4.1) of type FRAME_SIZE_ERROR.
  if not canReadNBytes(stream, 4):
    raise newConnectionError(ErrorCode.FrameSize, "The length of RstStream frame must be more than 4 octets.")

  # read frame ErrorCode
  result.errorCode = stream.readErrorCode
