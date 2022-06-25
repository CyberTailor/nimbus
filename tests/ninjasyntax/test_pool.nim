# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''pool test
  depth = 5
'''
"""

import nimbs/ninjasyntax

stdout.pool("test", "5")
