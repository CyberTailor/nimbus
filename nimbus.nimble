# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: CC0-1.0

# Package

version       = "0.2.5"
author        = "Anna"
description   = "A Nim build system."
license       = "BSD"

bin = @["nimbus"]
srcDir = "src"
installExt = @["nim"]

# Dependencies

requires "nim >= 1.2.0"
requires "weave"

# Tasks

task test, "Test nimbus with Testament":
  exec("testament all")
