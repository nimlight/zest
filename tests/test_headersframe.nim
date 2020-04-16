discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; --gc:refc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/baseframe
import ../src/zest/frame/headersFrame


import ./utils


# initiates
block:
  let
    streamId = StreamId(374)
    headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
    padding = Padding(4)
    priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
    headersFrame = initHeadersFrame(streamId, headerBlockFragment, some(padding), some(priority))

  doAssert headersFrame.serialize.fromByteSeq.newStringStream.readHeadersFrame == headersFrame


# padding

