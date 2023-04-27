# SPDX-FileCopyrightText: 2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

## This module is used to generate a NimScript file that, when executed, tells
## Nim to generate a build script in a custom JSON format.

import std/strutils

import common, options

proc writeBuilderScript*(f: File, options: Options) =
  f.write("""#!/usr/bin/env nim e

import std/[os, parseopt, strformat, strutils]

mode = Verbose

const
  nimBin = $1.quoteShell
  nimFlags = $2
  nimCacheBaseDir = $3

type
  Options = object
    genScript: bool
    target: string
    targetName: string
    inFile: string
    outFile: string
    paths: seq[string]

proc genScript(options: Options) =
  var paths = ""
  if options.paths.len != 0:
    paths = "-p:" & options.paths.join(" -p:")

  let nimCache = nimCacheBaseDir / options.targetName
  exec fmt"{nimBin} {nimFlags} c --genScript:on --nimcache:{nimCache.quoteShell}" &
       fmt" -o:{options.outFile.quoteShell} {paths} {options.inFile.quoteShell}"

  let txt2deps = findExe("txt2deps")
  if txt2deps.len != 0:
    let nimDepsFile = nimCache / options.targetName.addFileExt("deps")
    let gccDepsFile = options.target.addFileExt("d")
    exec fmt"{txt2deps} -T:{options.target.quoteShell}" &
         fmt" -i:{nimDepsFile.quoteShell} -o:{gccDepsFile.quoteShell}"

proc execScript(options: Options) =
  let nimCache = nimCacheBaseDir / options.targetName
  withDir nimCache:
    exec fmt"{nimBin} {nimFlags} jsonscript --nimcache:{nimCache.quoteShell}" &
         fmt" -o:{options.outFile.quoteShell} {options.inFile.quoteShell}"

proc parseCmdLine(): Options =
  result.genScript = true
  for kind, key, val in getOpt():
    case kind
    of cmdArgument:
      result.inFile = key
    of cmdLongOption, cmdShortOption:
      case key.normalize()
      of "t":
        # full path!
        result.target = val
        result.targetName = val.extractFilename
        result.outFile = val.addFileExt(ExeExt)
      of "p":
        result.paths.add(val)
      of "genscript":
        result.genScript = true
      of "jsonscript":
        result.genScript = false
      else:
        discard
    of cmdEnd:
      discard

let opts = parseCmdLine()
if opts.genScript:
  genScript(opts)
else:
  execScript(opts)
""" % [options.getNimBin().tripleQuoted,
       options.getNimFlags().tripleQuoted,
       options.getNimCacheBaseDir().tripleQuoted])
