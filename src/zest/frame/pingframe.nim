import ./baseframe


type
  PingFrame* = object of Frame
    opaqueData*: uint64
