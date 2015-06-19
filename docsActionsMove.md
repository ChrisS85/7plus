# Move #
This action moves one or more files to a destination directory.

| **Parameter** | **Description** |
|:--------------|:----------------|
|Source file(s) |Files to be moved. This can be either a single full file-/foldername, or a list of quoted full filenames separated by spaces, or a list of full filenames separated by newline characters. If a ${Sel}-type [placeholder](docsGenericPlaceholders.md) needs to be used, it is suggested to use either ${SelNQ} or ${SelNM}.|
|Target path    |Target directory of move operation. If this is empty, files will be moved to the same directory. This means that a new name has to be set, essentially resulting in a rename operation.|
|Target file(s) |Move target filenames. If this is empty, original filenames are used when the directory is set. It is possible to only specify a filename without extension to keep the original file extensions. If a target file already exists and "Overwrite" is off, a (number) will be attached to the end of the filename.|
|Silent         |If set, 7plus will not show the windows progress dialog. On short operations it won't be visible regardless of this setting.|
|Overwrite      |If set, files which already exist will be overwritten.|

# Usage examples #
  * This action can be used to change extensions for many files at once, or for mass renaming them to a limited extent. Combine it with a [hotkey](docsTriggersHotkey.md) trigger and an [input](docsActionsInput.md) action to enter the new extension.