# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

import std/[logging, os, sequtils, strtabs, strformat, strutils]

import nimbs/[common, dependencyresolver, installerscript, ninjasyntax,
              nimbleexecutor, options, packageinfo, packagemetadata,
              querytoolscript, testerscript, version]

proc processDependencies(requires: seq[string], options: Options): seq[string] =
  ## Checks package dependencies and returns list of paths for the Nim compiler,
  ## shell-quoted.
  for req in requires:
    let dep = parseRequires(req)
    case dep.name
    of "nim":
      let nimVer = getNimVersion(options)
      if not withinRange(nimVer, dep.ver):
        raise unsatisfiedDependencyError("Unsatisfied Nim dependency")
      debug("Found suitable Nim version")
    else:
      result.add(dep.getPath(options).quoteShell)

proc application(ninja: File, input, output: string, paths: seq[string]) =
  debug(fmt"[build.ninja] Generating target for application '{output}'")

  let depfile = quoteShell(output & ".d")
  var vars = newStringTable()
  if paths.len != 0:
    vars["paths"] = "-p:" & paths.join(" -p:")

  ninja.build([output],
    rule = "nimc",
    inputs = [input],
    variables = vars
  )

proc task(ninja: File, nimsFile, taskName: string) =
  debug(fmt"[build.ninja] Generating target for task '{taskName}'")

  var vars = newStringTable()
  vars["taskname"] = taskName

  ninja.build([taskName],
    rule = "nimbletask",
    inputs = [nimsFile],
    implicit = ["PHONY"],
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

  debug("Writing query tool script")
  let queryTool = open(options.getBuildDir() / queryToolFileName, fmWrite)
  queryTool.writeQueryToolScript()
  queryTool.close()

  debug("Populating package info")
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
  debug("Copying nimble file to nimbus-private")
  copyFile(pkgInfo.nimbleFile, nimsFile)
  debug("Querying tasks")
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

  debug("[build.ninja] Writing comments")
  ninja.comment("This file is autogenerated by the nimbus build system.")
  ninja.comment("Do not edit by hand.")
  ninja.newline()

  debug("[build.ninja] Writing variables")
  ninja.variable("nim", options.getNimBin())
  ninja.variable("nimbus", getAppFilename())
  ninja.variable("nimflags", options.getNimFlags())
  ninja.variable("sourcedir", options.getSourceDir())
  ninja.variable("nimcache", options.getNimCache())
  ninja.variable("cmdline", options.getCmdLine())
  ninja.newline()

  debug("[build.ninja] Generating 'REGENERATE_BUILD' rule")
  ninja.rule("REGENERATE_BUILD",
    command = "$nimbus $cmdline",
    description = "Regenerating build files.",
    pool = "console",
    generator = true)
  ninja.newline()

  debug("[build.ninja] Generating 'nimscript' rule")
  ninja.rule("nimscript",
    command = "$nim --hints:off e $in",
    description = "Executing NimScript file $in",
    pool = "console")
  ninja.newline()

  if tasks.len != 0:
    # most tasks are supposed to be run from the project root
    debug("[build.ninja] Generating 'nimbletask' rule")
    ninja.rule("nimbletask",
      command = "cd $sourcedir && $nim --hints:off $taskname $in",
      description = "Executing task $taskname",
      pool = "console")
    ninja.newline()

  if pkgInfo.bin.len != 0:
    debug("[build.ninja] Generating 'nimc' rule")
    ninja.rule("nimc",
      command = "$nim $nimflags c --nimcache:$nimcache -o:$out $paths $in",
      description = "Compiling Nim application $out",
      depfile = "$out.d",
      deps = "gcc",
      pool = "console")
    ninja.newline()

  debug("[build.ninja] Generating 'PHONY' target")
  ninja.comment("Phony build target, always out of date")
  ninja.build(["PHONY"], rule = "phony")
  ninja.newline()

  for taskName in tasks:
    ninja.task(nimsFile, taskName)
    ninja.newline()

  debug("[build.ninja] Generating 'build.ninja' target")
  ninja.build(["build.ninja"],
    rule = "REGENERATE_BUILD",
    inputs = [pkgInfo.nimbleFile])
  ninja.newline()

  debug("[build.ninja] Generating 'reconfigure' target")
  ninja.build(["reconfigure"],
    rule = "REGENERATE_BUILD",
    implicit = ["PHONY"])
  ninja.newline()

  for bin in pkgInfo.bin:
    let output = bin.lastPathPart.addFileExt(ExeExt)
    let input = pkgInfo.getSourceDir(options) / bin.addFileExt("nim")
    ninja.application(input, output, depPaths)
    ninja.newline()

  debug("[build.ninja] Generating 'all' target")
  ninja.build(["all"],
    rule = "phony",
    inputs = pkgInfo.bin.mapIt(it.lastPathPart.addFileExt(ExeExt)))
  ninja.default(["all"])
  ninja.newline()

  if nimbleTests:
    debug("[build.ninja] Generating 'test' target")
    ninja.build(["test"],
      rule = "nimscript",
      inputs = [testerFileName],
      implicit = ["PHONY", "all"])
    ninja.newline()

  debug("[build.ninja] Generating 'install' target")
  ninja.build(["install"],
    rule = "nimscript",
    inputs = [installerFileName],
    implicit = ["PHONY", "all"])
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
