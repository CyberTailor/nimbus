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
  nimCache = $3

type
  Options = object
    target: string
    inFile: string
    outFile: string
    paths: seq[string]

proc build(options: Options) =
  var paths = ""
  if options.paths.len != 0:
    paths = "-p:" & options.paths.join(" -p:")

  exec fmt"{nimBin} {nimFlags} c --genScript:on --nimcache:{nimCache.quoteShell}" &
       fmt" -o:{options.outFile.quoteShell} {paths} {options.inFile.quoteShell}"

  let txt2deps = findExe("txt2deps")
  if txt2deps.len != 0:
    let nimDepsFile = nimCache / options.target.addFileExt("deps")
    let gccDepsFile = options.target.addFileExt("d")
    exec fmt"{txt2deps} -T:{options.target.quoteShell}" &
         fmt" -i:{nimDepsFile.quoteShell} -o:{gccDepsFile.quoteShell}"

proc parseCmdLine(): Options =
  for kind, key, val in getOpt():
    case kind
    of cmdArgument:
      result.inFile = key
    of cmdShortOption:
      case key.normalize()
      of "t":
        result.target = val
        result.outFile = val.addFileExt(ExeExt)
      of "p":
        result.paths.add(val)
      else:
        discard
    of cmdEnd, cmdLongOption:
      discard

let opts = parseCmdLine()
build(opts)
""" % [options.getNimBin().tripleQuoted,
       options.getNimFlags().tripleQuoted,
       options.getNimCache().tripleQuoted])
