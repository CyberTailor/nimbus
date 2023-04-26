# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''{"packageName":"","version":"0.14.0","requiresData":["nim >= 0.13.0"],"bin":["nimble"],"skipDirs":[],"skipFiles":[],"skipExt":[],"installDirs":[],"installFiles":[],"installExt":["nim"],"srcDir":"src"}
'''
"""

import std/[os, tempfiles]
import nimbs/[common, nimbleexecutor, options, querytoolscript]

const nimbleFile = "tests" / "nimble" / "nimbleexecutor" / "nimble.nimble"

let tempDir = createTempDir("nimbustest_", "")
let queryTool = open(tempDir / queryToolFileName, fmWrite)
queryTool.writeQueryToolScript()
queryTool.close()

var opts = Options(buildDir: tempDir)
opts.setBuildDir
opts.setNimBin

echo nimbleFile.toJsonString(opts)

removeDir(tempDir)
