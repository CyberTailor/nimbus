# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''default main1
default main2 main3
'''
"""

import nimbs/ninjasyntax

stdout.default(@["main1"])
stdout.default(@["main2", "main3"])
