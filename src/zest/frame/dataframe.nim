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
    padding*: Option[Padding]
    payload*: seq[byte]


proc initDataFrame*(streamId: StreamId, payload: seq[byte],
                    padding: Option[Padding], endStream = false): DataFrame {.inline.}=
  ## Initiates DataFrame.
  var flag: Flag
  var length = payload.len
  if padding.isSome:
    flag = FlagDataPadded
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
  var payloadLen: int
  if padLength.isSome:
    let size = int(padLength.get)
    payloadLen = int(length) - size - 1
    if size >= payloadLen:
      raise newConnectionError(errorCode = ErrorCode.Protocol, msg = "Padding is too large!")
  else:
    payloadLen = int(length)

  if canReadNBytes(stream, payloadLen):
    if payloadLen > 0:
      result = newSeq[byte](payloadLen)
      discard stream.readData(result[0].addr, payloadLen)

proc serialize*(frame: DataFrame): seq[byte] {.inline.} = 
  ## Serializes the fields of the dataFrame.

  result = newSeqOfCap[byte](9 + frame.headers.length)
  if frame.padding.isSome:
    let padLength = frame.padding.get()
    # headers + pad length + payload + Padding
    result.add frame.headers.serialize
    result.add byte(padLength)
    result.add frame.payload
    result.add newSeq[byte](padLength.int)
  else:
    # headers + payload
    result.add frame.headers.serialize
    result.add frame.payload

proc readDataFrame*(stream: StringStream): DataFrame {.inline.} =
  ## Reads the fields of the dataFrame.

  # read frame header
  result.headers = stream.readFrameHeaders

  # read pad length
  result.padding = stream.readPadding(result.headers)

  # read payload
  result.payload = stream.readPayload(result.headers.length, result.padding)
