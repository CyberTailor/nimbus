# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/os
import nimbs/packageinfo

const dir = "tests" / "nimble" / "packageinfo" / "1nimble"

assert findNimbleFile(dir) == dir / "file.nimble"
