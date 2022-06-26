# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  exitcode: 1
  outputsub: "Failed to get the value of `license` from"
"""

import os
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nibble.nibble"

discard nimbleFile.queryString("license", opts)
