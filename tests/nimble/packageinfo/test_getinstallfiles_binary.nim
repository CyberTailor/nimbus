# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "binary"

let
  opts = Options(sourceDir: sourceDir)
  pkgInfo = PackageInfo(
    nimbleFile: sourceDir / "binary.nimble",
    name: "binary",
    version: "1.0",
    bin: @["tools/main"],
    skipFiles: @["README.md"]
  )

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "tools" / "main.nim"),
  (pcDir, sourceDir / "tools")
]
