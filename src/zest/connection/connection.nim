import ../zpack/zpack


type
  Hpack* = object
    decodedStr: DecodedStr
    dynHeaders: DynHeaders

  H2Connection* = object
    hPack: Hpack


proc initHpack*(strsize, qsize: Natural): Hpack {.inline.} =
  Hpack(decodedStr: initDecodedStr(), dynHeaders: initDynHeaders(strsize, qsize))

proc initH2Connection*(hPack: Hpack): H2Connection {.inline.} =
  H2Connection(hpack: hpack)
