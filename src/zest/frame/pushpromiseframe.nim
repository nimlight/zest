import ./baseframe


type
  # +---------------+
  # |Pad Length? (8)|
  # +-+-------------+-----------------------------------------------+
  # |R|                  Promised Stream ID (31)                    |
  # +-+-----------------------------+-------------------------------+
  # |                   Header Block Fragment (*)                 ...
  # +---------------------------------------------------------------+
  # |                           Padding (*)                       ...
  # +---------------------------------------------------------------+
  PushPromiseFrame* = object of Frame
    padding*: Option[Padding]
    promisedStreamID*: StreamId
    headerBlockFragment*: seq[byte]


proc initPushPromiseFrame*(streamId: StreamId, promisedStreamId: StreamId, headerBlockFragment: seq[byte],
                       padding: Option[Padding], endHeaders = false): PushPromiseFrame {.inline.} =
  ## Initiates PushPromiseFrame.
  var
    flag: Flag
    length = headerBlockFragment.len + 4

  # If a HEADERS frame is received whose stream identifier field is 0x0, 
  # the recipient MUST respond with a connection error 
  # (Section 5.4.1) of type PROTOCOL_ERROR.
  if streamId == StreamId(0):
    raise newException(ValueError, "The stream ID of PushPromise frame can't be zero.")

  # If the stream identifier field specifies the value
  # 0x0, a recipient MUST respond with a connection error (Section 5.4.1)
  # of type PROTOCOL_ERROR.
  if promisedStreamId == StreamId(0):
    raise newException(ValueError, "The promised stream ID of PushPromise frame can't be zero.")

  if padding.isSome:
    flag = flag or FlagPushPromisePadded
    inc(length, padding.get.int + 1)

  if endHeaders:
    flag = flag or FlagPushPromiseEndHeaders

  let headers = initFrameHeaders(length = uint32(length), frameType = FrameType.PushPromise,
                                 flag = flag, streamId = streamId)

  PushPromiseFrame(headers: headers, promisedStreamID: promisedStreamId, headerBlockFragment: headerBlockFragment, padding: padding)

proc readHeaderBlockFragment*(stream: StringStream, 
                              pushPromiseFrame: PushPromiseFrame): seq[byte] {.inline.} =
  var 
    length = pushPromiseFrame.headers.length.int - 4

  if pushPromiseFrame.padding.isSome:
    let 
      padLength = pushPromiseFrame.padding.get.int

    dec(length, padLength + 1)

    # Padding that exceeds the size remaining for the header block fragment MUST be
    # treated as a PROTOCOL_ERROR.
    if padLength >= length:
      raise newStreamError(ErrorCode.Protocol, "Padding is too large.")
  
  if length > 0 and canReadNBytes(stream, length):
    result = newSeq[byte](length)
    discard stream.readData(result[0].addr, length)

proc serialize*(frame: PushPromiseFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the PushPromiseFrame.
  
  # headers + pad length(?) + promised StreamId + headerBlockFragment + Padding(?)
  let length = 9 + frame.headers.length
  result = newSeqOfCap[byte](length)
  result.add frame.headers.serialize
  if frame.padding.isSome:
    result.add byte(frame.padding.get)

  var promisedStreamId = frame.promisedStreamID.uint32
  promisedStreamId.clearBit(31)
  result.add promisedStreamId.serialize

  result.add frame.headerBlockFragment
  result.setLen(length)

proc read*(self: type[PushPromiseFrame], headers: FrameHeaders, 
           stream: StringStream): PushPromiseFrame {.inline.} =
  ## Reads the fields of the PushPromiseFrame.
  
  assert headers.frameType == FrameType.PushPromise, "FrameType must be PushPromise."

  # read frame header
  result.headers = headers

  # If a HEADERS frame is received whose stream identifier field is 0x0, 
  # the recipient MUST respond with a connection error 
  # (Section 5.4.1) of type PROTOCOL_ERROR.
  if result.headers.streamId == StreamId(0):
    raise newConnectionError(ErrorCode.Protocol, "PushPromise frame can't be received with stream ID 0")

  # read pad length
  result.padding = stream.readPadding(result.headers)

  if canReadNBytes(stream, 4):
    # read promisedStreamId
    var promisedStreamId = stream.readBEUint32
    promisedStreamId.clearBit(31)
    result.promisedStreamId = StreamId(promisedStreamId)

    # If the stream identifier field specifies the value
    # 0x0, a recipient MUST respond with a connection error (Section 5.4.1)
    # of type PROTOCOL_ERROR.
    if result.promisedStreamId == StreamId(0):
      raise newConnectionError(ErrorCode.Protocol, 
                              "PushPromise frame can't be received with promised stream ID 0")

  # read headerBlockFragment
  result.headerBlockFragment = stream.readHeaderBlockFragment(result)
