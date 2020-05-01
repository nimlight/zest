import ../base/errorcodes


type
  H2Error* = ref object of CatchableError
  ProtocolError* = ref object of CatchableError
    errorCode: ErrorCode
