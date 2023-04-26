# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/os
import nimbs/[nimbleexecutor, options]

var opts = Options()
opts.setNimBin

const nimbleFile = "tests" / "nimble" / "nimbleexecutor" / "blank.nimble"

assert nimbleFile.getTasks(opts) == @[]
