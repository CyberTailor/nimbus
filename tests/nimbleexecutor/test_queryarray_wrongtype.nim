# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import json, os, unittest
import nimbs/nimbleexecutor, nimbs/options

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimbleexecutor" / "nimble.nimble"

expect JsonKindError:
  discard nimbleFile.queryArray("license", opts)
