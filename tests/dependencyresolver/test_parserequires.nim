# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/dependencyresolver, nimbs/version

assert parseRequires("nim >= 1.0") == ("nim", parseVersionRange(">= 1.0"))
assert parseRequires("packageA") == ("packageA", VersionRange(kind: verAny))
assert parseRequires("packageA#head") == ("packageA", VersionRange(kind: verAny))
assert parseRequires("packageA#abc123") == ("packageA", parseVersionRange("#abc123"))
