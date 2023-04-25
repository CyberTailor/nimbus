# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
"""

import os, strutils, std/tempfiles
import nimbs/options, nimbs/testerscript

const outputExpected = """#!/usr/bin/env nim e

import std/[os, strformat, strutils]

const
  nimBin = @/usr/bin/nim@.quoteShell
  nimFlags = @-d:release --threads:on@
  nimCache = @build dir/nimcache@.quoteShell

withDir(@tests/testerscript@):
  for test in listFiles("tests"):
    if test.startsWith("tests/t") and test.endsWith(".nim"):
      echo "-- Running test ", test, "..."
      exec(fmt"{nimBin} --hints:off {nimFlags} r --nimcache:{nimCacheDir} {test.quoteShell}")
""".replace("@", '"'.repeat(3))

let opts = Options(sourceDir: "tests" / "testerscript",
                   buildDir: "build dir",
                   nim: "/usr/bin/nim",
                   passNimFlags: @["-d:release", "--threads:on"])

let (cfile, path) = createTempFile("testerscript_", ".nim")
cfile.writeTesterScript(opts)

cfile.setFilePos(0)
assert cfile.readAll() == outputExpected

cfile.close()
removeFile(path)
