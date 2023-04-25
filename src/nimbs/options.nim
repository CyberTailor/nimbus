# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[logging, os, parseopt, strutils]

import common

type
  Options* = object
    showHelp*: bool
    debug*: bool
    nimbleDir*: string
    binDir*: string
    nim*: string # Nim compiler location
    url*: string 
    sourceDir*: string
    buildDir*: string
    logger*: ConsoleLogger
    passNimFlags*: seq[string]
    cmdLine*: seq[string] # only flags, not arguments

const
  help* = """
Usage: nimbus [-h] [--debug] [--nimbleDir:path] [--binDir:path] [--nim:path]
              [--url:url] [nim opts...] sourceDir [buildDir]

positional arguments:
  sourceDir
  buildDir

optional arguments:
  -h, --help          show this help message and exit
  --debug             Show debugging information.
  --nimbleDir:path    Nimble directory (default: $1).
  --binDir:path       Executable directory (default: $2).
  --nim:path          Nim compiler (default: nim).
  --url:url           Package URL.

Unrecognized flags are passed to the Nim compiler.
""" % [defaultNimbleDir, defaultBinDir]

proc writeHelp*() =
  echo(help)
  quit(QuitSuccess)

proc initLogger*(options: Options) =
  if getHandlers().len != 0:
    return

  addHandler(options.logger)
  if options.debug:
    setLogFilter(lvlDebug)
  else:
    setLogFilter(lvlNotice)

proc setLogger*(options: var Options) =
  options.logger = newConsoleLogger()
  options.initLogger()

func getBuildDir*(options: Options): string =
  return options.buildDir

func getNimCache*(options: Options): string =
  return options.getBuildDir() / nimCacheDirName

proc setBuildDir*(options: var Options) =
  if options.buildDir.len != 0:
    options.buildDir = expandTilde(options.buildDir).absolutePath()
    createDir(options.buildDir)
  else:
    options.buildDir = getCurrentDir()

func getSourceDir*(options: Options): string =
  return options.sourceDir

proc setSourceDir*(options: var Options) =
  options.sourceDir = expandTilde(options.sourceDir).absolutePath()
  if not dirExists(options.sourceDir):
    quit("Source directory $1 does not exist" % options.sourceDir)

func getNimbleDir*(options: Options): string =
  ## Get the Nimble directory.
  return options.nimbleDir

func getPkgsDir*(options: Options): string =
  ## Get the packages directory inside the Nimble directory.
  options.getNimbleDir() / nimblePackagesDirName

proc setNimbleDir*(options: var Options) =
  ## Set the Nimble directory.
  if options.nimbleDir.len != 0:
    options.nimbleDir = expandTilde(options.nimbleDir).absolutePath()
  else:
    options.nimbleDir = defaultNimbleDir

func getBinDir*(options: Options): string =
  ## Get the executable directory.
  return options.binDir

proc setBinDir*(options: var Options) =
  ## Set the executable directory.
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

func getNimBin*(options: Options): string =
  return options.nim

func getNimFlags*(options: Options): string =
  return options.passNimFlags.join(" ")

func getFlagString(kind: CmdLineKind, flag, val: string): string =
  ## Make a flag string from components. The result is quoted.
  let prefix =
    case kind
    of cmdShortOption: "-"
    of cmdLongOption: "--"
    else: ""
  if val == "":
    result = prefix & flag
  else:
    result = prefix & flag & ":" & val
  return result.quoteShell

func parseFlag(flag, val: string, result: var Options, kind = cmdLongOption) =
  let f = flag.normalize()
  let flagString = getFlagString(kind, flag, val)

  case f
  of "help", "h": result.showHelp = true
  of "debug": result.debug = true
  of "usedepfile": discard
  of "nimbledir": result.nimbleDir = val
  of "bindir": result.binDir = val
  of "nim": result.nim = val
  of "url": result.url = val
  else: result.passNimFlags.add(flagString)

  result.cmdline.add(flagString)

func parseArgument(key: string, argc: var int, result: var Options) =
  inc argc
  case argc
  of 1: result.sourceDir = key
  of 2: result.buildDir = key
  else: discard

proc parseCmdLine*(): Options =
  # set default values here
  result.debug = false
  result.showHelp = false

  var argc = 0
  for kind, key, val in getOpt():
    case kind
    of cmdArgument:
      parseArgument(key, argc, result)
    of cmdLongOption, cmdShortOption:
      parseFlag(key, val, result, kind)
    of cmdEnd: assert(false) # cannot happen

  if argc notin {1..2}:
    result.showHelp = true

func getCmdLine*(options: Options): string =
  var cmdLine = options.cmdLine
  cmdLine.add(options.getSourceDir().quoteShell)
  cmdLine.add(options.getBuildDir().quoteShell)
  return cmdLine.join(" ")
