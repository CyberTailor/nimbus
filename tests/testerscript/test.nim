# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
"""

import os, strutils, std/tempfiles
import nimbs/options, nimbs/testerscript

const outputExpected = """#!/usr/bin/env nim e

import os, strformat, strutils

const
  nimBin = @/usr/bin/nim@
  nimFlags = @-d:release --threads:on@
  nimCacheDir = @'build dir/nimcache'@

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
