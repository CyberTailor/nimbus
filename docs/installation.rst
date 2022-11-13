.. SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Installation
============

Prerequisites
-------------

The only build dependency is the Nim compiler. However, depfile support is only
available in the `patchset`_. To apply it in Gentoo, build ``dev-lang/nim`` with
``experimental`` USE flag.

.. _patchset: https://git.sysrq.in/nim-patches/

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

Using Nim:

.. prompt:: bash

   git clone https://git.sysrq.in/nimbus
   cd nimbus
   nim c src/nimbus

Using Nimble:

.. prompt:: bash

   nimble install https://git.sysrq.in/nimbus
