# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/version

assert not (newVersion("") < newVersion("0.0.0"))
assert newVersion("") < newVersion("1.0.0")
assert newVersion("") < newVersion("0.1.0")
