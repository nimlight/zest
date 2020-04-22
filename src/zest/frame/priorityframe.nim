import ./baseframe


type
  # +-+-------------------------------------------------------------+
  # |E|                  Stream Dependency (31)                     |
  # +-+-------------+-----------------------------------------------+
  # |   Weight (8)  |
  # +-+-------------+
  PriorityFrame* = object of Frame
    priority*: Priority


proc initPriorityFrame*(streamId: StreamId, priority: Priority): PriorityFrame {.inline.} =
  ## Initiates PriorityFrame.
  
  # The PRIORITY frame always identifies a stream.  If a PRIORITY frame
  # is received with a stream identifier of 0x0, the recipient MUST
  # respond with a connection error (Section 5.4.1) of type PROTOCOL_ERROR.
  if streamId == StreamId(0):
    raise newException(ValueError, "The streamid of Priority frame can't be zero.")

  assert streamId != priority.streamId, "A stream cannot depend on itself."
  
  let headers = initFrameHeaders(length = 5'u32, frameType = FrameType.Priority,
                                 flag = Flag(0), streamId = streamId)

  PriorityFrame(headers: headers, priority: priority)

proc serialize*(frame: PriorityFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the PriorityFrame.
  
  # headers + priority
  result = newSeqOfCap[byte](9 + 5)
  result.add frame.headers.serialize

  # A stream that is not dependent on any other stream is given a stream
  # dependency of 0x0.
  let priority = frame.priority
  var streamId = uint32(priority.streamId)
  if priority.exclusive:
    streamId.setBit(31)
  else:
    streamId.clearBit(31)
  result.add serialize(streamId)
  result.add byte(priority.weight)

proc read*(self: type[PriorityFrame], headers: FrameHeaders,
                        stream: StringStream): PriorityFrame {.inline.} =
  ## Reads the fields of the PriorityFrame.
  
  assert headers.frameType == FrameType.Priority, "FrameType must be Priority."

  # read frame header
  result.headers = headers

  # The PRIORITY frame always identifies a stream.  If a PRIORITY frame
  # is received with a stream identifier of 0x0, the recipient MUST
  # respond with a connection error (Section 5.4.1) of type PROTOCOL_ERROR.
  if result.headers.streamId == StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, "Priority frame can't be received with stream ID 0.")

  # read frame priority
  let priority = stream.readPriority(result.headers)
  if priority.isNone:
    raise newStreamError(ErrorCode.FrameSize, "The length of PRIORITY frame must be more than 5 octets.")
  result.priority = priority.get
