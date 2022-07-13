# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

## Dummy Weave API module.

const Weave* = true

func init*(weave: bool) = discard
func exit*(weave: bool) = discard
func syncRoot*(weave: bool) = discard

macro spawn*(fnCall: typed): untyped =
  fnCall

proc sync*[T](val: T): T =
  return val
