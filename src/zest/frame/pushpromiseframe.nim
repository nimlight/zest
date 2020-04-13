import ./baseframe


type
  PushPromiseFrame* = object of Frame
    padding*: Option[Padding]
    promisedStreamID*: StreamId
    headerBlockFragment*: seq[byte]
