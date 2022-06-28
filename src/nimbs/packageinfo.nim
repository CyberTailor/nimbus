# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os

import nimbleexecutor, options

proc getPackageName*(nimbleFile: string, options: Options): string =
  let packageName = nimbleFile.queryString("packageName", options)
  if packageName.len != 0:
    return packageName
  return splitFile(nimbleFile).name

proc findNimbleFile*(dir: string): string =
  var hits = 0
  for kind, path in walkDir(dir):
    if kind in {pcFile, pcLinkToFile}:
      let ext = path.splitFile.ext
      if ext == ".nimble":
        result = path
        inc hits
  if hits >= 2:
    quit("Only one .nimble file should be present in " & dir)
  elif hits == 0:
    quit("Could not find a file with a .nimble extension inside the " &
         "specified directory: " & dir)
