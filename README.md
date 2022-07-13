<!-- SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in> -->
<!-- SPDX-License-Identifier: CC0-1.0 -->

nimbus
======

**nimbus** is a **Nim** **bu**ild **s**ystem. You can also call in NimBS. Nimja
would also be a clever name but it's already taken.


Raison d'être
-------------

[nimble](https://github.com/nim-lang/nimble) is a great tool for development but
it does not get on well with system package managers.

This project is intended to be used with traditional package managers (primarly
with Gentoo's Portage). But maybe it'll be useful for other purposes too.


Dependencies
------------

**nimbus** only generates `build.ninja` files, so you'll need [ninja][ninja]
or [samurai][samurai] to use it.

[weave][weave] is used for optional threading support.

[ninja]: https://ninja-build.org/
[samurai]: https://github.com/michaelforney/samurai

[weave]: https://nimble.directory/pkg/weave


Installing
----------

* Using nimble:

    `nimble install`

* Using just Nim compiler:

    `nim c src/nimbus`

Add `-d:withWeave` flag to enable multi-threading.


Testing
-------

```sh
$ testament all
```


Contributing
------------

Patches and pull requests are welcome. Please use either [git-send-email(1)][1]
or [git-request-pull(1)][2], addressed to <cyber@sysrq.in>.

Your commit message should conform to the following standard:

```
file/changed: Concice and complete statement of the purpose

This is the body of the commit message.  The line above is the
summary.  The summary should be no more than 72 chars long.  The
body can be more freely formatted, but make it look nice.  Make
sure to reference any bug reports and other contributors.  Make
sure the correct authorship appears.
```

[1]: https://git-send-email.io/
[2]: https://git-scm.com/docs/git-request-pull


IRC
---

You can join the `#nimbus` channel either on [OFTC][oftc] or
[via Matrix][matrix].

[oftc]: https://www.oftc.net/
[matrix]: https://matrix.to/#/#nimbus:matrix.org


License
-------

* BSD-3-Clause
* Apache-2.0 (`ninja_syntax.nim`)
