# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "source"

let
  opts = Options(sourceDir: sourceDir)
  pkgInfo = PackageInfo(
    nimbleFile: sourceDir / "source.nimble",
    name: "source",
    version: "1.0",
    skipDirs: @["_test"],
    skipFiles: @["README.md"],
    skipExt: @["test"]
  )

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "source" / "file1.nim"),
  (pcFile, sourceDir / "source" / "file2.nim"),
  (pcDir, sourceDir / "source")
]
