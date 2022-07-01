# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import logging, os, sequtils, threadpool

import nimbleexecutor, options

type
  PackageInfo* = object
    nimbleFile*: string
    name*: string
    version*: string
    requires*: seq[string]
    bin*: seq[string]
    skipDirs*: seq[string]
    skipFiles*: seq[string]
    skipExt*: seq[string]
    installDirs*: seq[string]
    installFiles*: seq[string]
    installExt*: seq[string]
    srcDir*: string

  InstallEntry* = tuple
    kind: PathComponent
    path: string

proc getPackageName*(nimbleFile: string, options: Options): string =
  let packageName = nimbleFile.queryString("packageName", options)
  if packageName.len != 0:
    return packageName
  return splitFile(nimbleFile).name

proc findNimbleFile*(dir: string): string =
  var hits = 0
  for kind, path in walkDir(dir):
    if kind in {pcFile, pcLinkToFile}:
      let ext = path.splitFile.ext
      if ext == ".nimble":
        result = path
        inc hits
  if hits >= 2:
    quit("Only one .nimble file should be present in " & dir)
  elif hits == 0:
    quit("Could not find a file with a .nimble extension inside the " &
         "specified directory: " & dir)

proc initPackageInfo*(options: Options): PackageInfo =
  let nimbleFile = options.getSourceDir().findNimbleFile()

  let name = spawn nimbleFile.getPackageName(options)
  let version = spawn nimbleFile.queryString("version", options)
  let requires = spawn nimbleFile.queryArray("requiresData", options)
  let bin = spawn nimbleFile.queryArray("bin", options)
  let skipDirs = spawn nimbleFile.queryArray("skipDirs", options)
  let skipFiles = spawn nimbleFile.queryArray("skipFiles", options)
  let skipExt = spawn nimbleFile.queryArray("skipExt", options)
  let installDirs = spawn nimbleFile.queryArray("installDirs", options)
  let installFiles = spawn nimbleFile.queryArray("installFiles", options)
  let installExt = spawn nimbleFile.queryArray("installExt", options)
  let srcDir = spawn nimbleFile.queryString("srcDir", options)

  sync()

  result.nimbleFile = nimbleFile
  result.name = ^name
  result.version = ^version
  result.requires = ^requires
  result.bin = ^bin
  result.skipDirs = ^skipDirs
  result.skipFiles = ^skipFiles
  result.skipExt = ^skipExt
  result.installDirs = ^installDirs
  result.installFiles = ^installFiles
  result.installExt = ^installExt
  result.srcDir = ^srcDir

proc getSourceDir*(pkgInfo: PackageInfo, options: Options): string =
  ## Returns the directory containing the package source files.
  if pkgInfo.srcDir.len != 0:
    return options.getSourceDir() / pkgInfo.srcDir
  else:
    return options.getSourceDir()

proc checkInstallFile(pkgInfo: PackageInfo, sourceDir, file: string): bool =
  ## Checks whether ``file`` should be installed.
  ## ``True`` means file should be skipped.
  if file == pkgInfo.nimbleFile:
    # process it separately
    return true

  for ignoreFile in pkgInfo.skipFiles:
    if file == sourceDir / ignoreFile:
      return true

  for ignoreExt in pkgInfo.skipExt:
    if splitFile(file).ext == ('.' & ignoreExt):
      return true

  if splitFile(file).name[0] == '.': return true

proc checkInstallDir(pkgInfo: PackageInfo, sourceDir, dir: string): bool =
  ## Determines whether ``dir`` should be installed.
  ## ``True`` means dir should be skipped.
  for ignoreDir in pkgInfo.skipDirs:
    if dir == sourceDir / ignoreDir:
      return true

  let thisDir = splitPath(dir).tail
  assert thisDir != ""
  if thisDir[0] == '.': return true
  if thisDir == "nimcache": return true

proc getFilesWithExt(dir: string, installExt: seq[string]): seq[InstallEntry] =
  for kind, path in walkDir(dir):
    if kind == pcDir:
      let contents = getFilesWithExt(path, installExt)
      if contents.len != 0:
        result.add (pcDir, path)
        result &= contents
    else:
      if path.splitFile.ext.substr(1) in installExt:
        result.add (pcFile, path)

proc getFilesInDir(dir: string): seq[InstallEntry] =
  for kind, path in walkDir(dir):
    if kind == pcDir:
      let contents = getFilesInDir(path)
      if contents.len != 0:
        result.add (pcDir, path)
        result &= contents
    else:
      result.add (pcFile, path)

proc getFiles(pkgInfo: PackageInfo, dir: string): seq[InstallEntry] =
    for kind, path in walkDir(dir):
      case kind
      of pcDir:
        let skip = pkgInfo.checkInstallDir(dir, path)
        if skip:
          continue
        result.add (kind, path)
        result &= pkgInfo.getFiles(path)
      of pcFile:
        let skip = pkgInfo.checkInstallFile(dir, path)
        if skip:
          continue
        result.add (kind, path)
      else:
        continue

proc getInstallFiles*(pkgInfo: PackageInfo, options: Options): seq[InstallEntry] =
  let sourceDir = pkgInfo.getSourceDir(options)
  let whitelistMode =
          pkgInfo.installDirs.len != 0 or
          pkgInfo.installFiles.len != 0 or
          pkgInfo.installExt.len != 0
  if whitelistMode:
    for file in pkgInfo.installFiles:
      let src = sourceDir / file
      if not fileExists(src):
        warn("Missing file " & src)
        continue
      result.add (pcFile, src)

    for dir in pkgInfo.installDirs:
      let src = sourceDir / dir
      if not dirExists(src):
        warn("Missing directory " & src)
        continue
      result.add (pcDir, src)
      result &= getFilesInDir(src)

    result &= getFilesWithExt(sourceDir, pkgInfo.installExt)
  else:
    result = pkgInfo.getFiles(sourceDir)

  return deduplicate(result)
