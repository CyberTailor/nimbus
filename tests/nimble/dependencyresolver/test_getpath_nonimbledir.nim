# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
"""

import std/[os, unittest]
import nimbs/[dependencyresolver, options, version]

const nimbleDir = "tests" / "nimble" / "dependencyresolver" / "notexists"
let pkgA: PkgTuple = ("packageA", parseVersionRange(">= 0.1"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger
opts.setNimbleDir

expect UnsatisfiedDependencyError:
  discard pkgA.getPath(opts)
