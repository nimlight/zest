import ./baseframe


type
  HeadersFrame* = object of Frame
    padding*: Option[Padding]
    priority*: Option[Priority]
    headerBlockFragment*: seq[byte]

proc serialize*(frame: HeadersFrame): seq[byte] = 
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

proc readHeadersFrame*(stream: StringStream): HeadersFrame =
  ## Reads the fields of the dataFrame.
  
  # read frame header
  result.headers = stream.readFrameHeaders

  # read pad length
  result.padding = readPadding(stream, result.headers)

  # read payload
  result.payload = readPayload(stream, result.headers)
