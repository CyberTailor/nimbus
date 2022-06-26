# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  exitcode: 1
  outputsub: "Failed to get the value of `loicense` from"
"""

import os
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nimble.nimble"

discard nimbleFile.queryString("loicense", opts)
