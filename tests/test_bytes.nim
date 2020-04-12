discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "-d:release"
  targets:  "c cpp"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""
import ../src/zest/frame/bytes


import math


# test "serialize uint64":
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

# test "serialize uint32":
block:
  doAssert serialize(0'u32) == [0'u8, 0, 0, 0]
  doAssert serialize(2'u32 ^ 0) == [0'u8, 0, 0, 1]
  doAssert serialize(2'u32 ^ 8) == [0'u8, 0, 1, 0]
  doAssert serialize(2'u32 ^ 16) == [0'u8, 1, 0, 0]
  doAssert serialize(2'u32 ^ 24) == [1'u8, 0, 0, 0]
  doAssert serialize(high(uint32)) == [255'u8, 255, 255, 255]

# test "serialize uint16":
block:
  doAssert serialize(0'u16) == [0'u8, 0]
  doAssert serialize(2'u16 ^ 0) == [0'u8, 1]
  doAssert serialize(2'u16 ^ 8) == [1'u8, 0]
  doAssert serialize(high(uint16)) == [255'u8, 255]
