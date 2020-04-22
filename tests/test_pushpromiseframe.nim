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
import ../src/zest/frame/pushpromiseframe


import ./utils


# padding
block:
  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(231), StreamId(781), 
                                             @[1'u8, 2], padding = none(Padding))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(231), StreamId(781), 
                                             @[1'u8, 2], padding = some(Padding(0)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(231), StreamId(781), 
                                             @[1'u8, 2], padding = some(Padding(1)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(231), StreamId(781), 
                                             newSeq[byte](256), padding = some(Padding(255)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame


# SteamId
block:
  block:
    doAssertRaises(ValueError):
      discard initPushPromiseFrame(StreamId(0), StreamId(781), 
                                             @[1'u8, 2], padding = none(Padding))

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(1), StreamId(781), 
                                             @[1'u8, 2], padding = some(Padding(0)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(31), StreamId(781), 
                                             @[1'u8, 2], padding = some(Padding(1)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(high(uint32) shr 1), StreamId(781), 
                                             newSeq[byte](256), padding = some(Padding(255)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame


# SteamId
block:
  block:
    doAssertRaises(ValueError):
      discard initPushPromiseFrame(StreamId(10), StreamId(0), 
                                             @[1'u8, 2], padding = none(Padding))

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(1), StreamId(1), 
                                             @[1'u8, 2], padding = some(Padding(0)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(31), StreamId(781), 
                                             @[1'u8, 2], padding = some(Padding(1)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(71), StreamId(high(uint32) shr 1), 
                                             newSeq[byte](256), padding = some(Padding(255)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame


# headerBlockFragment
block:
  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(10), StreamId(10), 
                                             @[], padding = none(Padding))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(1), StreamId(1), 
                                             @[1'u8], padding = some(Padding(0)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(31), StreamId(13), 
                                             @[1'u8, 2, 3], padding = some(Padding(1)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame

  block:
    let 
      promisedFrame = initPushPromiseFrame(StreamId(71), StreamId(17), 
                                             newSeq[byte](2569), padding = some(Padding(255)))
      headers = promisedFrame.headers

    doAssert PushPromiseFrame.read(headers, promisedFrame.serialize[9 .. ^1].fromByteSeq
                                                         .newStringStream) == promisedFrame
