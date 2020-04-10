import ./baseframe


type
  GoAwayFrame* = object of Frame
    lastStreamId*: StreamId
    errorCode*: ErrorCode
    debugData*: seq[byte]