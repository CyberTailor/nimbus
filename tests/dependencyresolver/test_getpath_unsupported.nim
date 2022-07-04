# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  sortoutput: true
  output: '''--   Found packageA, version 0.5.0
-- Checking for packageA
WARN [initPkgList] Skipped unsupported package: packageA
WARN [initPkgList] Skipped unsupported package: packageA-#abc123
WARN [initPkgList] Skipped unsupported package: packageA-abc
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
