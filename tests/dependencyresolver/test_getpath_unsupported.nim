# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''WARN Skipped unsupported package: packageA
WARN Skipped unsupported package: packageA-abc
WARN Skipped unsupported package: packageA-#abc123
-- Checking for packageA
--   Found packageA, version 0.5.0
'''
"""

import os
import nimbs/dependencyresolver, nimbs/options, nimbs/version

const
  nimbleDir = "tests" / "dependencyresolver" / "nimbleDir_unsupported"
  pkgsDir = nimbleDir / "pkgs2"

let pkgA: PkgTuple = ("packageA", parseVersionRange(">= 0.1"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger

assert pkgA.getPath(opts) == pkgsDir / "packageA-0.5.0"
