.. SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Getting Started
===============

.. note::
   Make sure the project you want to build uses NimScript package file format.
   INI format is deprecated and not supported by nimbus.

Setup
-----

.. prompt:: bash

   cd my-nim-project
   mkdir build && cd build
   nimbus ..

This command will create a :file:`ninja.build` file in the build directory.

.. seealso:: :manpage:`nimbus.1` manual page

All the following commands need to be called from the build directory.

Compile
-------

.. prompt:: bash

   ninja

This command will build all project binaries, if any. If there are multiple, you
can choose which to build:

.. prompt:: bash

   ninja myprog

Run tasks
---------

A ninja target is created for every Nimble task. You can run them on request:

.. prompt:: bash

   ninja scss

Run tests
---------

.. prompt:: bash

   ninja test

This command will run "test" task (if defined). Otherwise, it will compile and
run all Nim files in the file:`tests` directory beginning with "t" in their
filename.

This behavior is compatible with Nimble.

Install
-------

.. prompt:: bash

   DESTDIR=/tmp/prefix ninja install

This command will install the package (both sources and binaries) into
:file:`/tmp/prefix`.
