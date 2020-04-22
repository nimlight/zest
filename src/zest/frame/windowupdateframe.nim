import ./baseframe


type
  # +-+-------------------------------------------------------------+
  # |R|              Window Size Increment (31)                     |
  # +-+-------------------------------------------------------------+
  WindowUpdateFrame* = object of Frame
    windowSizeIncrement*: uint32 # [1, 2^31-1] (2,147,483,647)


proc initWindowUpdateFrame*(streamId: StreamId, 
                            windowSizeIncrement: uint32): WindowUpdateFrame {.inline.} =
  ## Initiates WindowUpdateFrame.
  let headers = initFrameHeaders(length = 4, frameType = FrameType.WindowUpdate, 
                                 flag = Flag(0), streamId = streamId)
  
  if windowSizeIncrement == 0'u32:
    raise newException(ValueError, "The length of window must be more than zero.")

  WindowUpdateFrame(headers: headers, windowSizeIncrement: windowSizeIncrement)

proc serialize*(frame: WindowUpdateFrame): seq[byte] {.inline.} =
  ## Serializes WindowUpdateFrame.
  result = newSeqOfCap[byte](9 + 4)

  result.add frame.headers.serialize
  result.add frame.windowSizeIncrement.serialize

proc read*(self: type[WindowUpdateFrame], headers: FrameHeaders, 
           stream: StringStream): WindowUpdateFrame {.inline.} =
  ## Reads WindowUpdateFrame.
  result.headers = headers


  #  A WINDOW_UPDATE frame with a length other than 4 octets MUST be
  #  treated as a connection error (Section 5.4.1) of type
  #  FRAME_SIZE_ERROR.
  if not canReadNBytes(stream, 4):
    raise newConnectionError(ErrorCode.FrameSize, "The length of windowUpdateFrame must be more 4 octets.")

  # A receiver MUST treat the receipt of a WINDOW_UPDATE frame with an
  # flow-control window increment of 0 as a stream error (Section 5.4.2)
  # of type PROTOCOL_ERROR; errors on the connection flow-control window
  # MUST be treated as a connection error (Section 5.4.1)
  var increment = stream.readBEUint32
  increment.clearBit(31)
  if increment == 0'u32:
    if result.headers.streamId == StreamId(0):
      raise newConnectionError(ErrorCode.Protocol, "Window increment can't be 0.")
    else:
      raise newStreamError(ErrorCode.Protocol, "Window increment can't be 0.")
  result.windowSizeIncrement = increment
