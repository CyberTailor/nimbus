# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import nimbs/ninjasyntax

assert escape("normal string", body = true) == "normal string"
assert escape("$300", body = true) == "$$300"
assert escape("$$", body = true) == "$$$$"
