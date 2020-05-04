# zest

Http2 protocol for Nim. 

## Task

- [x] Frame
- [ ] Stream
- [ ] Connection
- [ ] Hpack

## Examples

### Frames
```nim
import zest


var strm = newStringStream(...)
let headers = strm.readFrameHeaders

case headers.frameType
of FrameType.Data:
    # read DataFrame
    let frame = DataFrame.read(headers, strm)
    # serialize DataFrame
    discard frame.serialize
of FrameType.Headers:
    let frame = HeadersFrame.read(headers, strm)
    discard frame.serialize
of FrameType.Priority:
    let frame = PriorityFrame.read(headers, strm)
    discard frame.serialize
of FrameType.RstStream:
    let frame = RstStreamFrame.read(headers, strm)
    discard frame.serialize
of FrameType.Settings:
    let frame = SettingsFrame.read(headers, strm)
    discard frame.serialize
of FrameType.PushPromise:
    let frame = PushPromise.read(headers, strm)
    discard frame.serialize
of FrameType.Ping:
    let frame = PingFrame.read(headers, strm)
    discard frame.serialize
of FrameType.GoAway:
    let frame = GoAwayFrame.read(headers, strm)
    discard frame.serialize
of FrameType.WindowUpdate:
    let frame = WindowUpdateFrame.read(headers, strm)
    discard frame.serialize
of FrameType.Continuation:
    let frame = ContinuationFrame.read(headers, strm)
    discard frame.serialize
else:
    discard
```
