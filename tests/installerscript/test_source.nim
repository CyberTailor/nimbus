# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  sortoutput: true
  output: '''


#!/usr/bin/env nim e
cpFile("tests/installerscript/source/source.nimble", destDir & "/opt/nimble/pkgs2/source-1.0/source.nimble")
cpFile("tests/installerscript/source/source/file1.nim", destDir & "/opt/nimble/pkgs2/source-1.0/source/file1.nim")
cpFile("tests/installerscript/source/source/file2.nim", destDir & "/opt/nimble/pkgs2/source-1.0/source/file2.nim")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source.nimble"
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source/file1.nim"
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-1.0/source/file2.nim"
let destDir = getEnv("DESTDIR")
mkDir(destDir & "/opt/nimble/pkgs2/source-1.0")
mkDir(destDir & "/opt/nimble/pkgs2/source-1.0/source")
'''
"""

import os
import nimbs/installerscript, nimbs/options, nimbs/packageinfo

var opts = Options(sourceDir: "tests" / "installerscript" / "source")
opts.setNimBin
opts.setNimbleDir

let pkgInfo = initPackageInfo(opts)
stdout.writeInstallerScript(pkgInfo, opts)
