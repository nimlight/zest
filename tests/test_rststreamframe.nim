discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:refc; --gc:arc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/baseframe
import ../src/zest/frame/rststreamframe


# initiates RstStreamFrame
block:
  let 
    errorCode = ErrorCode.No
    rstStreamFrame = initRstStreamFrame(StreamId(12), errorCode)

  doAssert rstStreamFrame.serialize.fromByteSeq.newStringStream.readRstStreamFrame == rstStreamFrame


# A RST_STREAM frame with a length other than 4 octets
block:
  doAssertRaises(ConnectionError):
    discard @[0'u8, 0, 4, 3, 0, 1, 7, 5, 1, 0, 0, 0].fromByteSeq.newStringStream.readRstStreamFrame


# A RST_STREAM frame with a length other than 4 octets
block:
  doAssertRaises(StreamError):
    discard @[0'u8, 0, 4, 3, 0, 1, 7, 5, 1, 0, 0, 0, 14].fromByteSeq.newStringStream.readRstStreamFrame


# ErrorCode
block:
  block:
    let 
      errorCode = ErrorCode.No
      rstStreamFrame = initRstStreamFrame(StreamId(133), errorCode)

    doAssert rstStreamFrame.serialize.fromByteSeq.newStringStream.readRstStreamFrame == rstStreamFrame

  block:
    for idx in 0 .. 13:
      let 
        errorCode = ErrorCode(idx)
        rstStreamFrame = initRstStreamFrame(StreamId(12), errorCode)

      doAssert rstStreamFrame.serialize.fromByteSeq.newStringStream.readRstStreamFrame == rstStreamFrame
