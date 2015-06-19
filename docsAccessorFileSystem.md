# File System Browser Plugin #

The file system browser plugin allows to enter paths and browse folders in Accessor.

Pressing Enter will either launch the selected file or dive into the selected folder.
When there is more than one result, TAB will toggle through the results. If there is only one result, TAB will act like the Enter key and go into the folder.

To show only file types of a certain kind, you may enter `*`.extensions at the end of the string, e.g. "C:\Downloads\`*`.zip" to only show zip files in the directory.

Opening a file by this method will append it to the [Program launcher plugin's](docsAccessorProgramLauncher.md) cache, so it can be accessed next time by simply typing a part of its filename.

In addition, this plugin allows to:
  * Open the path of a folder/file in explorer or CMD or copying it to the clipboard
  * Running a program with arguments
  * Showing the explorer context menu of the selected item.

## Other uses ##
  * This plugin can be opened in the currently active directory by pressing **CTRL + .** in Explorer or similar windows.
  * If a path is selected when Accessor is opened the contents of the directory will be shown in Accessor.