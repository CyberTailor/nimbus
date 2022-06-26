# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nimble.nimble"

# set values
assert nimbleFile.queryString("license", opts) == "BSD"
assert nimbleFile.queryString("srcDir", opts) == "src"
# unset values
assert nimbleFile.queryString("backend", opts) == ""
