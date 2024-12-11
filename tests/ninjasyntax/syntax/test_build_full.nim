# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''build main | main.out: nimc main.nim | src1.nim src2.nim || exe1 exe2
  pool = testpool
  dyndep = testdep
  key1 = value1
  key2 = value2
'''
"""

import strtabs

import nimbs/ninjasyntax

var vars = newStringTable()
vars["key1"] = "value1"
vars["key2"] = "value2"

stdout.build(@["main"], "nimc", inputs = @["main.nim"],
            implicit = @["src1.nim", "src2.nim"],
            orderOnly = @["exe1", "exe2"],
            implicitOutputs = @["main.out"],
            variables = vars, pool = "testpool", dyndep = "testdep")
