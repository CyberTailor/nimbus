# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "source-whitelist"

let opts = Options(sourceDir: sourceDir)
var pkgInfo = PackageInfo(
  nimbleFile: sourceDir / "source-whitelist.nimble",
  name: "source-whitelist",
  version: "1.0",
  installExt: @["nim"]
)

inferInstallRules(pkgInfo, opts)

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "file1.nim"),
  (pcFile, sourceDir / "file2.nim")
]
