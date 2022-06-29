# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  output: '''#!/usr/bin/env nim e

import strutils

withDir("tests/testerscript/tests"):
  for test in listFiles("."):
    if test.startsWith("./t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec("/usr/bin/nim --hints:off r " & test)
'''
"""

import os
import nimbs/options, nimbs/testerscript

let opts = Options(sourceDir: "tests" / "testerscript", nim: "/usr/bin/nim")

stdout.writeTesterScript(opts)
