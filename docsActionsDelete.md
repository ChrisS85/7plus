# Delete #
This action deletes one or more files to a destination directory.

| **Parameter** | **Description** |
|:--------------|:----------------|
|Source file(s) |Files to be deleted. This can be either a single full file-/foldername, or a list of quoted full filenames separated by spaces, or a list of full filenames separated by newline characters. If a ${Sel}-type [placeholder](docsGenericPlaceholders.md) needs to be used, it is suggested to use either ${SelNQ} or ${SelNM}.|
|Silent         |If set, 7plus will not show the windows progress dialog. On short operations it won't be visible regardless of this setting.|

# Usage examples #
  * This action can be used to make regularly delete temporary folders.
  * It is also possible to make delete key not delete specific files in explorer through combination of a [hotkey](docsTriggersHotkey.md) trigger, an [if](docsConditionsIf.md) condition to check for specific files, and this delete action.