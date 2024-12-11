.. SPDX-FileCopyrightText: 2024 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Release Notes
=============

1.1.4
-----

- Fix resolving dependencies with underscores or different letter case.

- Fix building Sphinx docs.

- Fix running tests for nimbus with Nim 2.2.

1.1.3
-----

- Fix incorrect manpage name for ``txt2deps``.

1.1.2
-----

- Fix generated :file:`build.ninja` files.

- Fix running nimble-style tests.

- Fix building Sphinx docs.

1.1.1
-----

- Fix tests for nimbus.

1.1.0
-----

- **Breaking**: Remove depfiles support via patched Nim.

- **New**: Add depfiles support via the ``txt2deps`` helper utility.

- **New**: Build binaries in two stages: split codegen from compilation.

- Use separate Nim cache directory for each binary.

- Stop disabling Nim hints by default.

- Enable live output for the Nim compiler.

- Relax escaping in Ninja syntax.

- Add Sphinx documentation.

1.0.0
-----

- **New**: Add depfiles support via patched Nim.

0.3.1
-----

- Set default log level to ``notice``.

0.3.0
-----

- Remove multithreading :file:`.nimble` file parsing and query NimScript
  variables in bulk instead.

- Switch to ORC garbage collector.

- Add more debug messages.

0.2.5
-----

- **New**: Add optional support for displaying debug messages.

- Fix deadlocks when too much threads are spawned.

0.2.4
-----

- Move Nim cache directory into the build directory.

- Implement better quoting for generated files.

0.2.3
-----

- Fix running nimble-style tests that expect to be executed from the source
  root.

0.2.2
-----

- Fix the ``all`` target in :file:`build.ninja`.

0.2.1
-----

- Fix build for binaries inside subdirectories.

0.2.0
-----

- Fix the rule that regenerates :file:`build.ninja` file.

- Use multithreading to parse :file:`.nimble` files.

- Improve manpage for nimbus.

- Fix tests for nimbus.

0.1.4
-----

- Pass Nim flags to nimble-style tests.

- Set executable bits via calling ``chmod`` instead of doing it with Nim.

0.1.3
-----

- **New**: Add support for nimble-style tests.

- Set executable bits on installed binaries.

0.1.2
-----

- Fix tests for nimbus.

0.1.1
-----

- **Breaking**: Ban in-source builds.

- **New**: Add support for installing :file:`nimblemeta.json` files.

0.1.0
-----

- First release.
