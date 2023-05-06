# SPDX-FileCopyrightText: 2022 Anna <cyber@sysrq.in>
# SPDX-License-Identifier: CC0-1.0
#
# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'nimbus'
copyright = '2022-2023, Anna (cybertailor) Vyalkova & Nimble Authors'
author = 'Anna (cybertailor) Vyalkova & Nimble Authors'
release = '1.1.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx-prompt',
]

try:
    import notfound.extension
    extensions.append('notfound.extension')

    notfound_no_urls_prefix = True
except ModuleNotFoundError:
    pass

try:
    import sphinx_sitemap
    extensions.append('sphinx_sitemap')

    sitemap_locales = [None]
    sitemap_url_scheme = '{link}'
except ModuleNotFoundError:
    pass

root_doc = 'toc'
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
manpages_url = 'https://docs.sysrq.in/{path}'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'insipid'
html_static_path = ['_static']
html_title = f'{project} {release}'
html_show_sourcelink = False
html_baseurl = 'https://nimbus.sysrq.in/'
