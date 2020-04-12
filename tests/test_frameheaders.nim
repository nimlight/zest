discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "-d:release"
  targets:  "c cpp"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams


import ../src/zest/frame/basetypes


block:
  # test frame headers
  let 
    length = 16777215'u32
    frameType = FrameType.Data
    flag = FlagDataPadded
    streamId = StreamId(21474836'u32)
  let frameHeaders = initFrameHeaders(length, frametype, flag, streamId)

  var serialize = frameHeaders.serialize
  doAssert serialize == @[255'u8, 255, 255, 0, 8, 1, 71, 174, 20]

  var str = "\xFF\xFF\xFF\x00\x08\x01\x47\xAE\x14"
  let 
    strm = newStringStream(str)
    readed = strm.readFrameHeaders
  doAssert readed.length == length
  doAssert readed.frameType == frameType
  doAssert readed.flag == flag
  doAssert readed.streamId == streamId
  strm.close()
