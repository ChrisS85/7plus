# Copy #
This action copies one or more files to a destination directory.

| **Parameter** | **Description** |
|:--------------|:----------------|
|Source file(s) |Files to be copied. This can be either a single full file-/foldername, or a list of quoted full filenames separated by spaces, or a list of full filenames separated by newline characters. If a ${Sel}-type [placeholder](docsGenericPlaceholders.md) needs to be used, it is suggested to use either ${SelNQ} or ${SelNM}.|
|Target path    |Target directory of copy operation. If this is empty, files will be copied to the same directory. This means that a new name has to be set.|
|Target file(s) |Copy target filenames. If this is empty, original filenames are used when the directory is set. It is possible to only specify a filename without extension to keep the original file extensions. If a target file already exists and "Overwrite" is off, a (number) will be attached to the end of the filename.|
|Silent         |If set, 7plus will not show the windows progress dialog. On short operations it won't be visible regardless of this setting.|
|Overwrite      |If set, files which already exist will be overwritten.|

# Usage examples #
  * This action can be used to make regularly backups of your important files. Simply combine it with a [timer](docsTriggersTimer.md) trigger and have it copy your files. You might want to use a date [placeholder](docsGenericPlaceholders.md) for the target folder name.