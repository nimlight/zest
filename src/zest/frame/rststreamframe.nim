import ./baseframe


type
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

  # read frame ErrorCode
  let errorCode = stream.readBEUint32
  if errorCode >= 14'u8:
    raise newStreamError(ErrorCode.Protocol, "Unknown errorCode!")
  else:
    result.errorCode = ErrorCode(errorCode)
