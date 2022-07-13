# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[json, os, osproc, sequtils, strformat, strutils]

import common, options

proc getSeq*(node: JsonNode): seq[string] =
  ## Retrieves the `seq[string]` value of a `JArray JsonNode`.
  return node.to(seq[string])

proc toJsonString*(nimbleFile: string, options: Options): string =
  ## Parse standard NimScript variables using a helper tool.

  let queryToolFile = options.getBuildDir() / queryToolFileName
  if not fileExists(queryToolFile):
    quit(fmt"{queryToolFileName} does not exist")

  let cmd = (
    "$# $# --eval:'include \"$#\"; include \"$#\"'" % [
      getNimBin(options).quoteShell,
      "--hints:off --verbosity:0",
      nimbleFile,
      queryToolFile
    ]
  ).strip()

  var exitCode: int
  (result, exitCode) = execCmdEx(cmd)
  if exitCode != QuitSuccess:
    stderr.write(&"Failed to parse {nimbleFile}\n")
    stderr.write(result)
    quit(QuitFailure)

proc getTasks*(nimsFile: string, options: Options): seq[string] =
  ## Parse NimScript tasks from `nim help` output.

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
