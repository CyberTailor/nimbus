# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/os
import nimbs/packagemetadata

const packageDir = "tests" / "nimble" / "packagemetadata" / "packageA-0.1.0"

assert getUrl(packageDir) == "https://example.com"
