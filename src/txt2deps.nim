# SPDX-FileCopyrightText: 2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[os, parseopt, strutils]

type
  Options = object
    invalidArguments: bool
    showHelp: bool
    target: string
    inFilePath: string
    outFilePath: string

const help* = """
Usage: txt2deps -T:path [-h] [-i:path] [-o:path]
Converts plain list of files to GCC-style depfile.

arguments:
  -h, --help  Show this help message and exit.
  -T:path     Build target.
  -i:path     Input deps file (default: stdin).
  -o:path     Output deps file (default: stdout).
""".strip()

proc writeHelp(status: int = QuitSuccess) =
  echo(help)
  quit(status)

proc parseCmdline(): Options =
  # Init the defaults
  result.invalidArguments = false
  result.showHelp = false

  for kind, key, val in getOpt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key.normalize()
      of "help", "h": result.showHelp = true
      of "t": result.target = val
      of "i": result.inFilePath = val
      of "o": result.outFilePath = val
      else: result.invalidArguments = true
    of cmdArgument:
      result.invalidArguments = true
    of cmdEnd:
      discard

  if result.target.len == 0:
    result.invalidArguments = true

func quoteMake(s: string): string =
  return s.multiReplace(
    (" ", "\\ "),
    ("#", "\\#")
  )

proc main(options: Options) =
  var inFile = stdin
  var outFile = stdout

  if options.inFilePath.len != 0:
    inFile = open(options.inFilePath)

  if options.outFilePath.len != 0:
    outFile = open(options.outFilePath, fmWrite)

  outFile.write(options.target.quoteMake & ": \\" & '\n')
  for line in inFile.lines:
    if line.len == 0 or not fileExists(line):
      continue
    outFile.write('\t' & line.quoteMake & " \\" & '\n')
  outFile.close()

when isMainModule:
  let opt = parseCmdLine()
  if opt.showHelp:
    writeHelp()
  if opt.invalidArguments:
    writeHelp(QuitFailure)
  main(opt)
