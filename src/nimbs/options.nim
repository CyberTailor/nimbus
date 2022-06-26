# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import logging, os, parseopt, strutils

type
  Options* = object
    showHelp*: bool
    nim*: string # Nim compiler location
    sourceDir*: string
    logger*: ConsoleLogger

const
  help* = """
Usage: nimbus [-h] [--nim:path] sourceDir

positional arguments:
  sourceDir

optional arguments:
  -h, --help    show this help message and exit
  --nim:path    Nim compiler (default: nim).
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
  of "nim": result.nim = val
  else: quit("Unknown option: " & getFlagString(kind, flag, val))

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
