# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import unittest
import nimbs/version

expect ParseVersionError:
  discard parseVersionRange("abc")

expect ParseVersionError:
  discard parseVersionRange(">> 0.1")

expect ParseVersionError:
  discard parseVersionRange("> 0.1 & > 0.2 & < 1.0")

expect ParseVersionError:
  discard parseVersionRange("0.9 0.10")
