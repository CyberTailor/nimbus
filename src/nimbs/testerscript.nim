# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, strutils

import common, options

proc writeTesterScript*(f: File, options: Options) =
  f.write("""#!/usr/bin/env nim e

import os, strformat, strutils

const
  nimBin = $1
  nimFlags = $2
  nimCacheDir = $3

withDir($4):
  for test in listFiles("tests"):
    if test.startsWith("tests/t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec(fmt"{nimBin} --hints:off {nimFlags} r --nimcache:{nimCacheDir} {test.quoteShell}")
""" % [options.getNimBin().quoteShell.tripleQuoted,
       options.getNimFlags().tripleQuoted,
       options.getNimCache().quoteShell.tripleQuoted,
       options.getSourceDir().tripleQuoted])
