# How to get the window class of a specific window #

This example demonstrates how to make a tool to figure out the window class of a specific window. The window class is simply a name that is assigned to a specific type of window.

  * Add a new event.
  * Let's use a hotkey trigger to get the class name.
  * Add a [clipboard](docsActionsClipboard.md) action.
  * Set "Content" to "${Class}".
  * Apply all changes.

When the hotkey is pressed, the class of the active window is copied to the clipboard, and you can use it in [window filter](docsGenericWindowFilter.md) controls now.