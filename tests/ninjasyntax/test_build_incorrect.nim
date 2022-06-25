# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: ""
"""

import nimbs/ninjasyntax

stdout.build(@[""], "")
stdout.build(@[], "nimc")
stdout.build(@["main"], "")
