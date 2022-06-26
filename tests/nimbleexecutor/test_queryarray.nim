# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nimble.nimble"

# set values
assert nimbleFile.queryArray("bin", opts) == @["nimble"]
assert nimbleFile.queryArray("requiresData", opts) == @["nim >= 0.13.0"]
# unset values
assert nimbleFile.queryArray("skipDirs", opts) == @[]
