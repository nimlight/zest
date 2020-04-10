import ./baseframe


type
  WindowUpdateFrame* = object of Frame
    windowSizeIncrement*: uint32