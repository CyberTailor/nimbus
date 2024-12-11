# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''-- Checking for https://packagea.example.com
--   Found packageA, version 0.5.0
-- Checking for https://Package_A.example.com
--   Found packageA, version 0.5.0
-- Checking for https://example.invalid
'''
"""

import std/[os, unittest]
import nimbs/[dependencyresolver, options, version]

const
  nimbleDir = "tests" / "nimble" / "dependencyresolver" / "nimbleDir"
  pkgsDir = nimbleDir / "pkgs2"

let
  pkgA: PkgTuple = ("https://packagea.example.com", parseVersionRange(">= 0.1"))
  pkgAUnderscore: PkgTuple = ("https://Package_A.example.com", parseVersionRange(">= 0.1"))
  pkgB: PkgTuple = ("https://example.invalid", parseVersionRange("< 1.0"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger

assert pkgA.getPath(opts) == pkgsDir / "packageA-0.5.0"
assert pkgAUnderscore.getPath(opts) == pkgsDir / "packageA-0.5.0"
expect UnsatisfiedDependencyError:
  discard pkgB.getPath(opts)
