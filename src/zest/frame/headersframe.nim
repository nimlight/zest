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

proc serialize*(frame: HeadersFrame): seq[byte] = 
  ## Serializes the fields of the dataFrame.
  if frame.padding.isSome:
    let length = frame.padding.get()
    if frame.priority.isSome:
      # headers + pad length + priority + headerBlockFragment + Padding
      result = newSeqOfCap[byte](9 + 1 + frame.headerBlockFragment.len + length.int)
      result.add frame.headers.serialize
      result.add byte(length)
      result.add frame.headerBlockFragment
      result.add newSeq[byte](length.int)
  else:
    # headers + payload
    result = newSeqOfCap[byte](9 + frame.headerBlockFragment.len)
    result.add frame.headers.serialize
    result.add frame.headerBlockFragment

proc readHeadersFrame*(stream: StringStream): HeadersFrame =
  ## Reads the fields of the dataFrame.
  
  # read frame header
  result.headers = stream.readFrameHeaders

  # read pad length
  # result.padding = readPadding(stream, result.headers)

  # read payload
