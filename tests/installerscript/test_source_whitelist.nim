# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  sortoutput: true
  output: '''

#!/usr/bin/env nim e
cpFile("tests/installerscript/source-whitelist/file1.nim", destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/file1.nim")
cpFile("tests/installerscript/source-whitelist/file2.nim", destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/file2.nim")
cpFile("tests/installerscript/source-whitelist/source-whitelist.nimble", destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/source-whitelist.nimble")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/file1.nim"
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/file2.nim"
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/source-whitelist-1.0/source-whitelist.nimble"
let destDir = getEnv("DESTDIR")
mkDir(destDir & "/opt/nimble/pkgs2/source-whitelist-1.0")
'''
"""

import os
import nimbs/installerscript, nimbs/options, nimbs/packageinfo

var opts = Options(sourceDir: "tests" / "installerscript" / "source-whitelist")
opts.setNimBin
opts.setNimbleDir

let pkgInfo = initPackageInfo(opts)
stdout.writeInstallerScript(pkgInfo, opts)
