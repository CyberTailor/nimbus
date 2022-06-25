# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: "build main: nimc\n"
"""

import nimbs/ninjasyntax

stdout.build(@["main"], "nimc")
