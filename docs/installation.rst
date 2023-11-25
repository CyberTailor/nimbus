.. SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Installation
============

Prerequisites
-------------

The only build dependency is a working Nim compiler.

Runtime dependencies are Nim (needed to run scripts) and either `ninja`_ or
`samu`_.

.. _ninja: https://ninja-build.org/
.. _samu: https://github.com/michaelforney/samurai

Gentoo
------

nimbus is packaged for Gentoo in the GURU ebuild repository.

.. prompt:: bash #

   eselect repository enable guru
   emaint sync -r guru
   emerge dev-nim/nimbus

Other distributions
-------------------

.. image:: https://repology.org/badge/vertical-allrepos/nim:nimbus.svg
   :alt: Packaging status on Repology
   :target: https://repology.org/project/nim:nimbus/versions

Manual installation
-------------------

Using Nimble:

.. prompt:: bash

   nimble install https://git.sysrq.in/nimbus

Using Nim (expert):

.. prompt:: bash

   git clone https://git.sysrq.in/nimbus
   cd nimbus
   nim c src/nimbus
   nim c src/txt2deps
