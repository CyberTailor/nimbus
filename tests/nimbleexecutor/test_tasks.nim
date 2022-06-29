# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, std/tempfiles
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nimble.nimble"

let nimsFile = genTempPath("nimscript_", ".nims")
copyFile(nimbleFile, nimsFile)

assert nimsFile.getTasks(opts) == @["test"]

removeFile(nimsFile)
