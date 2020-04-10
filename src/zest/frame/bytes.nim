template castNumber(result, number: typed): untyped =
  when cpuEndian == bigEndian:
    cast[type(result)](number)
  else:
    let 
      reversedArray = cast[type(result)](number)
      size = reversedArray.len - 1
    for idx in 0 .. size:
      result[idx] = reversedArray[size - idx]
    result

proc serialize*(number: uint64): array[8, byte] =
  ## serialize uint64 to byte array
  result = castNumber(result, number)

proc serialize*(number: uint32): array[4, byte] =
  ## serialize uint32 to byte array
  result = castNumber(result, number)

proc serialize*(number: uint16): array[2, byte] =
  ## serialize uint16 to byte array
  # result[0] = byte(number shr 8'u16)
  # result[1] = byte(number)
  result = castNumber(result, number)
