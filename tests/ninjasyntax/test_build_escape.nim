# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''build main$ program: nimc
build main$:program: nimc
build main$$: nimc
build main$$$ program: nimc
'''
"""

import nimbs/ninjasyntax

stdout.build(@["main program"], "nimc")
stdout.build(@["main:program"], "nimc")
stdout.build(@["main$"], "nimc")
stdout.build(@["main$ program"], "nimc")
