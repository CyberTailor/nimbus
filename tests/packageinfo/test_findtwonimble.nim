# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  exitcode: 1
  outputsub: "Only one .nimble file should be present in"
"""

import os
import nimbs/packageinfo

const dir = "tests" / "packageinfo" / "2nimble"

discard findNimbleFile(dir)
