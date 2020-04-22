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
import ../src/zest/frame/headersframe


import ./utils


# initiates
block:
  let
    streamId = StreamId(374)
    headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
    padding = some(Padding(4))
    priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
    headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
    headers = headersFrame.headers

  doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame


# initiates
block:
  let
    streamId = StreamId(374)
    headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
    padding = some(Padding(4))
    priority = initPriority(StreamId(374), weight = 12'u8, exclusive = false)
    headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
    headers = headersFrame.headers

  doAssertRaises(StreamError):
    discard HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream)


# receive headersFrame and streamId is 0x0
block:
  let
    streamId = StreamId(0)
    headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
    padding = some(Padding(4))
    priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)

  doAssertRaises(ValueError):
    discard initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))


# empty padding and empty priority
block:
  let
    streamId = StreamId(374)
    headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
    padding = none(Padding)
    priority = none(Priority)
    headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, priority)
    headers = headersFrame.headers

  doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame


# padding
block:
  # empty padding
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = none(Padding)
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # zero padding
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(0))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # more padding
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # pad length is more than headerBlockFragment length
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(18))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssertRaises(StreamError):
      discard HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream)


# priority
block:
  # empty priority
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, none(Priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # depends on streamId 0x0
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(0), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # depends on streamId 0x888
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(888), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # weight is zero
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(888), weight = 0'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # weight is 255
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(888), weight = 255'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # exclusive is true
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(888), weight = 124'u8, exclusive = true)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # exclusive is false
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment = @[120'u8, 105, 110, 103, 122, 101, 115, 104, 101, 110]
      padding = some(Padding(8))
      priority = initPriority(StreamId(888), weight = 124'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame


# headerBlockFragment
block:
  # headerBlockFragment is empty
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment: seq[byte] = @[]
      padding = none(Padding)
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # headerBlockFragment is empty and padding is zero
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment: seq[byte] = @[]
      padding = some(Padding(0))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssertRaises(StreamError):
      discard HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream)

  # headerBlockFragment is seq[byte] of length 1
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment: seq[byte] = @[12'u8]
      padding = some(Padding(0))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame

  # headerBlockFragment is seq[byte] of length 1 and padding is one
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment: seq[byte] = @[12'u8]
      padding = some(Padding(1))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssertRaises(StreamError):
      discard HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream)

  # headerBlockFragment is seq[byte] of length 8888
  block:
    let
      streamId = StreamId(374)
      headerBlockFragment: seq[byte] = newSeq[byte](8888)
      padding = some(Padding(4))
      priority = initPriority(StreamId(876), weight = 12'u8, exclusive = false)
      headersFrame = initHeadersFrame(streamId, headerBlockFragment, padding, some(priority))
      headers = headersFrame.headers

    doAssert HeadersFrame.read(headers, headersFrame.serialize[9 .. ^1].fromByteSeq
                                                  .newStringStream) == headersFrame
