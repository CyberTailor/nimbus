# SPDX-FileCopyrightText: 2011 Google Inc.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: Apache-2.0
# Original work: 'misc/ninja_syntax.py' in the Ninja source code.

## A module for generating .ninja files.
## RTFM: https://ninja-build.org/manual.html

import std/[sequtils, strformat, strtabs, strutils]

proc newline*(f: File) =
  f.write('\n')

proc comment*(f: File, text: string) =
  f.write(&"# {text}\n")

proc line(f: File, text: string, indent = 0) =
  ## Write indented 'text', followed by a newline.
  f.write(text.indent(indent, "  ") & '\n')

proc variable*(f: File, key, value: string, indent = 0) =
  if key.len != 0 and value.len != 0:
    f.line(fmt"{key} = {value}", indent)

proc pool*(f: File, name, depth: string) =
  if name.len != 0 and depth.len != 0:
    f.line(fmt"pool {name}")
    f.variable("depth", depth, indent = 1)

proc rule*(
    f: File, name, command: string;
    description, depfile, deps, pool, rspfile, rspfileContent = "";
    generator, restat = false
  ) =
  if name.len == 0 or command.len == 0:
    return

  f.line(fmt"rule {name}")
  f.variable("command", command, indent = 1)
  if description.len != 0:
    f.variable("description", description, indent = 1)
  if depfile.len != 0:
    f.variable("depfile", depfile, indent = 1)
  if deps.len != 0:
    f.variable("deps", deps, indent = 1)
  if pool.len != 0:
    f.variable("pool", pool, indent = 1)
  if rspfile.len != 0:
    f.variable("rspfile", rspfile, indent = 1)
  if rspfile_content.len != 0:
    f.variable("rspfile_content", rspfile_content, indent = 1)
  if generator:
    f.variable("generator", "1", indent = 1)
  if restat:
    f.variable("restat", "1", indent = 1)

proc build*(
    f: File, outputs: openArray[string], rule: string;
    inputs, implicit, orderOnly, implicitOutputs: openArray[string] = [];
    variables: StringTableRef = nil; pool, dyndep = ""
  ) =
  # note: filterIt converts openArray[string] to seq[string]
  var outputs = outputs.filterIt(it != "")
  if outputs.len == 0 or rule.len == 0:
    return

  var inputs = inputs.filterIt(it.len != 0)
  var implicit = implicit.filterIt(it.len != 0)
  var orderOnly = orderOnly.filterIt(it.len != 0)
  var implicitOutputs = implicitOutputs.filterIt(it.len != 0)

  if implicit.len != 0:
    inputs.add("|")
    inputs.add(implicit)
  if orderOnly.len != 0:
    inputs.add("||")
    inputs.add(orderOnly)
  if implicitOutputs.len != 0:
    outputs.add("|")
    outputs.add(implicitOutputs)

  let outputsStr = join(outputs, " ")
  let inputsStr = join(@[rule] & inputs, " ")
  f.line(fmt"build {outputsStr}: {inputsStr}")
  if pool.len != 0:
    f.line(fmt"pool = {pool}", indent = 1)
  if dyndep.len != 0:
    f.line(fmt"dyndep = {dyndep}", indent = 1)

  if variables != nil:
    for key, val in variables.pairs:
      f.variable(key, val, indent = 1)

proc `include`*(f: File, path: string) =
  if path.len != 0:
    f.line(fmt"include {path}")

proc subninja*(f: File, path: string) =
  if path.len != 0:
    f.line(fmt"subninja {path}")

proc default*(f: File, targets: openArray[string]) =
  var targets = targets.filterIt(it.len != 0)
  if targets.len != 0:
    f.line("default " & targets.join(" "))


func escape*(s: string, body = false): string =
  ## Escape a string such that it can be embedded into a Ninja file without
  ## further interpretation.
  assert not s.contains("\n"), "Ninja syntax does not allow newlines"
  if body:
    return s.replace("$", "$$")
  else:
    return s.multiReplace(
      ("$", "$$"),
      (" ", "$ "),
      (":", "$:")
    )
