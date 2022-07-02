# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  output: '''#!/usr/bin/env nim e

import strutils

withDir("tests/testerscript"):
  for test in listFiles("tests"):
    if test.startsWith("tests/t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec("/usr/bin/nim --hints:off -d:release --threads:on r " & test)
'''
"""

import os
import nimbs/options, nimbs/testerscript

let opts = Options(sourceDir: "tests" / "testerscript",
                   nim: "/usr/bin/nim",
                   passNimFlags: @["-d:release", "--threads:on"])

stdout.writeTesterScript(opts)
