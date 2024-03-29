<!-- SPDX-FileCopyrightText: 2022-2024 Anna <cyber@sysrq.in> -->
<!-- SPDX-License-Identifier: CC0-1.0 -->

nimbus
======

[![Build Status](https://drone.tildegit.org/api/badges/CyberTaIlor/nimbus/status.svg)](https://drone.tildegit.org/CyberTaIlor/nimbus)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8267/badge)](https://www.bestpractices.dev/projects/8267)

**nimbus** is a **Nim** **bu**ild **s**ystem. You can also call in NimBS. Nimja
would also be a clever name but it's already taken (turns out the name "nimbus"
is taken two times already but nobody cares yet).

* [Read the manpage online][man]
* Example use:
    * [nimble.eclass][nimble.eclass]
    * [dev-nim/\* ebuilds][dev-nim]

[man]: https://docs.sysrq.in/nimbus
[nimble.eclass]: https://gitweb.gentoo.org/repo/proj/guru.git/tree/eclass/nimble.eclass
[dev-nim]: https://gitweb.gentoo.org/repo/proj/guru.git/tree/dev-nim


Raison d'être
-------------

[nimble](https://github.com/nim-lang/nimble) is a great tool for development but
it does not get on well with system package managers.

This project is intended to be used with traditional package managers (primarly
with Gentoo's Portage). But maybe it'll be useful for other purposes too.


Development status
------------------

This software is considered [completed][ddv-post] and stable. No new features
are planned, however there will be releases for bug fixes and compatibility
updates.

[ddv-post]: https://drewdevault.com/2021/01/04/A-culture-of-stability-and-reliability.html


Dependencies
------------

This software has no build dependencies other than the Nim standard library.

**nimbus** only generates `build.ninja` files, so you'll need [ninja][ninja]
or [samurai][samurai] to use it.

[ninja]: https://ninja-build.org/
[samurai]: https://github.com/michaelforney/samurai


Installing
----------

* Using nimble:

    `nimble install`

* Using just Nim compiler (expert):

    ```sh
    nim c src/nimbus
    nim c src/txt2deps
    ```


Testing
-------

```sh
$ testament all
```


Packaging
---------

You can track new releases using an [atom feed][atom] provided by GitHub.

[atom]: https://github.com/cybertailor/nimbus/releases.atom


Contributing
------------

Patches and pull requests are welcome. Please use either
[git-send-email(1)][git-send-email] or [git-request-pull(1)][git-request-pull],
addressed to <cyber@sysrq.in>.

Your commit message should conform to the following standard:

```
file/changed: Concice and complete statement of the purpose

This is the body of the commit message.  The line above is the
summary.  The summary should be no more than 72 chars long.  The
body can be more freely formatted, but make it look nice.  Make
sure to reference any bug reports and other contributors.  Make
sure the correct authorship appears.
```

[git-send-email]: https://git-send-email.io/
[git-request-pull]: https://git-scm.com/docs/git-request-pull


IRC
---

You can join the `#nimbus` channel either on [OFTC][oftc] or
[via Matrix][matrix].

[oftc]: https://www.oftc.net/
[matrix]: https://matrix.to/#/#nimbus:sysrq.in


License
-------

* BSD-3-Clause
* Apache-2.0 (`ninja_syntax.nim`)
