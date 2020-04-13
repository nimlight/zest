import options, streams
import ./errorcodes, ./flags, ./basetypes

export errorcodes, flags, basetypes, options, streams

const
  FrameDefaultMaxLen* = 16384 # 2 ^ 14
  FrameAllowedMaxLen* = 16777215 # 2 ^ 24 - 1 


type
  # +-----------------------------------------------+
  # |                 Length (24)                   |
  # +---------------+---------------+---------------+
  # |   Type (8)    |   Flags (8)   |
  # +-+-------------+---------------+-------------------------------+
  # |R|                 Stream Identifier (31)                      |
  # +=+=============================================================+
  # |                   Frame Payload (0...)                      ...
  # +---------------------------------------------------------------+
  # https://tools.ietf.org/html/rfc7540#section-4
  Frame* = object of RootObj
    headers*: FrameHeaders
    payload*: seq[byte]
