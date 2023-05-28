# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/strutils

const
  nimbusVersion* = "1.1.2"

  defaultBinDir* = "/usr/local/bin"
  defaultNimbleDir* = "/opt/nimble"
  nimblePackagesDirName* = "pkgs2"

  packageMetadataFileName* = "nimblemeta.json"
  nimCacheDirName* = "nimcache"

  builderFileName* = "builder.nims"
  installerFileName* = "installer.nims"
  testerFileName* = "tester.nims"
  queryToolFileName* = "querytool.nims"

  nimbleVariables* = [
    "packageName",
    "version",
    "requiresData",
    "bin",
    "skipDirs",
    "skipFiles",
    "skipExt",
    "installDirs",
    "installFiles",
    "installExt",
    "srcDir"
  ]

func tripleQuoted*(s: string): string =
  ## Applies """triple quotes""" to a string.
  return '"'.repeat(3) & s & '"'.repeat(3)
