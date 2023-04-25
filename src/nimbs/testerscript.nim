# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/strutils

import common, options

proc writeTesterScript*(f: File, options: Options) =
  f.write("""#!/usr/bin/env nim e

import std/[os, strformat, strutils]

const
  nimBin = $1.quoteShell
  nimFlags = $2
  nimCache = $3.quoteShell

withDir($4):
  for test in listFiles("tests"):
    if test.startsWith("tests/t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec(fmt"{nimBin} --hints:off {nimFlags} r --nimcache:{nimCacheDir} {test.quoteShell}")
""" % [options.getNimBin().tripleQuoted,
       options.getNimFlags().tripleQuoted,
       options.getNimCache().tripleQuoted,
       options.getSourceDir().tripleQuoted])
