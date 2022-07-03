# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import algorithm, os
import nimbs/options, nimbs/packageinfo

const sourceDir = "tests" / "packageinfo" / "source"

var opts = Options(sourceDir: sourceDir)
opts.setNimBin

let files = initPackageInfo(opts).getInstallFiles(opts).sorted
assert files == @[
  (pcFile, sourceDir / "source" / "file1.nim"),
  (pcFile, sourceDir / "source" / "file2.nim"),
  (pcDir, sourceDir / "source")
]
