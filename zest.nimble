# Package

version       = "0.1.0"
author        = "flywind"
description   = "Http2 for Nim."
license       = "BSD 3-Clause"
srcDir        = "src"



# Dependencies

requires "nim >= 1.2.0"


task tests, "Run all tests":
  exec "nim c -r tests/test_all.nim"
