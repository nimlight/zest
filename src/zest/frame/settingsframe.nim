import ./baseframe


type
  SettingsFrame* = object of Frame
    settings: Settings
    size: uint32