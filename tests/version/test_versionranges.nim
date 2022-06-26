# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/version

let versionRange1 = parseVersionRange(">= 1.0 & <= 1.5")
let versionRange2 = parseVersionRange("1.0")

assert parseVersionRange("== 3.4.2") == parseVersionRange("3.4.2")

assert versionRange1.kind == verIntersect
assert versionRange2.kind == verEq
# An empty version range should give verAny
assert parseVersionRange("").kind == verAny
