# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: BSD-3-Clause

discard """
  joinable: false
  output: '''{
  "url": "https://example.com"
}
'''
"""

import nimbs/packagemetadata

stdout.writeMetaData(url = "https://example.com")
