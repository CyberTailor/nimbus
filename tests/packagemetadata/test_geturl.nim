# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os
import nimbs/packagemetadata

const packageDir = "tests" / "packagemetadata" / "packageA-0.1.0"

assert getUrl(packageDir) == "https://example.com"
