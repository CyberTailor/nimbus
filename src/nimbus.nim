# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/options

proc setup(options: Options) =
  discard

when isMainModule:
  var opt = parseCmdLine()
  if opt.showHelp:
    writeHelp() # quits
  opt.setLogger
  opt.setSourceDir
  opt.setNimBin
  opt.setNimbleDir
  opt.setup()
