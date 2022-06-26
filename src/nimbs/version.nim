# SPDX-FileCopyrightText: Copyright (C) Dominik Picheta. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

## Module for handling versions and version ranges such as ``>= 1.0 & <= 1.5``

import parseutils, strutils

type
  Version* {.requiresInit.} = object
    version: string

  VersionRangeEnum* = enum
    verLater, # > V
    verEarlier, # < V
    verEqLater, # >= V -- Equal or later
    verEqEarlier, # <= V -- Equal or earlier
    verIntersect, # > V & < V
    verTilde, # ~= V
    verCaret, # ^= V
    verEq, # V
    verAny # *

  VersionRange* = ref VersionRangeObj
  VersionRangeObj = object
    case kind*: VersionRangeEnum
    of verLater, verEarlier, verEqLater, verEqEarlier, verEq:
      ver*: Version
    of verIntersect, verTilde, verCaret:
      verILeft, verIRight: VersionRange
    of verAny:
      nil

  ParseVersionError* = object of CatchableError

const
  notSetVersion* = Version(version: "-1")

proc parseVersionError*(msg: string): ref ParseVersionError =
  result = newException(ParseVersionError, msg)

template `$`*(ver: Version): string = ver.version

proc newVersion*(ver: string): Version =
  if ver.len != 0 and ver[0] notin {'\0'} + Digits:
    raise parseVersionError("Wrong version: " & ver)
  return Version(version: ver)

proc `<`*(ver: Version, ver2: Version): bool =
  # Handling for normal versions such as "0.1.0" or "1.0".
  var sVer = ver.version.split('.')
  var sVer2 = ver2.version.split('.')
  for i in 0..max(sVer.len, sVer2.len)-1:
    var sVerI = 0
    if i < sVer.len:
      discard parseInt(sVer[i], sVerI)
    var sVerI2 = 0
    if i < sVer2.len:
      discard parseInt(sVer2[i], sVerI2)
    if sVerI < sVerI2:
      return true
    elif sVerI == sVerI2:
      discard
    else:
      return false

proc `==`*(ver: Version, ver2: Version): bool =
  var sVer = ver.version.split('.')
  var sVer2 = ver2.version.split('.')
  for i in 0..max(sVer.len, sVer2.len)-1:
    var sVerI = 0
    if i < sVer.len:
      discard parseInt(sVer[i], sVerI)
    var sVerI2 = 0
    if i < sVer2.len:
      discard parseInt(sVer2[i], sVerI2)
    if sVerI == sVerI2:
      result = true
    else:
      return false

proc `<=`*(ver: Version, ver2: Version): bool =
  return (ver == ver2) or (ver < ver2)

proc `==`*(range1: VersionRange, range2: VersionRange): bool =
  if range1.kind != range2.kind : return false
  result = case range1.kind
  of verLater, verEarlier, verEqLater, verEqEarlier, verEq:
    range1.ver == range2.ver
  of verIntersect, verTilde, verCaret:
    range1.verILeft == range2.verILeft and range1.verIRight == range2.verIRight
  of verAny: true

proc withinRange*(ver: Version, ran: VersionRange): bool =
  case ran.kind
  of verLater:
    return ver > ran.ver
  of verEarlier:
    return ver < ran.ver
  of verEqLater:
    return ver >= ran.ver
  of verEqEarlier:
    return ver <= ran.ver
  of verEq:
    return ver == ran.ver
  of verIntersect, verTilde, verCaret:
    return withinRange(ver, ran.verILeft) and withinRange(ver, ran.verIRight)
  of verAny:
    return true

proc contains*(ran: VersionRange, ver: Version): bool =
  return withinRange(ver, ran)

proc getNextIncompatibleVersion(version: Version, semver: bool): Version =
  ## try to get next higher version to exclude according to semver semantic
  var numbers = version.version.split('.')
  let originalNumberLen = numbers.len
  while numbers.len < 3:
    numbers.add("0")
  var zeros = 0
  for n in 0 ..< 2:
    if numbers[n] == "0":
      inc(zeros)
    else: break
  var increasePosition = 0
  if (semver):
    if originalNumberLen > 1:
      case zeros
      of 0:
        increasePosition = 0
      of 1:
        increasePosition = 1
      else:
        increasePosition = 2
  else:
    increasePosition = max(0, originalNumberLen - 2)

  numbers[increasePosition] = $(numbers[increasePosition].parseInt() + 1)
  var zeroPosition = increasePosition + 1
  while zeroPosition < numbers.len:
    numbers[zeroPosition] = "0"
    inc(zeroPosition)
  result = newVersion(numbers.join("."))

proc makeRange(version: Version, op: string): VersionRange =
  if version == notSetVersion:
    raise parseVersionError("A version needs to accompany the operator.")

  case op
  of ">":
    result = VersionRange(kind: verLater, ver: version)
  of "<":
    result = VersionRange(kind: verEarlier, ver: version)
  of ">=":
    result = VersionRange(kind: verEqLater, ver: version)
  of "<=":
    result = VersionRange(kind: verEqEarlier, ver: version)
  of "", "==":
    result = VersionRange(kind: verEq, ver: version)
  of "^=", "~=":
    let
      excludedVersion = getNextIncompatibleVersion(
        version, semver = (op == "^="))
      left = makeRange(version, ">=")
      right = makeRange(excludedVersion, "<")

    result =
      if op == "^=":
        VersionRange(kind: verCaret, verILeft: left, verIRight: right)
      else:
        VersionRange(kind: verTilde, verILeft: left, verIRight: right)
  else:
    raise parseVersionError("Invalid operator: " & op)

proc parseVersionRange*(s: string): VersionRange =
  # >= 1.5 & <= 1.8
  if s.len == 0:
    result = VersionRange(kind: verAny)
    return

  if s[0] == '#':
    # Handle normal versions only.
    result = VersionRange(kind: verAny)
    return

  var i = 0
  var op = ""
  var version = ""
  while i < s.len:
    case s[i]
    of '>', '<', '=', '~', '^':
      op.add(s[i])
    of '&':
      result = VersionRange(kind: verIntersect)
      result.verILeft = makeRange(newVersion(version), op)

      # Parse everything after &
      # Recursion <3
      result.verIRight = parseVersionRange(substr(s, i + 1))

      # Disallow more than one verIntersect. It's pointless and could lead to
      # major unpredictable mistakes.
      if result.verIRight.kind == verIntersect:
        raise parseVersionError(
          "Having more than one `&` in a version range is pointless")
      return
    of '0'..'9', '.':
      version.add(s[i])

    of ' ':
      # Make sure '0.9 8.03' is not allowed.
      if version != "" and i < s.len - 1:
        if s[i+1] in {'0'..'9', '.'}:
          raise parseVersionError(
            "Whitespace is not allowed in a version literal.")
    else:
      raise parseVersionError(
        "Unexpected char in version range '" & s & "': " & s[i])
    inc(i)
  result = makeRange(newVersion(version), op)

proc `$`*(verRange: VersionRange): string =
  case verRange.kind
  of verLater:
    result = "> "
  of verEarlier:
    result = "< "
  of verEqLater:
    result = ">= "
  of verEqEarlier:
    result = "<= "
  of verEq:
    result = ""
  of verIntersect:
    return $verRange.verILeft & " & " & $verRange.verIRight
  of verTilde:
    return " ~= " & $verRange.verILeft
  of verCaret:
    return " ^= " & $verRange.verILeft
  of verAny:
    return "any version"

  result.add($verRange.ver)
