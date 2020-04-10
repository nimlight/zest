import ./baseframe

type
  # +---------------+ |Pad Length? (8)|
  # +---------------+-----------------------------------------------+ |
  # Data (*) Padding (*) ...
  # +---------------------------------------------------------------+ |
  # ...
  # +---------------------------------------------------------------+

  # DATA frames MAY also contain padding.  Padding can be added to DATA
  # frames to obscure the size of messages.  Padding is a security
  # feature.
  # https://tools.ietf.org/html/rfc7540#section-6.1
  # FlagDataEndStream = 0x1
  # FlagDataPadded = 0x8
  DataFrame* = object of Frame
    ## DATA frames (type=0x0) convey arbitrary, variable-length sequences of
    ## octets associated with a stream.  One or more DATA frames are used,
    ## for instance, to carry HTTP request or response payloads.
    # allowed flags: END_STREAM (0x1) PADDED (0x8)
    padding*: Option[Padding]


proc serialize*(frame: DataFrame): seq[byte] =
  discard
