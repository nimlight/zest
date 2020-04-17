import ./baseframe


type
  # +---------------+
  # |Pad Length? (8)|
  # +-+-------------+-----------------------------------------------+
  # |E|                 Stream Dependency? (31)                     |
  # +-+-------------+-----------------------------------------------+
  # |  Weight? (8)  |
  # +-+-------------+-----------------------------------------------+
  # |                   Header Block Fragment (*)                 ...
  # +---------------------------------------------------------------+
  # |                           Padding (*)                       ...
  # +---------------------------------------------------------------+
  HeadersFrame* = object of Frame
    padding*: Option[Padding]
    priority*: Option[Priority]
    headerBlockFragment*: seq[byte]


proc initHeadersFrame*(streamId: StreamId, headerBlockFragment: seq[byte],
                       padding: Option[Padding], priority: Option[Priority], 
                       endStream = false, endHeaders = false): HeadersFrame {.inline.} =
  ## Initiates HeadersFrame.
  var 
    flag: Flag
    length = headerBlockFragment.len

  if padding.isSome:
    flag = flag or FlagHeadersPadded
    inc(length, padding.get.int + 1)

  if priority.isSome:
    flag = flag or FlagHeadersPriority
    inc(length, 5)

  if endStream:
    flag = flag or FlagHeadersEndStream

  if endHeaders:
    flag = flag or FlagHeadersEndHeaders

  let headers = initFrameHeaders(length = uint32(length), frameType = FrameType.Headers,
                                 flag = flag, streamId = streamId)

  HeadersFrame(headers: headers, headerBlockFragment: headerBlockFragment, 
               priority: priority, padding: padding)

proc readHeaderBlockFragment*(stream: StringStream, 
                              headersFrame: HeadersFrame): seq[byte] {.inline.} =
  var 
    length = headersFrame.headers.length.int

  if headersFrame.priority.isSome:
    dec(length, 5)

  if headersFrame.padding.isSome:
    let padLength = headersFrame.padding.get.int
    dec(length, padLength + 1)

    # Padding that exceeds the size remaining for the header block fragment MUST be
    # treated as a PROTOCOL_ERROR.
    if padLength >= length:
      raise newStreamError(ErrorCode.Protocol, "Padding is too large!")
  
  if length > 0 and canReadNBytes(stream, length):
    result = newSeq[byte](length)
    discard stream.readData(result[0].addr, length)

proc serialize*(frame: HeadersFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the HeadersFrame.
  
  # headers + pad length(?) + priority(?) + headerBlockFragment + Padding(?)
  let length = 9 + frame.headers.length
  result = newSeqOfCap[byte](length)
  result.add frame.headers.serialize
  if frame.padding.isSome:
    result.add byte(frame.padding.get)

  # A stream that is not dependent on any other stream is given a stream
  # dependency of 0x0.
  if frame.priority.isSome:
    let priority = frame.priority.get
    var streamId = uint32(priority.streamId)
    if priority.exclusive:
      streamId.setBit(31)
    else:
      streamId.clearBit(31)
    result.add serialize(streamId)
    result.add byte(priority.weight)

  result.add frame.headerBlockFragment
  result.setLen(length)

proc readHeadersFrame*(stream: StringStream): HeadersFrame {.inline.} =
  ## Reads the fields of the HeadersFrame.
  
  # read frame header
  result.headers = stream.readFrameHeaders

  # If a HEADERS frame is received whose stream identifier field is 0x0, 
  # the recipient MUST respond with a connection error 
  # (Section 5.4.1) of type PROTOCOL_ERROR.
  if result.headers.streamId == StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, "HEADERS frame can't be received with stream ID 0")

  # read pad length
  result.padding = stream.readPadding(result.headers)

  # read frame priority
  result.priority = stream.readPriority(result.headers)

  # read headerBlockFragment
  result.headerBlockFragment = stream.readHeaderBlockFragment(result)
