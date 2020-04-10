import ./baseframe


type
  HeadersFrame* = object of Frame
    padding*: Option[Padding]
    priority*: Option[Priority]
    headerBlockFragment*: seq[byte]