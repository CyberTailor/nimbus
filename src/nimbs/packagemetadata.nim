# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import json, os, streams

import common

proc getUrl*(packageDir: string): string =
  let path = packageDir / packageMetadataFileName
  if not fileExists(path):
    return ""

  let json = parseJson(path.newFileStream, filename = path)
  if "url" notin json:
    return ""

  return json["url"].getStr()

proc writeMetaData*(f: File, url: string) =
  let json = %* {"url": url}
  f.write(json.pretty)
