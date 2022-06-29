# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import json, os, osproc, sequtils, strformat, strutils

import options

proc query(nimbleFile, variable: string, options: Options): string =
  ## Return a NimScript variable as a JSON object.
  let cmd = (
    "$# $# --eval:'import json; include \"$#\"; echo %$#'" % [
      getNimBin(options).quoteShell,
      "--hints:off --verbosity:0",
      nimbleFile,
      variable
    ]
  ).strip()

  var exitCode: int
  (result, exitCode) = execCmdEx(cmd)
  if exitCode != QuitSuccess:
    quit(fmt"Failed to get the value of `{variable}` from {nimbleFile}")

proc queryString*(nimbleFile, variable: string, options: Options): string =
  result = nimbleFile.query(variable, options).parseJson().getStr()

proc queryArray*(nimbleFile, variable: string, options: Options): seq[string] =
  result = nimbleFile.query(variable, options).parseJson().to(seq[string])

proc getTasks*(nimsFile: string, options: Options): seq[string] =
  let cmd = (
    "$# $# help $#" % [
      getNimBin(options).quoteShell,
      "--hints:off --verbosity:0",
      nimsFile.quoteShell
    ]
  )

  let (output, exitCode) = execCmdEx(cmd)
  if exitCode != QuitSuccess:
    quit(fmt"Failed to parse tasks from {nimsFile}")

  for line in output.splitLines().filterIt(it.len != 0):
    result.add(line.splitWhitespace()[0])
