import ./baseframe


type
  PriorityFrame* = object of Frame
    priority*: Option[Priority]
