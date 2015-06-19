# 7plus Version 2.2.0 Changelog #

New Functions:
  * Unicode support
  * 64 bit support
  * Copy Events, Action and Condition
  * Added hotstrings, which can be used to expand abbreviations (e.g. "btw" -> "by the way")
  * Program Launcher Accessor plugin now expands placeholders so you can use placeholders like %ProgramFiles%
  * Added dropping files on Accessor keywords list
  * Added PageUp/Down to Accessor list
  * Added support for Hotkey release events (UP in Hotkey GUI)
  * Added support for auto-updating event configuration so users can receive bugfixes and new events between version updates. As a consequence of this, 7plus now uses a versioning scheme consisting of 4 numbers, where the last one represents the number of applied patches since the last release.
  * Added descriptions for each event for better usability
  * Added "Show window size as tooltip while resizing"

Bugfixes:
  * Fixed CTRL+P accidently being assigned
  * Fixed a scrolling bug in Accessor
  * Fixed Alt+LButton: Move windows option not appearing in settings
  * Fixed a bug pausing the script when Notepad+  **wasn't running/installed
  * Fixed capital C and X not working in Explorer address and search bar
  * Fixed timer window event name not updating when applying settings with changed event name
  * Fixed a bug which caused selected files placeholder not to work on desktop
  * Fixed Windows Installer shortcuts being resolved incorrectly in program launcher start menu scanning
  * Autoupdate is now fully functional for users which have UAC enabled
  * Improved the reliability of the 7plus startup procedure
  * Fixed ${MC} Placeholder not working**

Changes:
  * Removed "Minimize to tray" for 64bit compatibility reasons
  * Removed a redundant event

If you like this program and want to support its development, please consider donating!