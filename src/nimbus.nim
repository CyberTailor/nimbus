# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os

import nimbs/common, nimbs/dependencyresolver, nimbs/installerscript,
       nimbs/ninjasyntax, nimbs/options, nimbs/packageinfo, nimbs/version

proc processDependencies(requires: seq[string], options: Options): seq[string] =
  for req in requires:
    let dep = parseRequires(req)
    case dep.name
    of "nim":
      let nimVer = getNimVersion(options)
      if not withinRange(nimVer, dep.ver):
        raise unsatisfiedDependencyError("Unsatisfied Nim dependency")
    else:
      result.add(dep.getPath(options))

proc setup(options: Options) =
  echo "The nimbus build system"
  echo "Version: " & nimbusVersion
  echo "Source dir: " & options.getSourceDir()
  echo "Build dir: " & getCurrentDir()

  let pkgInfo = initPackageInfo(options)
  echo "Project name: " & pkgInfo.name
  echo "Project version: " & pkgInfo.version
  echo "Nim compiler: " & options.getNimBin()
  echo ""

  let depPaths = processDependencies(pkgInfo.requires, options)

  echo "-- Generating installer script"
  let installer = open(installerFileName, fmWrite)
  installer.writeInstallerScript(pkgInfo, options)
  installer.close()

  echo "-- Generating build.ninja"
  let ninja = open("build.ninja", fmWrite)

  ninja.comment("This file is autogenerated by the nimbus build system.")
  ninja.comment("Do not edit by hand.")
  ninja.newline()

  ninja.variable("nim", options.getNimBin())
  ninja.variable("nimbus", getAppFilename())
  ninja.variable("sourcedir", options.getSourceDir())
  ninja.newline()

  ninja.rule("REGENERATE_BUILD",
    command = "$nimbus $sourcedir",
    description = "Regenerating build files.",
    pool = "console",
    generator = true)
  ninja.newline()

  ninja.rule("nimscript",
    command = "$nim --hints:off e $in",
    description = "Executing NimScript file $in",
    pool = "console")
  ninja.newline()

  ninja.comment("Phony build target, always out of date")
  ninja.build(@["PHONY"], rule = "phony")
  ninja.newline()

  ninja.build(@["build.ninja"],
    rule = "REGENERATE_BUILD",
    inputs = @[pkgInfo.nimbleFile])
  ninja.newline()

  ninja.build(@["reconfigure"],
    rule = "REGENERATE_BUILD",
    implicit = @["PHONY"])
  ninja.newline()

  ninja.build(@["install"],
    rule = "nimscript",
    inputs = @[installerFileName],
    implicit = @["PHONY"])
  ninja.close()

when isMainModule:
  var opt = parseCmdLine()
  if opt.showHelp:
    writeHelp() # quits
  opt.setLogger
  opt.setSourceDir
  opt.setNimBin
  opt.setNimbleDir
  opt.setup()
