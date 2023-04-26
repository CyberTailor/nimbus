# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  exitcode: 1
  outputsub: "Could not find a file with a .nimble extension inside the specified directory:"
"""

import std/os
import nimbs/packageinfo

const dir = "tests" / "nimble" / "packageinfo" / "0nimble"

discard findNimbleFile(dir)
