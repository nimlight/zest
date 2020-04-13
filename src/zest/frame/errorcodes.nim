type
  # https://tools.ietf.org/html/rfc7540#section-7
  ErrorCode* {.pure.} = enum
    No = 0'u32
    Protocol = 1'u32
    Internal = 2'u32
    FlowControl = 3'u32
    SettingsTimeout = 4'u32
    StreamClosed = 5'u32
    FrameSize = 6'u32
    RefusedStream = 7'u32
    Cancel = 8'u32
    Compression = 9'u32
    Connect = 10'u32
    EnhanceYourCalm = 11'u32
    InadequateSecurity = 12'u32
    Http11Required = 13'u32
