# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: CC0-1.0

# Package

version       = "0.1.0"
author        = "Anna"
description   = "A Nim build system."
license       = "BSD"

bin = @["nimbus"]
srcDir = "src"

# Dependencies

requires "nim >= 0.13.0"
