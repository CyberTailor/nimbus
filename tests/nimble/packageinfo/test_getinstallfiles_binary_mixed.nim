# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "binary-mixed"

let opts = Options(sourceDir: sourceDir)
var pkgInfo = PackageInfo(
  nimbleFile: sourceDir / "binary-mixed.nimble",
  name: "binary-mixed",
  version: "1.0",
  installExt: @["nim"],
  bin: @["tools/main"],
  skipFiles: @["README.md"]
)

inferInstallRules(pkgInfo, opts)

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "tools" / "main.nim"),
  (pcDir, sourceDir / "tools")
]
