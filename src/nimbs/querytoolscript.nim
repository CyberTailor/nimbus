# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/strformat

import common

proc writeQueryToolScript*(f: File) =
  f.write("""#!/usr/bin/env nim e

import json

echo %{
""")

  for variable in nimbleVariables:
    f.write(&"  \"{variable}\": %{variable},\n")

  f.write("}\n")
