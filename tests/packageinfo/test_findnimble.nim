# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os
import nimbs/packageinfo

const dir = "tests" / "packageinfo" / "1nimble"

assert findNimbleFile(dir) == dir / "file.nimble"
