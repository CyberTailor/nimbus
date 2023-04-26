# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[algorithm, os]
import nimbs/[options, packageinfo]

const sourceDir = "tests" / "nimble" / "packageinfo" / "source"

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
