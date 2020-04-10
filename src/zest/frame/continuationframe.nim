import ./baseframe


type
  ContinuationFrame* = object of Frame
    headerBlockFragment*: seq[byte]