# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "binary"

var opts = Options(sourceDir: sourceDir)
opts.setNimBin

let pkgInfo = initPackageInfo(opts)
assert pkgInfo.name == "binary"
assert pkgInfo.version == "1.0"

let files = pkgInfo.getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "tools" / "main.nim"),
  (pcDir, sourceDir / "tools")
]
