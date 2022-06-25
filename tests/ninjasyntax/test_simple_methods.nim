# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''# This is a comment
# 

include samurai.build
subninja kabuto.build
'''
"""

import nimbs/ninjasyntax

stdout.comment("This is a comment")
stdout.comment("")

stdout.newline()

stdout.includeFile("samurai.build")
stdout.includeFile("")

stdout.subninja("kabuto.build")
stdout.subninja("")
