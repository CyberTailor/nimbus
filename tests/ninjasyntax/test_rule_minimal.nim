# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''rule nimc
  command = nim c $in
'''
"""

import nimbs/ninjasyntax

stdout.rule("nimc", "nim c $in")
