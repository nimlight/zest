import ./baseframe


type
  # +---------------------------------------------------------------+
  # |                   Header Block Fragment (*)                 ...
  # +---------------------------------------------------------------+
  ContinuationFrame* = object of Frame
    headerBlockFragment: seq[byte]


proc `headerBlockFragment`*(frame: ContinuationFrame): seq[byte] {.inline.} =
  frame.headerBlockFragment

proc initContinuationFrame*(streamId: StreamId, headerBlockFragment: seq[byte], 
                            endHeaders = false): ContinuationFrame {.inline.} =
  ## Initiates ContinuationFrame.
  let flag = if endHeaders: FlagContinuationEndHeaders
    else: Flag(0)

  # If a CONTINUATION frame is received whose stream identifier field is 0x0,
  # the recipient MUST respond with a connection error (Section 5.4.1) of
  # type PROTOCOL_ERROR.
  if streamId == StreamId(0):
    raise newException(ValueError, "The length of continuationFrame can be zero.")

  let headers = initFrameHeaders(length = headerBlockFragment.len.uint32, frameType = FrameType.Continuation, 
                                 flag = flag, streamId = streamId)

  ContinuationFrame(headers: headers, headerBlockFragment: headerBlockFragment)

proc serialize*(frame: ContinuationFrame): seq[byte] {.inline.} =
  ## Serializes ContinuationFrame.
  result = newSeqOfCap[byte](9 + frame.headers.length)

  result.add frame.headers.serialize
  result.add frame.headerBlockFragment

proc read*(self: type[ContinuationFrame], headers: FrameHeaders,stream: StringStream): ContinuationFrame {.inline.} =
  ## Reads ContinuationFrame.
  
  assert headers.frameType == FrameType.Continuation, "FrameType must be Continuation."


  result.headers = headers

  # CONTINUATION frames MUST be associated with a stream.  If a
  # CONTINUATION frame is received whose stream identifier field is 0x0,
  # the recipient MUST respond with a connection error (Section 5.4.1) of
  # type PROTOCOL_ERROR.
  if result.headers.streamId == StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, 
                             "The stream id of Continuation frames must not be zero.")

  let length = result.headers.length.int
  if length > 0:
    if not canReadNBytes(stream, length):
      raise newConnectionError(ErrorCode.FrameSize, "Invalid Frame.")

    var headerBlockFragment = newseq[byte](length)
    discard stream.readData(headerBlockFragment[0].addr, length)
    result.headerBlockFragment = move(headerBlockFragment)
