# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  output: '''#!/usr/bin/env nim e
let destDir = getEnv("DESTDIR")

mkDir(destDir & "/opt/nimble/pkgs2/source-1.0")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source.nimble"
cpFile("tests/installerscript/source/source.nimble", destDir & "/opt/nimble/pkgs2/source-1.0/source.nimble")

mkDir(destDir & "/opt/nimble/pkgs2/source-1.0/source")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source/file1.nim"
cpFile("tests/installerscript/source/source/file1.nim", destDir & "/opt/nimble/pkgs2/source-1.0/source/file1.nim")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source/file2.nim"
cpFile("tests/installerscript/source/source/file2.nim", destDir & "/opt/nimble/pkgs2/source-1.0/source/file2.nim")
'''
"""

import os
import nimbs/installerscript, nimbs/options, nimbs/packageinfo

var opts = Options(sourceDir: "tests" / "installerscript" / "source")
opts.setNimBin
opts.setNimbleDir

let pkgInfo = initPackageInfo(opts)
stdout.writeInstallerScript(pkgInfo, opts)
