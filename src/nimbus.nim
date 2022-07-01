# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import os, sequtils, strtabs, strutils

import nimbs/common, nimbs/dependencyresolver, nimbs/installerscript,
       nimbs/ninjasyntax, nimbs/nimbleexecutor, nimbs/options,
       nimbs/packageinfo, nimbs/packagemetadata, nimbs/testerscript,
       nimbs/version

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

proc application(ninja: File, input, output: string, paths: seq[string]) =
  var vars = newStringTable()
  if paths.len != 0:
    vars["paths"] = "-p:" & paths.join(" -p:")

  ninja.build(@[output],
    rule = "nimc",
    inputs = @[input],
    implicit = @["PHONY"], # FIXME: add depfile support to the Nim compiler
    variables = vars
  )

proc task(ninja: File, nimsFile, taskName: string) =
  var vars = newStringTable()
  vars["taskname"] = taskName

  ninja.build(@[taskName],
    rule = "nimbletask",
    inputs = @[nimsFile],
    implicit = @["PHONY"],
    variables = vars
  )

proc setup(options: Options) =
  # if true, nimble-style tests are used
  var nimbleTests = false

  echo "The nimbus build system"
  echo "Version: " & nimbusVersion
  echo "Source dir: " & options.getSourceDir()
  echo "Build dir: " & options.getBuildDir()

  if options.getSourceDir() == options.getBuildDir():
    quit("In-source builds are not allowed")

  let pkgInfo = initPackageInfo(options)
  echo "Project name: " & pkgInfo.name
  echo "Project version: " & pkgInfo.version
  echo "Nim compiler: " & options.getNimBin()
  echo ""

  let nimbusPriv = options.getBuildDir() / "nimbus-private"
  createDir(nimbusPriv)

  let depPaths = processDependencies(pkgInfo.requires, options)

  let nimsFile =
    nimbusPriv / splitFile(pkgInfo.nimbleFile).name.changeFileExt("nims")
  copyFile(pkgInfo.nimbleFile, nimsFile)
  let tasks = nimsFile.getTasks(options)

  if options.url.len != 0:
    echo "-- Generating nimblemeta.json"
    let nimblemeta = open(options.getBuildDir() / packageMetadataFileName,
                          fmWrite)
    nimblemeta.writeMetaData(options.url)
    nimblemeta.close()

  echo "-- Generating installer script"
  let installer = open(options.getBuildDir() / installerFileName, fmWrite)
  installer.writeInstallerScript(pkgInfo, options)
  installer.close()

  if "test" notin tasks and dirExists(options.getSourceDir() / "tests"):
    echo "-- Generating tester script"
    let tester = open(options.getBuildDir() / testerFileName, fmWrite)
    tester.writeTesterScript(options)
    tester.close()
    nimbleTests = true

  echo "-- Generating build.ninja"
  let ninja = open(options.getBuildDir() / "build.ninja", fmWrite)

  ninja.comment("This file is autogenerated by the nimbus build system.")
  ninja.comment("Do not edit by hand.")
  ninja.newline()

  ninja.variable("nim", options.getNimBin())
  ninja.variable("nimbus", getAppFilename())
  ninja.variable("nimflags", options.getNimFlags())
  ninja.variable("sourcedir", options.getSourceDir())
  ninja.variable("cmdline", options.getCmdLine())
  ninja.newline()

  ninja.rule("REGENERATE_BUILD",
    command = "$nimbus $cmdline",
    description = "Regenerating build files.",
    pool = "console",
    generator = true)
  ninja.newline()

  ninja.rule("nimscript",
    command = "$nim --hints:off e $in",
    description = "Executing NimScript file $in",
    pool = "console")
  ninja.newline()

  if tasks.len != 0:
    # most tasks are supposed to be run from the project root
    ninja.rule("nimbletask",
      command = "cd $sourcedir && $nim --hints:off $taskname $in",
      description = "Executing task $taskname",
      pool = "console")
    ninja.newline()

  if pkgInfo.bin.len != 0:
    ninja.rule("nimc",
      command = "$nim --hints:off $nimflags c -o:$out $paths $in",
      description = "Compiling Nim application $out")
    ninja.newline()

  ninja.comment("Phony build target, always out of date")
  ninja.build(@["PHONY"], rule = "phony")
  ninja.newline()

  for taskName in tasks:
    ninja.task(nimsFile, taskName)
    ninja.newline()

  ninja.build(@["build.ninja"],
    rule = "REGENERATE_BUILD",
    inputs = @[pkgInfo.nimbleFile])
  ninja.newline()

  ninja.build(@["reconfigure"],
    rule = "REGENERATE_BUILD",
    implicit = @["PHONY"])
  ninja.newline()

  for bin in pkgInfo.bin:
    let output = bin.addFileExt(ExeExt)
    let input = pkgInfo.getSourceDir(options) / bin.addFileExt("nim")
    ninja.application(input, output, depPaths)
    ninja.newline()

  ninja.build(@["all"],
    rule = "phony",
    inputs = map(pkgInfo.bin,
                 proc(bin: string): string = bin.addFileExt(ExeExt)))
  ninja.default(@["all"])
  ninja.newline()

  if nimbleTests:
    ninja.build(@["test"],
      rule = "nimscript",
      inputs = @[testerFileName],
      implicit = @["PHONY", "all"])
    ninja.newline()

  ninja.build(@["install"],
    rule = "nimscript",
    inputs = @[installerFileName],
    implicit = @["PHONY", "all"])
  ninja.close()

when isMainModule:
  var opt = parseCmdLine()
  if opt.showHelp:
    writeHelp() # quits
  opt.setLogger
  opt.setSourceDir
  opt.setBuildDir
  opt.setNimBin
  opt.setNimbleDir
  opt.setBinDir
  opt.setup()
