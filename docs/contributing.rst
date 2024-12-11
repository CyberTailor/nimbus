.. SPDX-FileCopyrightText: 2022-2024 Anna <cyber@sysrq.in>
..
.. SPDX-License-Identifier: BSD-3-Clause

Contributing
============

Any form of contribution is welcome!

Workflow
--------

First, get the source code:

.. prompt:: bash

   git clone https://git.sysrq.in/nimbus

Make some changes and run the tests:

.. prompt:: bash

   nimble test

Commit the changes. Your commit message should conform to the following
standard::

    file/changed: concice and complete statement of the purpose

    This is the body of the commit message.  The line above is the
    summary.  The summary should be no more than 72 chars long.  The
    body can be more freely formatted, but make it look nice.  Make
    sure to reference any bug reports and other contributors.  Make
    sure the correct authorship appears.

Use `git rebase`_ if needed to make commit history look good.

.. _git rebase: https://git-rebase.io/

Finally, send a patch to the developer using `git send-email`_:

.. prompt:: bash

   git send-email --to=cyber@sysrq.in origin/master

.. _git send-email: https://git-send-email.io/


Writing new tests
-----------------

Tests are discovered by the following pattern:

:file:`tests/<category>/<subcategory>/test_<name>.nim`

This project uses the `Testament_` unit testing framework.

.. _Testament: https://nim-lang.org/docs/testament.html#writing-unit-tests


Code style
----------

Should be `NEP-1`_ for all new contributions, however there are no linters in CI
pipelines yet.

.. _NEP-1: https://nim-lang.org/docs/nep1.html
