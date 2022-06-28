# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, strformat

import options, packageinfo

proc writeCpFile(f: File, source, dest: string) =
  f.write(&"""echo "-- Installing " & destDir & "{dest}"""")
  f.write('\n')
  f.write(&"""cpFile("{source}", destDir & "{dest}")""")
  f.write('\n')

proc writeMkDir(f: File, dir: string) =
  f.write(&"""mkDir(destDir & "{dir}")""")
  f.write('\n')

proc writeInstallerScript*(f: File, pkgInfo: PackageInfo, options: Options) =
  f.write("""#!/usr/bin/env nim e
let destDir = getEnv("DESTDIR")

""")

  let packageDir = options.getPkgsDir() / (pkgInfo.name & '-' & pkgInfo.version)
  f.writeMkDir(packageDir)
  f.writeCpFile(pkgInfo.nimbleFile, packageDir / pkgInfo.nimbleFile.lastPathPart)

  let offset = pkgInfo.getSourceDir(options).len
  for entry in pkgInfo.getInstallFiles(options):
    let dest = packageDir / entry.path.substr(offset)
    case entry.kind
    of pcDir:
      f.write('\n')
      f.writeMkDir(dest)
    of pcFile:
      f.writeCpFile(entry.path, dest)
    else: continue
