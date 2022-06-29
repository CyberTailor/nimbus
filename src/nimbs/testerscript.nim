# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, osproc, strutils

import options

proc writeTesterScript*(f: File, options: Options) =
  let testsDir = options.getSourceDir() / "tests"

  f.write("""#!/usr/bin/env nim e

import strutils

withDir("$#"):
  for test in listFiles("."):
    if test.startsWith("./t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec("$# --hints:off $# r " & test)
""" % [testsDir, getNimBin(options).quoteShell, options.passNimFlags.join(" ")])
