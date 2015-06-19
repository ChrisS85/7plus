# 7plus Version 2.1.0 changelog #
_This file is temporary and will be changed in the future_

### New Functions: ###
  * **Accessor** window which serves as a versatile way to access all kinds of things with the keyboard. It also provides useful context menu options and shows CPU load.
  * **Accessor plugins**:
    * **Window Switcher**: Activates windows, shows cpu load/always on top state, allows closing the window/process and setting always on top state
    * **Program Launcher**: Runs programs by typing their names, similar to programs like Launchy or Exekutor. Automatically indexes the running programs so indexing of program files or windows directory should be unnecessary.
    * **File System Viewer**: Browse the file system and execute or open files/folders. Supports autocompletion
    * **Uninstaller**: Uninstall programs or remove them from uninstall list
    * **Google Search**: Quickly search for something using Google
    * **Calculator**: Use Google calculator for quick calculations and unit conversions
    * **Weather**: Quickly access Google Weather
    * **Notes**: Take notes
    * **FastFolders**: Access to FastFolders from anywhere
    * **Notepad++ Tab Switcher**: Activates Notepad++ and shows a specific tab. Uses smart prediction similar to Notepad++ FileSwitcher plugin.
    * **URL**: Opens URLs and keeps a history of entered URLs.
  * **Accessor** may use **user-defined keywords**. This is very useful for web searches.
  * **Events** are now **categorized**. Old users may need to store their custom events prior to upgrade.
  * **FTP Upload** action now uses **FTP profiles** instead of defining the FTP access data separately in each action.
  * New **ExplorerButton** trigger allows to add buttons to the explorer bar that trigger any function, like uploading files, creating a backup of the current folder, open selected files with a specific program,...
  * In addition to the last entry, a button was added to ExplorerButton config menu and FastFolders tab to **remove all explorer buttons** created by 7plus. This can be used to remove any buttons which were erroneously generated.
  * New **ViewMode** action for controlling the visibility of hidden files and file extensions in explorer.
  * 7plus can now be run in **portable mode** by appending -Portable as command line switch. Features that access the registry (mostly explorer bar buttons) won't work in this mode.
  * 7plus can now **run as normal user** when admin privileges aren't available. In this mode certain features (mostly explorer bar buttons) are not accessible. This is configurable in Misc settings tab. When installed in Program Files directory and not running as admin, settings will have to be located in %AppData%\7plus.
  * Added an **apply button** to settings.
  * Added an **uninstaller** that removes all changes made by 7plus.
  * Added a **new placeholder: ${MC}** - Class of window under mouse.
  * Added a **new placeholder: ${MNN}** - ClassNN of control under mouse.
  * Added a **new action: Wait**
### Bugfixes: ###
  * Bug about nonexistent hotkey in settings was fixed.
  * Events, conditions and actions are now removed again if "Add event/condition/action" was used and cancel was pressed.
  * Default settings file accidently contained a translated version of "New textfile" string in previous version.
  * Fixed an error in IsRenaming condition that prevented Backspace and Shift+C while renaming files.
  * Backspace made Explorer/File dialog go upwards in address/search bar.
  * Clipboard history is now stored separately in an XML file, this should get rid of occassionally appearing settings file bloat.
  * Double click on Desktop trigger should now work properly on 32 bit systems. On 64 bit systems it will only work sometimes until the switch to a 64 bit version of Autohotkey is made.
  * A bug causing WindowState action not to work properly was fixed.
  * Fixed selecting files on the desktop, NewFile and NewFolder actions should now work on the desktop in most cases.
  * UACAutorun.exe and ChangeLocation.exe are not needed anymore. Their functionality is now implemented in 7plus.exe.
  * And some others not worth noting

If you like this program and want to support its development, please consider donating!