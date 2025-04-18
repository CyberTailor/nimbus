# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022-2025 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[json, logging, os, sequtils]

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

proc inferInstallRules*(pkgInfo: var PackageInfo, options: Options) =
  # Binary packages shouldn't install .nim files by default.
  # (As long as the package info doesn't explicitly specify what should be
  # installed.)
  let installInstructions =
    pkgInfo.installDirs.len + pkgInfo.installExt.len + pkgInfo.installFiles.len
  if installInstructions == 0 and pkgInfo.bin.len > 0 and pkgInfo.name != "nim":
    pkgInfo.skipExt.add("nim")

  # When a package doesn't specify a `srcDir` it's fair to assume that
  # the .nim files are in the root of the package. So we can explicitly select
  # them and prevent the installation of anything else. The user can always
  # override this with `installFiles`.
  if pkgInfo.srcDir == "":
    if dirExists(options.getSourceDir() / pkgInfo.name):
      pkgInfo.installDirs.add(pkgInfo.name)
    if fileExists(options.getSourceDir() / pkgInfo.name.addFileExt("nim")):
      pkgInfo.installFiles.add(pkgInfo.name.addFileExt("nim"))

  # Always skip binaries.
  pkgInfo.skipFiles &= pkgInfo.bin

proc initPackageInfo*(options: Options): PackageInfo =
  ## Fill a new PackageInfo object using values from the Nimble file.

  let nimbleFile = options.getSourceDir().findNimbleFile()
  result.nimbleFile = nimbleFile

  let variables = nimbleFile.toJsonString(options).parseJson()
  result.name         = variables["packageName"].getStr()
  result.version      = variables["version"].getStr()
  result.requires     = variables["requiresData"].getSeq()
  result.bin          = variables["bin"].getSeq()
  result.skipDirs     = variables["skipDirs"].getSeq()
  result.skipFiles    = variables["skipFiles"].getSeq()
  result.skipExt      = variables["skipExt"].getSeq()
  result.installDirs  = variables["installDirs"].getSeq()
  result.installFiles = variables["installFiles"].getSeq()
  result.installExt   = variables["installExt"].getSeq()
  result.srcDir       = variables["srcDir"].getStr()
  
  if result.name.len == 0:
    result.name = splitFile(nimbleFile).name

  # Apply rules to infer which files should/shouldn't be installed.
  # https://github.com/nim-lang/nimble/issues/469
  inferInstallRules(result, options)

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

proc getFiles(pkgInfo: PackageInfo, sourceDir, dir: string): seq[InstallEntry] =
  for kind, path in walkDir(dir):
    case kind
    of pcDir:
      let skip = pkgInfo.checkInstallDir(sourceDir, path)
      if skip:
        continue
      result.add (kind, path)
      result &= pkgInfo.getFiles(sourceDir, path)
    of pcFile:
      let skip = pkgInfo.checkInstallFile(sourceDir, path)
      if skip:
        continue
      result.add (kind, path)
    else:
      continue

proc getFiles(pkgInfo: PackageInfo, sourceDir: string): seq[InstallEntry] =
  pkgInfo.getFiles(sourceDir, sourceDir)

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
