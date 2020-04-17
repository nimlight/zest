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
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssertRaises(ConnectionError):
      discard priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame
  
  # A stream cannot depend on itself.
  block:
    let
      streamId = StreamId(888)
      priority = initPriority(StreamId(888), weight = 0'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssertRaises(StreamError):
      discard priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame

  # A PRIORITY frame with a length other than 5 octets
  block:
    doAssertRaises(StreamError):
      discard @[0'u8, 0, 5, 2, 0, 1, 7, 5, 1, 8, 9, 3, 2].fromByteSeq.newStringStream.readPriorityFrame

  # weight is zero
  block:
    let
      streamId = StreamId(50)
      priority = initPriority(StreamId(888), weight = 0'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssert priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame == priorityFrame

  # weight is 255
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(0), weight = 255'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssert priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame == priorityFrame

  # exclusive is true
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(1), weight = 25'u8, exclusive = true)
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssert priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame == priorityFrame

  # exclusive is false
  block:
    let
      streamId = StreamId(10)
      priority = initPriority(StreamId(2), weight = 25'u8, exclusive = false)
      priorityFrame = initPriorityFrame(streamId, priority)

    doAssert priorityFrame.serialize.fromByteSeq.newStringStream.readPriorityFrame == priorityFrame
