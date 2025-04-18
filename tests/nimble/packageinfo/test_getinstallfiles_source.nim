# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "source"

let opts = Options(sourceDir: sourceDir)
var pkgInfo = PackageInfo(
  nimbleFile: sourceDir / "source.nimble",
  name: "source",
  version: "1.0",
  srcDir: "src",
  skipExt: @["test"]
)

inferInstallRules(pkgInfo, opts)

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "src" / "source" / "file1.nim"),
  (pcFile, sourceDir / "src" / "source" / "file2.nim"),
  (pcDir, sourceDir / "src" / "source")
]
