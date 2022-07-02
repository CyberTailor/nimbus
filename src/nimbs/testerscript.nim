# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, osproc, strutils

import options

proc writeTesterScript*(f: File, options: Options) =
  f.write("""#!/usr/bin/env nim e

import strutils

withDir("$#"):
  for test in listFiles("tests"):
    if test.startsWith("tests/t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec("$# --hints:off $# r " & test)
""" % [options.getSourceDir(),
       options.getNimBin().quoteShell,
       options.getNimFlags()])
