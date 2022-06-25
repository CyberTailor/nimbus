# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: "nimflags = -d:release\n"
"""

import nimbs/ninjasyntax

stdout.variable("nimflags", "-d:release")
