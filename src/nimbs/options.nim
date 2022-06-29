# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import logging, os, parseopt, strutils

import common

type
  Options* = object
    showHelp*: bool
    nimbleDir*: string
    binDir*: string
    nim*: string # Nim compiler location
    sourceDir*: string
    logger*: ConsoleLogger
    passNimFlags*: seq[string]

const
  help* = """
Usage: nimbus [-h] [--nimbleDir:path] [--binDir:path] [--nim:path] [nim opts...]
              sourceDir

positional arguments:
  sourceDir

optional arguments:
  -h, --help          show this help message and exit
  --nimbleDir:path    Nimble directory (default: /opt/nimble).
  --binDir:path       Executable directory (default: /usr/local/bin).
  --nim:path          Nim compiler (default: nim).

Unrecognized flags are passed to the Nim compiler.
"""

proc writeHelp*() =
  echo(help)
  quit(QuitSuccess)

proc setLogger*(options: var Options) =
  options.logger = newConsoleLogger()
  addHandler(options.logger)

proc getSourceDir*(options: Options): string =
  return options.sourceDir

proc setSourceDir*(options: var Options) =
  options.sourceDir = expandTilde(options.sourceDir).absolutePath()
  if not dirExists(options.sourceDir):
    quit("Source directory $1 does not exist" % options.sourceDir)

proc getNimbleDir*(options: Options): string =
  return options.nimbleDir

proc getPkgsDir*(options: Options): string =
  options.getNimbleDir() / nimblePackagesDirName

proc setNimbleDir*(options: var Options) =
  if options.nimbleDir.len != 0:
    options.nimbleDir = expandTilde(options.nimbleDir).absolutePath()
  else:
    options.nimbleDir = defaultNimbleDir

proc getBinDir*(options: Options): string =
  return options.binDir

proc setBinDir*(options: var Options) =
  if options.binDir.len != 0:
    options.binDir = expandTilde(options.binDir).absolutePath()
  else:
    options.binDir = defaultBinDir

proc setNimBin*(options: var Options) =
  # Find nim binary and set into options
  if options.nim.len != 0:
    # --nim:<path> takes priority...
    if options.nim.splitPath().head.len == 0:
      # Just filename, search in PATH - nim_temp shortcut
      let pnim = findExe(options.nim)
      if pnim.len != 0:
        options.nim = pnim
      else:
        quit("Unable to find `$1` in $PATH" % options.nim)
    elif not options.nim.isAbsolute():
      # Relative path
      options.nim = expandTilde(options.nim).absolutePath()

    if not fileExists(options.nim):
      quit("Unable to find `$1`" % options.nim)
  else:
    # Search PATH
    let pnim = findExe("nim")
    if pnim.len != 0:
      options.nim = pnim

    if options.nim.len == 0:
      # Nim not found in PATH
      quit("Unable to find `nim` binary - add to $PATH or use `--nim`")

proc getNimBin*(options: Options): string =
  return options.nim

proc getNimFlags*(options: Options): string =
  return options.passNimFlags.join(" ")

proc getFlagString(kind: CmdLineKind, flag, val: string): string =
  let prefix =
    case kind
    of cmdShortOption: "-"
    of cmdLongOption: "--"
    else: ""
  if val == "":
    return prefix & flag
  else:
    return prefix & flag & ":" & val

proc parseFlag*(flag, val: string, result: var Options, kind = cmdLongOption) =

  let f = flag.normalize()

  case f
  of "help", "h": result.showHelp = true
  of "nimbledir": result.nimbleDir = val
  of "bindir": result.binDir = val
  of "nim": result.nim = val
  else: result.passNimFlags.add(getFlagString(kind, flag, val))

proc parseCmdLine*(): Options =
  result = Options()

  var argc = 0
  for kind, key, val in getOpt():
    case kind
    of cmdArgument:
      inc argc
      result.sourceDir = key
    of cmdLongOption, cmdShortOption:
      parseFlag(key, val, result, kind)
    of cmdEnd: assert(false) # cannot happen

  if argc != 1:
    result.showHelp = true
