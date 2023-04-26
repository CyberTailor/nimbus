# SPDX-FileCopyrightText: 2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
"""

import std/[os, strutils, tempfiles]
import nimbs/[builderscript, options]

const outputExpected = """#!/usr/bin/env nim e

import std/[os, parseopt, strformat, strutils]

mode = Verbose

const
  nimBin = @/usr/bin/nim@.quoteShell
  nimFlags = @-d:release --threads:on@
  nimCache = @build dir/nimcache@
""".replace("@", '"'.repeat(3))

let opts = Options(buildDir: "build dir",
                   nim: "/usr/bin/nim",
                   passNimFlags: @["-d:release", "--threads:on"])

let (cfile, path) = createTempFile("builderscript_", ".nims")
cfile.writeBuilderScript(opts)

cfile.setFilePos(0)
assert cfile.readAll().startsWith outputExpected

cfile.close()
removeFile(path)
