# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[logging, os, sequtils, strformat, times]

when defined(withWeave):
  import weave
else:
  import dummythreading

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
  ## Fill a new PackageInfo object using values from the Nimble file.

  proc debugFn(s: string) =
    debug("[initPackageInfo] " & s)

  let nimbleFile = options.getSourceDir().findNimbleFile()
  result.nimbleFile = nimbleFile

  var optionsRef = new Options
  optionsRef[] = options

  var timeStart: float
  if options.debug:
    timeStart = epochTime()
    debugFn("Started querying " & nimbleFile)

  init(Weave)
  let
    name         = spawn nimbleFile.queryString("packageName", optionsRef)
    version      = spawn nimbleFile.queryString("version", optionsRef)
    requires     = spawn nimbleFile.queryArray("requiresData", optionsRef)
    bin          = spawn nimbleFile.queryArray("bin", optionsRef)
    skipDirs     = spawn nimbleFile.queryArray("skipDirs", optionsRef)
    skipFiles    = spawn nimbleFile.queryArray("skipFiles", optionsRef)
    skipExt      = spawn nimbleFile.queryArray("skipExt", optionsRef)
    installDirs  = spawn nimbleFile.queryArray("installDirs", optionsRef)
    installFiles = spawn nimbleFile.queryArray("installFiles", optionsRef)
    installExt   = spawn nimbleFile.queryArray("installExt", optionsRef)
    srcDir       = spawn nimbleFile.queryString("srcDir", optionsRef)

  syncRoot(Weave)
  exit(Weave)

  if options.debug:
    let time = epochTime() - timeStart
    debugFn(fmt"Finished querying {nimbleFile} ({time:.2f} s)")

  result.name         = sync(name)
  result.version      = sync(version)
  result.requires     = sync(requires)
  result.bin          = sync(bin)
  result.skipDirs     = sync(skipDirs)
  result.skipFiles    = sync(skipFiles)
  result.skipExt      = sync(skipExt)
  result.installDirs  = sync(installDirs)
  result.installFiles = sync(installFiles)
  result.installExt   = sync(installExt)
  result.srcDir       = sync(srcDir)
  
  if result.name.len == 0:
    result.name = splitFile(nimbleFile).name

func getSourceDir*(pkgInfo: PackageInfo, options: Options): string =
  ## Returns the directory containing the package source files.
  if pkgInfo.srcDir.len != 0:
    return options.getSourceDir() / pkgInfo.srcDir
  else:
    return options.getSourceDir()

func checkInstallFile(pkgInfo: PackageInfo, sourceDir, file: string): bool =
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

func checkInstallDir(pkgInfo: PackageInfo, sourceDir, dir: string): bool =
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
