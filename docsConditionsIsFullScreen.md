# IsFullScreen #
This condition checks if there is a full-screen application running in foreground. It can use both an include and an exclude list of window class names that can be entered in Misc category in settings. A program that matches an include-list entry is always recognized as a fullscreen application, while a program matching an exclude-list entry is always recognized as a normal program.

# Tips #
  * This condition is used to disable hotkeys that you don't want to use when fullscreen applications such as games are running, because the triggered event might disrupt the fullscreen application.
  * To figure out class names, see [this tutorial](docsExamplesGetClassName.md).