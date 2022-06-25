# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/ninjasyntax

assert escape("normal string") == "normal string"
assert escape("$300") == "$$300"
assert escape("$$") == "$$$$"
