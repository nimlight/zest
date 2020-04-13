import streams, endians


template castNumber(result, number: typed): untyped =
  ## Cast ``number`` to array[byte] in big endians order.
  when cpuEndian == bigEndian:
    cast[type(result)](number)
  else:
    let 
      reversedArray = cast[type(result)](number)
      size = reversedArray.len - 1
    for idx in 0 .. size:
      result[idx] = reversedArray[size - idx]
    result

proc serialize*(number: uint64): array[8, byte] {.inline.} =
  ## Serializes uint64 to byte array.
  result = castNumber(result, number)

proc serialize*(number: uint32): array[4, byte] {.inline.} =
  ## Serializes uint32 to byte array.
  result = castNumber(result, number)

proc serialize*(number: uint16): array[2, byte] {.inline.} =
  ## Serializes uint16 to byte array.
  # result[0] = byte(number shr 8'u16)
  # result[1] = byte(number)
  result = castNumber(result, number)

template offset*(p: pointer, n: int): pointer = 
  ## Gets pointer ``p`` of offset ``n``.
  cast[pointer](cast[ByteAddress](p) + n)

template canReadNBytes*(stream: StringStream, length: Natural): bool =
  ## Decides whether can read ``length`` bytes.
  stream.data.len >= stream.getPosition() + length

proc readBEUint64*(strm: Stream): uint64 {.inline.} =
  ## Reads uint64 in big endians order.
  var input = strm.readUint64
  bigEndian64(result.addr, input.addr)

proc readBEUint32*(strm: Stream): uint32 {.inline.} =
  ## Reads uint32 in big endians order.
  var input = strm.readUint32
  bigEndian32(result.addr, input.addr)

proc readBEUint16*(strm: Stream): uint16 {.inline.} =
  ## Reads uint16 in big endians order.
  var input = strm.readUint16
  bigEndian16(result.addr, input.addr)
