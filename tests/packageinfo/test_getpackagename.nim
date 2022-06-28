# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os
import nimbs/options, nimbs/packageinfo

const nimbleFile = "tests" / "packageinfo" / "1nimble" / "file.nimble"

var opts = Options()
opts.setNimBin

assert nimbleFile.getPackageName(opts) == "file"
