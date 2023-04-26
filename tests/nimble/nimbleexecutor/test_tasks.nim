# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[os, tempfiles]
import nimbs/[nimbleexecutor, options]

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimble" / "nimbleexecutor" / "nimble.nimble"

let nimsFile = genTempPath("nimscript_", ".nims")
copyFile(nimbleFile, nimsFile)

assert nimsFile.getTasks(opts) == @["test"]

removeFile(nimsFile)
