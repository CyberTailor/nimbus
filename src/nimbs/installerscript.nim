# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[os, strformat]

import common, options, packageinfo

proc writeCpFile(f: File, source, dest: string) =
  f.write(&"echo \"-- Installing: \" & destDir & {dest.tripleQuoted}\n")
  f.write(&"cpFile({source.tripleQuoted}, destDir & {dest.tripleQuoted})\n")

proc writeMkDir(f: File, dir: string) =
  f.write(&"echo \"-- Installing: \" & destDir & {dir.tripleQuoted}\n")
  f.write(&"mkDir(destDir & {dir.tripleQuoted})\n")

proc writeChmod(f: File, dest: string) =
  f.write(&"if chmod.len != 0:\n")
  f.write(&"  exec(quoteShellCommand([chmod, \"+x\", destDir & {dest.tripleQuoted}]))\n")

proc writeBinInstaller(f: File, pkgInfo: PackageInfo, options: Options) =
  f.write("""
import os
let chmod = findExe("chmod")

""")

  f.writeMkDir(options.getBinDir())
  for bin in pkgInfo.bin:
    let binWithExt = bin.lastPathPart.addFileExt(ExeExt)
    f.writeCpFile(binWithExt, options.getBinDir() / binWithExt)
    f.writeChmod(options.getBinDir() / binWithExt)

proc writeInstallerScript*(f: File, pkgInfo: PackageInfo, options: Options) =
  f.write("""#!/usr/bin/env nim e
let destDir = getEnv("DESTDIR")

""")

  let packageDir = options.getPkgsDir() / (pkgInfo.name & '-' & pkgInfo.version)
  f.writeMkDir(packageDir)
  f.writeCpFile(pkgInfo.nimbleFile,
                packageDir / pkgInfo.nimbleFile.lastPathPart)

  let nimbleMeta = options.getBuildDir() / packageMetadataFileName
  if fileExists(nimbleMeta):
    f.writeCpFile(nimbleMeta, packageDir / packageMetadataFileName)

  let offset = pkgInfo.getSourceDir(options).len # length of source root
  for entry in pkgInfo.getInstallFiles(options):
    let dest = packageDir / entry.path.substr(offset)
    case entry.kind
    of pcDir:
      f.write('\n')
      f.writeMkDir(dest)
    of pcFile:
      f.writeCpFile(entry.path, dest)
    else: continue

  if pkgInfo.bin.len != 0:
    f.writeBinInstaller(pkgInfo, options)
