# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, unittest
import nimbs/dependencyresolver, nimbs/options, nimbs/version

const nimbleDir = "tests" / "dependencyresolver" / "notexists"
let pkgA: PkgTuple = ("packageA", parseVersionRange(">= 0.1"))

var opts = Options(nimbleDir: nimbleDir)
opts.setLogger
opts.setNimbleDir

expect UnsatisfiedDependencyError:
  discard pkgA.getPath(opts)
