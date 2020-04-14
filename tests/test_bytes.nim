discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; --gc:arc --d:release"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/bytes


import math, streams


# test "toByteSeq" and "fromByteSeq"
block:
  block:
    let 
      str = "\xFF\xFF\xFF\x00\x08\x01\x47\xAE\x14"
      bytes = @[255'u8, 255, 255, 0, 8, 1, 71, 174, 20]

    doAssert str.toByteSeq == bytes
    doAssert bytes.fromByteSeq == str
    doAssert str.toByteSeq.fromByteSeq == str
    doAssert bytes.fromByteSeq.toByteSeq == bytes

  block:
    let
      str = "\xFF\xFF\xFF\x00\x08\x00\x00\x00\x01"
      bytes = [255'u8, 255, 255, 0, 8, 0, 0, 0, 1]
    
    doAssert str.toByteSeq == bytes
    doAssert bytes.fromByteSeq == str
    doAssert str.toByteSeq.fromByteSeq == str
    doAssert bytes.fromByteSeq.toByteSeq == bytes

# test "serialize uint64"
block:
  doAssert serialize(0'u64) == [0'u8, 0, 0, 0, 0, 0, 0, 0]
  doAssert serialize(2'u64 ^ 0) == [0'u8, 0, 0, 0, 0, 0, 0, 1]
  doAssert serialize(2'u64 ^ 8) == [0'u8, 0, 0, 0, 0, 0, 1, 0]
  doAssert serialize(2'u64 ^ 16) == [0'u8, 0, 0, 0, 0, 1, 0, 0]
  doAssert serialize(2'u64 ^ 24) == [0'u8, 0, 0, 0, 1, 0, 0, 0]
  doAssert serialize(2'u64 ^ 32) == [0'u8, 0, 0, 1, 0, 0, 0, 0]
  doAssert serialize(2'u64 ^ 40) == [0'u8, 0, 1, 0, 0, 0, 0, 0]
  doAssert serialize(2'u64 ^ 48) == [0'u8, 1, 0, 0, 0, 0, 0, 0]
  doAssert serialize(2'u64 ^ 56) == [1'u8, 0, 0, 0, 0, 0, 0, 0]
  doAssert serialize(high(uint64)) == [255'u8, 255, 255, 255, 255, 255, 255, 255]

# test "serialize uint32"
block:
  doAssert serialize(0'u32) == [0'u8, 0, 0, 0]
  doAssert serialize(2'u32 ^ 0) == [0'u8, 0, 0, 1]
  doAssert serialize(2'u32 ^ 8) == [0'u8, 0, 1, 0]
  doAssert serialize(2'u32 ^ 16) == [0'u8, 1, 0, 0]
  doAssert serialize(2'u32 ^ 24) == [1'u8, 0, 0, 0]
  doAssert serialize(high(uint32)) == [255'u8, 255, 255, 255]

# test "serialize uint16"
block:
  doAssert serialize(0'u16) == [0'u8, 0]
  doAssert serialize(2'u16 ^ 0) == [0'u8, 1]
  doAssert serialize(2'u16 ^ 8) == [1'u8, 0]
  doAssert serialize(high(uint16)) == [255'u8, 255]

# test "can read n bytes"
block:
  var strm = newStringStream("\x0D\x0E\x05\x15\x0D\x0E\x05\x15")
  doAssert canReadNBytes(strm, 8)
  doAssert canReadNBytes(strm, 7)
  doAssert canReadNBytes(strm, 6)
  doAssert canReadNBytes(strm, 5)
  doAssert canReadNBytes(strm, 4)
  doAssert canReadNBytes(strm, 3)
  doAssert canReadNBytes(strm, 2)
  doAssert canReadNBytes(strm, 1)
  doAssert canReadNBytes(strm, 0)
  doAssert not canReadNBytes(strm, 9)

# test "readBEUint"
block:
  var strm = newStringStream("\x00\x00\x0B\xF4\x9B\xA6\xA1\x59")
  doAssert canReadNBytes(strm, 8)
  doAssert strm.readBEUint64 == 13145211314521'u64
  strm.setPosition(0)
  doAssert canReadNBytes(strm, 4)
  doAssert strm.readBEUint32 == 3060'u32
  strm.setPosition(0)
  doAssert canReadNBytes(strm, 2)
  doAssert strm.readBEUint16 == 0'u16

# test "readBEUint64
block:
  var strm = newStringStream("\x00\x00\x02\x31\xFA\x71\x79\xF3\x00\x01")
  doAssert canReadNBytes(strm, 8)
  doAssert strm.readBEUint64 == 2413678393843'u64

# test "readBEUint32
block:
  var strm = newStringStream("\x71\x79\xF3\x00\x01")
  doAssert canReadNBytes(strm, 4)
  doAssert strm.readBEUint32 == 1903817472'u32

# test "readBEUint16
block:
  var strm = newStringStream("\x05\x22")
  doAssert canReadNBytes(strm, 2)
  doAssert strm.readBEUint16 == 1314'u16
