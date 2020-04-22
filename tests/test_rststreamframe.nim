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
    headers = rstStreamFrame.headers

  doAssert RstStreamFrame.read(headers, rstStreamFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == rstStreamFrame


# A RST_STREAM frame with a length other than 4 octets
block:
  let headers = @[0'u8, 0, 4, 3, 0, 1, 7, 5, 1].fromByteSeq.newStringStream.readFrameHeaders
  doAssertRaises(ConnectionError):
    discard RstStreamFrame.read(headers, @[0'u8, 0, 0].fromByteSeq.newStringStream)


# A RST_STREAM frame with a length other than 4 octets
block:
  let headers = @[0'u8, 0, 4, 3, 0, 1, 7, 5, 1].fromByteSeq.newStringStream.readFrameHeaders
  doAssertRaises(StreamError):
    discard RstStreamFrame.read(headers, @[0'u8, 0, 0, 14].fromByteSeq.newStringStream)


# ErrorCode
block:
  block:
    let 
      errorCode = ErrorCode.No
      rstStreamFrame = initRstStreamFrame(StreamId(133), errorCode)
      headers = rstStreamFrame.headers

    doAssert RstStreamFrame.read(headers, rstStreamFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == rstStreamFrame

  block:
    for idx in 0 .. 13:
      let 
        errorCode = ErrorCode(idx)
        rstStreamFrame = initRstStreamFrame(StreamId(12), errorCode)
        headers = rstStreamFrame.headers

      doAssert RstStreamFrame.read(headers, rstStreamFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == rstStreamFrame
