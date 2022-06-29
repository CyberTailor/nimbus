# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  disabled: "win"
  sortoutput: true
  output: '''


  exec(chmod & " +x " & destDir & "/usr/local/bin/main")
#!/usr/bin/env nim e
cpFile("main", destDir & "/usr/local/bin/main")
cpFile("tests/installerscript/binary/binary.nimble", destDir & "/opt/nimble/pkgs2/binary-1.0/binary.nimble")
cpFile("tests/installerscript/binary/main.nim", destDir & "/opt/nimble/pkgs2/binary-1.0/main.nim")
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/binary-1.0/binary.nimble"
echo "-- Installing " & destDir & "/opt/nimble/pkgs2/binary-1.0/main.nim"
echo "-- Installing " & destDir & "/usr/local/bin/main"
if chmod.len != 0:
let chmod = findExe("chmod")mkDir(destDir & "/usr/local/bin")
let destDir = getEnv("DESTDIR")
mkDir(destDir & "/opt/nimble/pkgs2/binary-1.0")
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
