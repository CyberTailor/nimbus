# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: CC0-1.0

# Package

version       = "1.1.0"
author        = "Anna"
description   = "A Nim build system"
license       = "BSD"

bin = @["nimbus", "txt2deps"]
srcDir = "src"
installExt = @["nim"]

# Dependencies

requires "nim >= 0.13.0"

# Tasks

task test, "Test nimbus with Testament":
  exec("testament all")

task clean, "Clean test files":
  rmFile("outputGotten.txt")
  rmDir("testresults")
