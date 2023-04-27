# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''build main$ program: nimc
build main$:program: nimc
build main$$: nimc
build main$$$ program: nimc
'''
"""

import nimbs/ninjasyntax

stdout.build(["main program".escape], "nimc")
stdout.build(["main:program".escape], "nimc")
stdout.build(["main$".escape], "nimc")
stdout.build(["main$ program".escape], "nimc")
