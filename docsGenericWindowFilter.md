# WindowFilter #

A window filter consists of two controls that are reused in many triggers/conditions and actions to select a specific type of window.

First you can select by what you want to limit the matching windows. The options here are:
  * Program: Enter the program name, such as Notepad.exe. This is not unique, as there could be other processes with the same executable name.
  * Class: Enter a window class name, which is specific to a certain type of window. The case of the name matters here. To figure out window class names, see [here](docsExamplesGetClassName.md).
  * Title: Enter a part of the window title.
  * Active: Simply uses the currently active window.
  * UnderMouse: Uses the window which is currently under the mouse.

# Tips #
  * Note that when there are multiple matching windows, only the first matching one is used.
  * Things like the desktop or the taskbar are also considered as windows by the system.