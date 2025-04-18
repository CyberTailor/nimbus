# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "softened"

let opts = Options(sourceDir: sourceDir)
var pkgInfo = PackageInfo(
  nimbleFile: sourceDir / "softened.nimble",
  name: "softened",
  version: "1.0"
)
inferInstallRules(pkgInfo, opts)

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "softened.nim"),
  (pcFile, sourceDir / "softened" / "file.test"),
  (pcFile, sourceDir / "softened" / "file1.nim"),
  (pcFile, sourceDir / "softened" / "file2.nim"),
  (pcDir, sourceDir / "softened")
]
