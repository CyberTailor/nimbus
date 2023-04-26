# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''-- Checking for packageA
--   Found packageA, version 0.5.0
-- Checking for packageA
--   Found packageA, version 0.5.0
-- Checking for packageB
'''
"""

import std/[os, unittest]
import nimbs/[dependencyresolver, options, version]

const
  nimbleDir = "tests" / "nimble" / "dependencyresolver" / "nimbleDir"
  pkgsDir = nimbleDir / "pkgs2"

let
  pkgAHash: PkgTuple = ("packageA", parseVersionRange("#abc123"))
  pkgA: PkgTuple = ("packageA", parseVersionRange(">= 0.1"))
  pkgB: PkgTuple = ("packageB", parseVersionRange("< 1.0"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger

assert pkgA.getPath(opts) == pkgsDir / "packageA-0.5.0"
assert pkgAHash.getPath(opts) == pkgsDir / "packageA-0.5.0"
expect UnsatisfiedDependencyError:
  discard pkgB.getPath(opts)
