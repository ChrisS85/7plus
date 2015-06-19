# 7plus Version 2.6.0 Changelog #
**New Functions:**
  * Complete rewrite of the Accessor launcher and its plugins. See below for details.
  * Full Windows 8 compatibility
  * Improved Clipboard Manager by adding persistent clipboard entries that can be searched and support parameters. This is now backed by an Accessor plugin, see below. Additionally, programs can now be excluded from the clipboard history to protect the privacy of sensitive data copied from these programs.
  * Added an action to send Email triggers to [If this then that](http://www.ifttt.com). Some possible uses are included in 7plus, but this requires that you enter your Email login in 7plus and add the matching recipes in IFTTT. Matching recipes are linked to on the Settings page.
  * Added Explorer path history and frequent paths to the Clipboard Manager menu.
  * FTP upload action can now upload directories. In addition, FTP and image uploads are carried out in a separate process for better responsiveness.
  * TAB key can now be used for autocompletion instead of switching the focus whenever a common autocompletion-list is visible (Examples: Path fields, Run dialog).
  * The event system now supports OR operators for its conditions. This results in about 1/3rd less stock events which have been combined with others now.
  * Middle clicking empty taskbar area now toggles mute.
  * 7plus will now display a notification when an drive is connected/mounted to quickly open the drive in Explorer.
  * New action for text-to-speech voice output.

**Accessor:**
  * Accessor has been rewritten from scratch and is now much more modular and powerful. All of its plugins were also rewritten and improved. There are also some new ones. Here's an excerpt of the most important new things:
    * The design has been completely reworked to be much more attractive.
    * Accessor now includes buttons for predefined searches (access to plugins, web searches...), programs/files/folders and FastFolder directories. These buttons can be modified within Accessor. The programs/files/folders can also be accessed with WIN + F[1-12] hotkeys while Accessor is closed.
    * Results are now sorted by a new algorithm that includes the usage frequency and match quality. Execute a result a few times and it will appear at the top of the list!
    * Accessor now makes use of the text that is selected before the Accessor window is opened. Among other things it's now possible to select a file path, URL or registry key, open Accessor and it will be inserted as command automatically. The selection is also used in other plugins where appropriate.
    * It is now possible to use a timer in combination with Accessor commands. Examples:
      * Message Pizza in 10 min
      * Shutdown in 1hour 30 minutes
  * Some new settings to control the behavior and appearance, including support for Aero window style.

**New Accessor Plugins:**
  * Registry plugin: Quickly open Regedit at a key. Useful for going to keys which are written on webpages by selecting the text and opening Accessor.
  * Accessor history plugin: Keeps track of the recently executed Accessor commands. This history is now visible when Accessor is opened in no specific context.
  * File search plugin: Searches the file system.
  * Recent folders plugin: Keeps track of recently used folders. It can be used to quickly switch folders in Explorer, file dialogs, CMD and WinRar. Very useful!
  * Keyword plugin: Quickly create keywords by selecting text or a file, open Accessor and type "Learn as [Keyword](Keyword.md)". Credits go out to Enso Launcher for the idea!
  * Event plugin: Allows to create Accessor commands that trigger events. This allows to combine the ease of access(or) with the feature-rich event system.
    * New commands created with this plugin: Shutdown, Reboot, Hibernate, Standby, LogOff, Lock, Message, Say
    * This plugin is particularly useful in combination with the IFTTT integration mentioned above. It allows to create commands to write tweets, facebook posts and access many other web services supported by IFTTT from withing Accessor.
  * Clipboard plugin: Allows to quickly search for stored clipboard entries and paste them. Selected text can also be stored with this plugin.
  * Control Panel plugin: Indexes the control panel and makes it possible to access the control panel applets.


**Changes to existing Accessor plugins:**
  * The URL plugin can now read and access bookmarks of Opera, Firefox, Chrome and IE.
  * Program Launcher plugin: It's now possible to use CTRL + O in Explorer to select a program for opening the selected file
  * File System plugin: By pressing CTRL + . in Explorer or file dialogs Accessor will show the current directory
  * Various hotkeys and additional actions have been added for the plugins. As an example, results that are folders can now be opened directly in the file system plugin by pressing CTRL + F while the result is selected.

**Bugfixes:**
  * Fixed a severe bug in xml file loading.
  * Fixed encoding of some web requests.
  * Fixed a bug which caused flashing of file dialog close box while mouse was over it.
  * Fixed a bug that caused crashes and hangups on windows which contain ListViews. This fix also improves responsiveness of ListView and TreeView selections.
  * Fixed Explorer windows getting activated at the start of 7plus.
  * Fixed a bug that prevented setting the current directory in save file dialogs.
  * Fixed enabling/disabling of Explorer bar buttons.
  * Fixed "Run or activate" action.
  * Fixed a possible issue in event patching during the update process.

**Changes:**
  * Rewrote navigation code that sets/gets paths/selections in explorer, file dialogs, CMD, Desktop etc.
  * Rewrote notifications to properly stack and to add support for hyperlinks.
  * Improved Slide Windows to be much more responsive.
  * Simplified Image Converter by removing resizing and cropping options for simpler layout. It's recommended to perform these operations in a dedicated image editor (which can be launched by clicking on the image).
  * Global settings for image and text editor paths.
  * Adjusted some window sizes to get rid of redundant scrollbars.
  * Added a setting to avoid 7plus-related Explorer hang-ups.
  * More operations run in separate processes now to improve responsivity.

If you like this program and want to support its development, please consider donating!