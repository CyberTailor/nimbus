# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  output: '''#!/usr/bin/env nim e

import json

echo %{
  "packageName": %packageName,
  "version": %version,
  "requiresData": %requiresData,
  "bin": %bin,
  "skipDirs": %skipDirs,
  "skipFiles": %skipFiles,
  "skipExt": %skipExt,
  "installDirs": %installDirs,
  "installFiles": %installFiles,
  "installExt": %installExt,
  "srcDir": %srcDir,
}
'''
"""

import nimbs/querytoolscript

stdout.writeQueryToolScript()
