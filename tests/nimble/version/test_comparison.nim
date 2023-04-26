# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/version

assert newVersion("1.0") < newVersion("1.4")
assert newVersion("1.0.1") > newVersion("1.0")
assert newVersion("1.0.6") <= newVersion("1.0.6")
assert not (newVersion("0.1.0") < newVersion("0.1"))
assert not (newVersion("0.1.0") > newVersion("0.1"))
assert newVersion("0.1.0") < newVersion("0.1.0.0.1")
assert newVersion("0.1.0") <= newVersion("0.1")
assert newVersion("1") == newVersion("1")
assert newVersion("1.0.2.4.6.1.2.123") == newVersion("1.0.2.4.6.1.2.123")
assert newVersion("1.0.2") != newVersion("1.0.2.4.6.1.2.123")
assert newVersion("1.0.3") != newVersion("1.0.2")
assert newVersion("1") == newVersion("1.0")
