# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[json, logging, os, osproc, sequtils, strformat, strutils, times]

import options

{.experimental: "implicitDeref".}

type SeqString* = seq[string]

proc query(nimbleFile, variable: string,
           options: OptionsRef): string {.thread.} =
  ## Return a NimScript variable as a JSON object.

  proc debugFn(s: string) =
    debug("[query] " & s)
    stdout.flushFile()

  var timeStart: float
  options.initLogger()
  if options.debug:
    timeStart = epochTime()
    debugFn(fmt"Started querying NimScript variable '{variable}'")

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

  if options.debug:
    let time = epochTime() - timeStart
    debugFn(fmt"Finished querying NimScript variable '{variable}' ({time:.2f} s)")

proc queryString*(nimbleFile, variable: string,
                  options: OptionsRef): string {.thread.} =
  result = nimbleFile.query(variable, options).parseJson().getStr()

proc queryArray*(nimbleFile, variable: string,
                 options: OptionsRef): SeqString {.thread.} =
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
