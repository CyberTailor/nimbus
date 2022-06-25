# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''rule nimc
  command = nim c $nimflags --depfile $out.d $in
  description = CC $out
  depfile = $out.d
  deps = gcc
  pool = test
  rspfile = rspfile
  rspfile_content = rspcontent
  generator = 1
  restat = 1
'''
"""

import nimbs/ninjasyntax

stdout.rule("nimc", "nim c $nimflags --depfile $out.d $in",
            description = "CC $out", depfile = "$out.d", deps = "gcc",
            pool = "test", rspfile = "rspfile", rspfile_content = "rspcontent",
            generator = true, restat = true)
