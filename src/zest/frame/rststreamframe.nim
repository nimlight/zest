import ./baseframe


type
  RstStreamFrame* = object of Frame
    errorCode: ErrorCode
