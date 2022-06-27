# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''-- Checking for https://packagea.example.com
--   Found packageA, version 0.5.0
-- Checking for https://example.invalid
'''
"""

import os, unittest
import nimbs/dependencyresolver, nimbs/options, nimbs/version

const
  nimbleDir = "tests" / "dependencyresolver" / "nimbleDir"
  pkgsDir = nimbleDir / "pkgs2"

let
  pkgA: PkgTuple = ("https://packagea.example.com", parseVersionRange(">= 0.1"))
  pkgB: PkgTuple = ("https://example.invalid", parseVersionRange("< 1.0"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger

assert pkgA.getPath(opts) == pkgsDir / "packageA-0.5.0"
expect UnsatisfiedDependencyError:
  discard pkgB.getPath(opts)
