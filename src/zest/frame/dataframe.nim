import ./baseframe

type
  # +---------------+
  # |Pad Length? (8)|
  # +---------------+-----------------------------------------------+
  # |                            Data (*)                         ...
  # +---------------------------------------------------------------+
  # |                           Padding (*)                       ...
  # +---------------------------------------------------------------+

  # DATA frames MAY also contain padding. Padding can be added to DATA
  # frames to obscure the size of messages. Padding is a security
  # feature.
  # https://tools.ietf.org/html/rfc7540#section-6.1

  DataFrame* = object of Frame
    ## DATA frames (type=0x0) convey arbitrary, variable-length sequences of
    ## octets associated with a stream.  One or more DATA frames are used,
    ## for instance, to carry HTTP request or response payloads.
    # Allowed flags:
    # FlagDataEndStream = 0x1
    # FlagDataPadded = 0x8
    padding: Option[Padding]
    payload: seq[byte]


proc `padding`*(frame: DataFrame): Option[Padding] {.inline.} =
  frame.padding

proc `payload`*(frame: DataFrame): seq[byte] {.inline.} =
  frame.payload

proc initDataFrame*(streamId: StreamId, payload: seq[byte],
                    padding: Option[Padding], endStream = false): DataFrame {.inline.} =
  ## Initiates DataFrame.
  var 
    flag: Flag
    length = payload.len

  # DATA frames MUST be associated with a stream.  If a DATA frame is
  # received whose stream identifier field is 0x0, the recipient MUST
  # respond with a connection error (Section 5.4.1) of type
  # PROTOCOL_ERROR.
  if streamId == StreamId(0):
    raise newException(ValueError, "The stream id of DataFrame must not be zero.")

  if padding.isSome:
    flag = flag or FlagDataPadded
    inc(length, padding.get.int + 1)

  if endStream:
    flag = flag or FlagDataEndStream

  let headers = initFrameHeaders(length = uint32(length), frameType = FrameType.Data,
                                 flag = flag, streamId = streamId)

  DataFrame(headers: headers, payload: payload, padding: padding)

proc isStreamEnded*(frame: DataFrame): bool {.inline.} =
  ## Contains FlagDataEndStream flag.
  frame.headers.flag.contains(FlagDataEndStream)

proc isPadded*(frame: DataFrame): bool {.inline.} =
  ## Contains FlagDataPadded flag.
  frame.headers.flag.contains(FlagDataPadded)

proc readPayload*(stream: StringStream, length: uint32, padLength: Option[Padding]): seq[byte] {.inline.} =
  ## Reads payload.
  var payloadLen = int(length)

  if padLength.isSome:
    let size = int(padLength.get)
    dec(payloadLen, size + 1)
    if size >= payloadLen:
      raise newConnectionError(errorCode = ErrorCode.Protocol, msg = "Padding is too large.")

  if payloadLen > 0 and canReadNBytes(stream, payloadLen):
    result = newSeq[byte](payloadLen)
    discard stream.readData(result[0].addr, payloadLen)

proc serialize*(frame: DataFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the DataFrame.

  let length = 9 + frame.headers.length
  result = newSeqOfCap[byte](length)
  result.add frame.headers.serialize
  # headers + pad length(?) + payload + Padding(?)
  if frame.padding.isSome:
    result.add byte(frame.padding.get)
  result.add frame.payload
  result.setLen(length)

proc read*(self: type[DataFrame], headers: FrameHeaders, stream: StringStream): DataFrame {.inline.} =
  ## Reads the fields of the DataFrame.
  
  assert headers.frameType == FrameType.Data, "FrameType must be Data."

  # read frame header
  result.headers = headers

  # DATA frames MUST be associated with a stream.  If a DATA frame is
  # received whose stream identifier field is 0x0, the recipient MUST
  # respond with a connection error (Section 5.4.1) of type
  # PROTOCOL_ERROR.
  if result.headers.streamId == StreamId(0):
    raise newException(ValueError, "The stream id of DataFrame must not be zero.")

  # read pad length
  result.padding = stream.readPadding(result.headers)

  # read payload
  result.payload = stream.readPayload(result.headers.length, result.padding)
