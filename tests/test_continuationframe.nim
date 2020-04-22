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
import ../src/zest/frame/continuationframe


block:
  doAssertRaises(ValueError):
    discard initContinuationFrame(StreamId(0), @[])


# streamId
block:
  let streamId = [1, 2, 3, 666, 2233, 2333]
  for idx in streamId:
    let 
      continuationFrame = initContinuationFrame(StreamId(idx), @[1'u8, 7])
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame


# flag
block:
  let flags = [true, false]
  for idx in flags:
    let 
      continuationFrame = initContinuationFrame(StreamId(1723), @[1'u8, 7], idx)
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame


# headerBlockFragment
block:
  block:
    let 
      continuationFrame = initContinuationFrame(StreamId(1723), @[], true)
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame

  block:
    let 
      continuationFrame = initContinuationFrame(StreamId(1723), @[0'u8], true)
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame

  block:
    let 
      continuationFrame = initContinuationFrame(StreamId(1723), @[1'u8, 2'u8], true)
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame

  block:
    let 
      continuationFrame = initContinuationFrame(StreamId(1723), 
                                                  @[1'u8, 2, 3, 7, 8, 9, 12, 255, 236], true)
      headers = continuationFrame.headers

    doAssert ContinuationFrame.read(headers, 
          continuationFrame.serialize[9 .. ^1].fromByteSeq.newStringStream) == continuationFrame
