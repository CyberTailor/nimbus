# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "source-whitelist"

var opts = Options(sourceDir: sourceDir)
opts.setNimBin

let pkgInfo = initPackageInfo(opts)
assert pkgInfo.name == "source-whitelist"
assert pkgInfo.version == "1.0"

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "file1.nim"),
  (pcFile, sourceDir / "file2.nim")
]
