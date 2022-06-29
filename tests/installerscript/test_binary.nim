# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  output: '''#!/usr/bin/env nim e
let destDir = getEnv("DESTDIR")

mkDir(destDir & "/opt/nimble/pkgs2/binary-1.0")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/binary-1.0/binary.nimble"
cpFile("tests/installerscript/binary/binary.nimble", destDir & "/opt/nimble/pkgs2/binary-1.0/binary.nimble")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/binary-1.0/main.nim"
cpFile("tests/installerscript/binary/main.nim", destDir & "/opt/nimble/pkgs2/binary-1.0/main.nim")

mkDir(destDir & "/usr/local/bin")
echo "-- Installing " & destDir & "/usr/local/bin/main"
cpFile("main", destDir & "/usr/local/bin/main")
'''
"""

import os
import nimbs/installerscript, nimbs/options, nimbs/packageinfo

var opts = Options(sourceDir: "tests" / "installerscript" / "binary")
opts.setNimBin
opts.setNimbleDir
opts.setBinDir

let pkgInfo = initPackageInfo(opts)
stdout.writeInstallerScript(pkgInfo, opts)
