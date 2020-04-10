import options
import ./errorcodes, ./basetypes

export errorcodes, basetypes, options

const
  FrameMinLen* = 16384 # 2 ^ 14
  FrameMaxAllowedLen* = 16777215 # 2 ^ 24 - 1 


type
  # +-----------------------------------------------+ |
  # Length (24) | Flags (8) | |
  # +---------------+---------------+---------------+ | Type (8)
  # +-+-------------+---------------+-------------------------------+ |R|
  # Stream Identifier (31) Frame Payload (0...) |
  # +=+=============================================================+ |
  # ..
  # +---------------------------------------------------------------+
  # https://tools.ietf.org/html/rfc7540#section-4
  Frame* = object of RootObj
    headers*: Headers
    payload*: seq[byte]
