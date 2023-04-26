# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  exitcode: 1
  outputsub: "Only one .nimble file should be present in"
"""

import std/os
import nimbs/packageinfo

const dir = "tests" / "nimble" / "packageinfo" / "2nimble"

discard findNimbleFile(dir)
