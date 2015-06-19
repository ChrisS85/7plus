There are various things to know about debugging 7plus.

First, there are more or less 3 methods of debugging:

  * Debugging AHK in Visual Studio: This is the most basic form of debugging and only needs to be done when there are problems that relate to things happening under the hood.
  * Debugging with a dbgp client: I suggest using Notepad++ with the dbgp plugin. A new one will be released shortly with great speed improvements (I already have it). To use it, open the dbgp window in NP++, enable debug mode in 7plus and press WIN + Y. It will break at the current line in code and allow you to step on from there. As for configuration the new version of the plugin should use these settings:
    * Bypass all mapping
    * Use SOURCE command for all files and bypass maps
    * Break at first line when debugging starts
    * Max depth should be at 1 (deeper levels are queried upon expansion in newer version)
    * Refreshing local and global context are neat but take some performance on each step. If it's too slow you can turn these settings off and manually refresh them through the context menu of the windows.
  * Using the ListLines feature of AHK with the source version: Not recommended usually as too much things happen and one can't see everything.

In general, every developer should enable debug mode by enabling debugging on the Misc page or under [General](General.md)->DebugEnabled=1 in Settings.ini.

# Using DebugView #
DebugView is used to see debug log messages when debug mode is enabled. Put the DebugView folder in the 7plus directory and it will be launched and configured automatically upon 7plus startup.