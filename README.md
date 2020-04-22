# zest
Http2 for Nim.


```nim
import zest


var strm = newStringStream(...)
let headers = strm.readFrameHeaders

case headers.frameType
of FrameType.Data:
    let frame = DataFrame.read(headers, strm)
of FrameType.Headers:
    let frame = HeadersFrame.read(headers, strm)
of FrameType.Priority:
    let frame = PriorityFrame.read(headers, strm)
of FrameType.RstStream:
    let frame = RstStreamFrame.read(headers, strm)
of FrameType.Settings:
    let frame = SettingsFrame.read(headers, strm)
of FrameType.PushPromise:
    let frame = PushPromise.read(headers, strm)
of FrameType.Ping:
    let frame = PingFrame.read(headers, strm)
of FrameType.GoAway:
    let frame = GoAwayFrame.read(headers, strm)
of FrameType.WindowUpdate:
    let frame = WindowUpdateFrame.read(headers, strm)
of FrameType.Continuation:
    let frame = ContinuationFrame.read(headers, strm)
else:
    discard
```