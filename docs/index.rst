.. SPDX-FileCopyrightText: 2022-2023 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Introduction
============

nimbus is a build system for `Nim`_. It is compatible with the `Nimble`_ package
format, so you can use it to build and install packages from the `Nimble
Directory`_ and other sources.

.. _Nim: https://nim-lang.org/
.. _Nimble: https://nimble.directory/
.. _Nimble Directory: https://nimble.directory/

If you want to learn about how to use nimbus, check out the following resources:

* :doc:`installation`
* :doc:`getting-started`

If you need help, or want to talk to the developers, use our chat rooms:

* IRC: `#nimbus`_ at ``irc.oftc.net``
* Matrix: `#nimbus:sysrq.in`_

.. _#nimbus: https://kiwiirc.com/nextclient/#ircs://irc.oftc.net:+6697/nimbus
.. _#nimbus\:sysrq.in: https://matrix.to/#/#nimbus:sysrq.in

If you find any bugs, please report them on `Bugzilla`_.

.. _Bugzilla: https://bugs.sysrq.in/enter_bug.cgi?product=Software&component=nimbus

Raison d'être
-------------

nimble is a great tool for development but it does not get on well with system
package managers. This project is intended to be used with traditional package
managers (primarly with Gentoo's Portage). But maybe it'll be useful for other
purposes too.
