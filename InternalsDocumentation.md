# Linking to Documentation from within 7plus #
7plus contains help buttons at various places, most notably one for each SubEvent and for each Accessor plugin. The documentation is hosted on Google Code wiki and follows a specific naming scheme:

  * Trigger documentation pages start with "docsTriggers"
  * Condition documentation pages start with "docsConditions"
  * Action documentation pages start with "docsActions"
  * Accessor plugin documentation pages start with "docsAccessor"

Each SubEvent class needs to have a key called WikiLink that contains the name after the static part listed above.

In 7plus the function OpenWikiPage(Pagename) is used.

# Translating localization #
Localization of the documentation can be done by creating a subfolder in the repository under wiki\ with the name of the locale, i.e. de or fr. Inside files with the same name as the original pages need to be placed. Google Code will automatically choose the correct language for displaying and will show merged comments for each page.