import ./baseframe

type
  DataFrame* = object of Frame
    padding*: Option[Padding]
