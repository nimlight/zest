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


proc initDataFrame*(headers: FrameHeaders, payload: seq[byte], padding: Option[Padding]): DataFrame =
  ## Initiates DataFrame.
  DataFrame(headers: headers, payload: payload, padding: padding)

proc serialize*(frame: DataFrame): seq[byte] = 
  ## Serializes the fields of the dataFrame.
  if frame.padding.isSome:
    let length = frame.padding.get()
    # headers + pad length + payload + Padding
    result = newSeqOfCap[byte](9 + 1 + frame.payload.len + length.int)
    result.add frame.headers.serialize
    result.add byte(length)
    result.add frame.payload
    result.add newSeq[byte](length.int)
  else:
    # headers + payload
    result = newSeqOfCap[byte](9 + frame.payload.len)
    result.add frame.headers.serialize
    result.add frame.payload

proc readDataFrame*(stream: StringStream): DataFrame =
  ## Reads the fields of the dataFrame.

  # read frame header
  result.headers = stream.readFrameHeaders

  # read pad length
  result.padding = stream.readPadding(result.headers)

  # read payload
  result.payload = stream.readPayload(result.headers)
