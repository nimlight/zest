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
import ../src/zest/frame/priorityframe


# priority
block:
  # a PRIORITY frame is received with a stream identifier of 0x0
  block:
    let
      streamId = StreamId(0)
      priority = initPriority(StreamId(888), weight = 0'u8, exclusive = false)


    doAssertRaises(ValueError):
      discard initPriorityFrame(streamId, priority)

  # A stream cannot depend on itself.
  block:
    discard

  # A PRIORITY frame with a length other than 5 octets
  block:
    let headers = [0'u8, 0, 5, 2, 0, 1, 7, 5, 1].fromByteSeq.newStringStream.readFrameHeaders
    doAssertRaises(StreamError):
      discard PriorityFrame.read(headers, @[8'u8, 9, 3, 2].fromByteSeq.newStringStream)

  # weight is zero
  block:
    let
      streamId = StreamId(50)
      priority = initPriority(StreamId(888), weight = 0'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)
      headers = priorityFrame.headers

    doAssert PriorityFrame.read(headers, priorityFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == priorityFrame

  # weight is 255
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(0), weight = 255'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)
      headers = priorityFrame.headers

    doAssert PriorityFrame.read(headers, priorityFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == priorityFrame

  # exclusive is true
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(1), weight = 25'u8, exclusive = true)
      priorityFrame = initPriorityFrame(streamId, priority)
      headers = priorityFrame.headers

    doAssert PriorityFrame.read(headers, priorityFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == priorityFrame

  # exclusive is false
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(2), weight = 25'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)
      headers = priorityFrame.headers

    doAssert PriorityFrame.read(headers, priorityFrame.serialize[9 .. ^1].fromByteSeq
                                                      .newStringStream) == priorityFrame
