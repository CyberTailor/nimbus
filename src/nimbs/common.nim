# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

import std/strutils

const
  nimbusVersion* = "0.3.0"

  defaultBinDir* = "/usr/local/bin"
  defaultNimbleDir* = "/opt/nimble"
  nimblePackagesDirName* = "pkgs2"

  packageMetadataFileName* = "nimblemeta.json"
  nimCacheDirName* = "nimcache"

  installerFileName* = "installer.nims"
  testerFileName* = "tester.nims"

func tripleQuoted*(s: string): string =
  return '"'.repeat(3) & s & '"'.repeat(3)
