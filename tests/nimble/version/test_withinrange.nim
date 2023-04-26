# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/version

let versionRange1 = parseVersionRange(">= 1.0 & <= 1.5")
let versionRange2 = parseVersionRange("> 0.1")

let version1 = newVersion("0.1.0")
let version2 = newVersion("1.5.1")
let version3 = newVersion("1.0.2.3.4.5.6.7.8.9.10.11.12")

assert not withinRange(version1, versionRange2)
assert not withinRange(version2, versionRange1)
assert withinRange(version3, versionRange1)

assert version1 notin versionRange2
assert version2 notin versionRange1
assert version3 in versionRange1
