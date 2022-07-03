# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "binary"

var opts = Options(sourceDir: sourceDir)
opts.setNimBin

let files = initPackageInfo(opts).getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "tools" / "main.nim"),
  (pcDir, sourceDir / "tools")
]
