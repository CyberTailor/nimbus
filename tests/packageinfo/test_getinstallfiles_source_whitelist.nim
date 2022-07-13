# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "source-whitelist"

let
  opts = Options(sourceDir: sourceDir)
  pkgInfo = PackageInfo(
    nimbleFile: sourceDir / "source-whitelist.nimble",
    name: "source-whitelist",
    version: "1.0",
    installExt: @["nim"]
  )

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "file1.nim"),
  (pcFile, sourceDir / "file2.nim")
]
