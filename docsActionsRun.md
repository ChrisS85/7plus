# Run #
This action runs a program, opens a file with its associated program or opens a URL.
The command should be specified in quotes if you want to add command-line arguments to it.
You may also set the working directory and optionally have 7plus wait until the program has finished running.

# Usage examples #
  * This is most often used in combination with the [hotkey trigger](docsTriggersHotkey.md). You can assign hotkeys to launch programs this way.
  * Using [placeholders](docsGenericPlaceholders.md), you can create many useful context-sensitive actions, like running a file compare on selected files in explorer, or running a script/compile some code from your text-editor (if it has the full path in its window title so ${PT} can be used).