type
  # An 8-bit field reserved for boolean flags specific to the frame type.
  Flag* = distinct uint8


const
  # Data Frame
  FlagDataEndStream* = Flag(1)
  FlagDataPadded* = Flag(8)

  # Headers Frame
  FlagHeadersEndStream* = Flag(1)
  FlagHeadersEndHeaders* = Flag(4)
  FlagHeadersPadded* = Flag(8)
  FlagHeadersPriority* = Flag(32)

  # Settings Frame
  FlagSettingsAck* = Flag(1)

  # Ping Frame
  FlagPingAck* = Flag(1)

  # Continuation Frame
  FlagContinuationEndHeaders* = Flag(4)

  # PushPromise  
  FlagPushPromiseEndHeaders* = Flag(4)
  FlagPushPromisePadded* = Flag(8)


proc `==`*(self, other: Flag): bool {.borrow.}
proc `and`*(self, other: Flag): Flag {.borrow.}
proc `or`*(self, other: Flag): Flag {.borrow.}


template contains*(self, other: Flag): bool =
  ## Decides whether ``self`` flags collection contains ``other`` flag.
  (self and other) == other
