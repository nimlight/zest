import ../src/zest/frame/bytes


import unittest, math


suite "Serialize":
  test "serialize uint64":
    check:
      serialize(0'u64) == [0'u8, 0, 0, 0, 0, 0, 0, 0]
      serialize(2'u64 ^ 0) == [0'u8, 0, 0, 0, 0, 0, 0, 1]
      serialize(2'u64 ^ 8) == [0'u8, 0, 0, 0, 0, 0, 1, 0]
      serialize(2'u64 ^ 16) == [0'u8, 0, 0, 0, 0, 1, 0, 0]
      serialize(2'u64 ^ 24) == [0'u8, 0, 0, 0, 1, 0, 0, 0]
      serialize(2'u64 ^ 32) == [0'u8, 0, 0, 1, 0, 0, 0, 0]
      serialize(2'u64 ^ 40) == [0'u8, 0, 1, 0, 0, 0, 0, 0]
      serialize(2'u64 ^ 48) == [0'u8, 1, 0, 0, 0, 0, 0, 0]
      serialize(2'u64 ^ 56) == [1'u8, 0, 0, 0, 0, 0, 0, 0]
      serialize(high(uint64)) == [255'u8, 255, 255, 255, 255, 255, 255, 255]

  test "serialize uint32":
    check:
      serialize(0'u32) == [0'u8, 0, 0, 0]
      serialize(2'u32 ^ 0) == [0'u8, 0, 0, 1]
      serialize(2'u32 ^ 8) == [0'u8, 0, 1, 0]
      serialize(2'u32 ^ 16) == [0'u8, 1, 0, 0]
      serialize(2'u32 ^ 24) == [1'u8, 0, 0, 0]
      serialize(high(uint32)) == [255'u8, 255, 255, 255]

  test "serialize uint16":
    check:
      serialize(0'u16) == [0'u8, 0]
      serialize(2'u16 ^ 0) == [0'u8, 1]
      serialize(2'u16 ^ 8) == [1'u8, 0]
      serialize(high(uint16)) == [255'u8, 255]
