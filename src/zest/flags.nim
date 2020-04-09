type
  Flag* = distinct uint8


const
  # Data Frame
  FlagDataEndStream* = Flag(1)
  FlagDataPadded* = Flag(8)

  # Headers Frame
  FlagHeadersEndStream* = Flag(1)
  FlagHeadersEndHeaders* = Flag(4)
  FlagHeadersPadded* = Flag(8)
  FlagHeadersPriority* = Flag(20)

  # Settings Frame
  FlagSettingsAck* = Flag(1)

  # Ping Frame
  FlagPingAck* = Flag(1)

  # Continuation Frame
  FlagContinuationEndHeaders* = Flag(4)

  # PushPromise  
  FlagPushPromiseEndHeaders* = Flag(4)
  FlagPushPromisePadded* = Flag(8)
