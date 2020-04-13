discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc"
  targets:  "c cpp"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import streams


import ../src/zest/frame/baseframe
import ../src/zest/frame/dataframe


block:
  let 
    length = 1'u32
    frameType = FrameType.Data
    flag = FlagDataPadded
    streamId = StreamId(21474836'u32)
    frameHeaders = initFrameHeaders(length, frameType, flag, streamId)
    dataFrame = initDataFrame(frameHeaders, @[12'u8], none(Padding))

  doAssert dataFrame.headers.length == length
