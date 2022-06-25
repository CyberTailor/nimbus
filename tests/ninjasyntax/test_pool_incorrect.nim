# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: ""
"""

import nimbs/ninjasyntax

stdout.pool("", "")
stdout.pool("test", "")
stdout.pool("", "5")
