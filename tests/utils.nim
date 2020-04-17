import ../src/zest/frame/baseframe
import ../src/zest/frame/headersframe


import strformat


proc `==`*(self, other: StreamId): bool {.borrow.}
proc `$`*(streamId: StreamId): string {.borrow.}
proc `$`*(flag: Flag): string {.borrow.}
proc `$`*(padding: Padding): string {.borrow.}

proc `$`*(s: seq[byte]): string =
  for i in s:
    result.add fmt"{i} "

proc `==`*(self, other: Priority): bool {.inline.} =
  self.exclusive == other.exclusive and self.weight == other.weight and
                                        self.streamId == other.streamId

proc `$`*(priority: Priority): string =
  fmt"{priority.exclusive} {priority.weight} {priority.streamId}"

proc `==`*(self, other: FrameHeaders): bool {.inline.} =
  self.flag == other.flag and self.length == other.length and
                              self.frameType == other.frameType and
                              self.streamId == other.streamId

proc `==`*(self, other: HeadersFrame): bool {.inline.} =
  self.headers == other.headers and self.padding == other.padding and
                                    self.priority == other.priority and
                                    self.headerBlockFragment == other.headerBlockFragment
