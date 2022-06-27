# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import logging, os, osproc, parseutils, sequtils, strformat, strutils

import options, packagemetadata, version

type
  ## Tuple representing an installed package.
  Package = tuple[path: string, name: string, version: Version]

  ## Tuple containing package name and version range.
  PkgTuple* = tuple[name: string, ver: VersionRange]

  UnsatisfiedDependencyError* = object of CatchableError

proc `<`(pkg: Package, pkg2: Package): bool =
  return pkg.version < pkg2.version

proc unsatisfiedDependencyError*(msg: string): ref UnsatisfiedDependencyError =
  result = newException(UnsatisfiedDependencyError, msg)

proc unsupportedPkgWarning(dirName: string) =
  warn("Skipped unsupported package: " & dirName)

proc initPkgList(options: Options): seq[Package] =
  ## Scan the Nimble directory for packages.
  for kind, path in walkDir(options.getPkgsDir):
    if kind in {pcDir, pcLinkToDir}:
      let dirName = path.lastPathPart
      let nameVerPair = dirName.split('-', maxsplit = 1)
      if nameVerPair.len != 2:
        unsupportedPkgWarning(dirName)
        continue

      let name = nameVerPair[0]
      let verStr = nameVerPair[1]

      var version = notSetVersion
      try:
        version = newVersion(verStr)
      except ParseVersionError:
        unsupportedPkgWarning(dirName)
        continue

      result.add (path, name, version)

proc getNimVersion*(options: Options): Version =
  let nimVer = execCmdEx(
    options.getNimBin.quoteShell &
    " --hints:off --verbosity:0" &
    " --eval:'echo NimVersion'").output
  return newVersion(nimVer)

proc getPath*(depPkg: PkgTuple, options: Options): string =
  ## Return a path for using with the `--path` Nim compiler option.
  var pkgList {.global.}: seq[Package] = @[]
  once: pkgList = initPkgList(options)

  echo "-- Checking for " & depPkg.name
  var matchingPkgs: seq[Package] = @[]
  for pkg in pkgList:
    if not withinRange(pkg.version, depPkg.ver):
      continue
    if depPkg.name != pkg.name:
      if depPkg.name != getUrl(pkg.path):
        continue
    matchingPkgs.add(pkg)

  if matchingPkgs.len == 0:
    raise unsatisfiedDependencyError("Unsatisfied dependency: " & depPkg.name)

  let bestPkg = matchingPkgs[matchingPkgs.maxIndex]
  result = bestPkg.path
  echo fmt"--   Found {bestPkg.name}, version " & $bestPkg.version

proc parseRequires*(req: string): PkgTuple =
  try:
    if ' ' in req:
      var i = skipUntil(req, Whitespace)
      result.name = req[0 .. i].strip
      result.ver = parseVersionRange(req[i .. req.len-1])
    elif '#' in req:
      var i = skipUntil(req, {'#'})
      result.name = req[0 .. i-1]
      result.ver = VersionRange(kind: verAny)
    else:
      result.name = req.strip
      result.ver = VersionRange(kind: verAny)
  except ParseVersionError:
    quit("Unable to parse dependency version range: " &
         getCurrentExceptionMsg())

proc `$`*(pkg: Package): string =
  return pkg.name & "@" & $pkg.version

proc `$`*(dep: PkgTuple): string =
  return dep.name & "@" & $dep.ver
