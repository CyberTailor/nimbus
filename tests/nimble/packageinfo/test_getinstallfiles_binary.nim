# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "binary"

let opts = Options(sourceDir: sourceDir)
var pkgInfo = PackageInfo(
  nimbleFile: sourceDir / "binary.nimble",
  name: "binary",
  version: "1.0",
  bin: @["tools/main"],
  skipFiles: @["README.md"]
)

inferInstallRules(pkgInfo, opts)

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcDir, sourceDir / "tools")
]
