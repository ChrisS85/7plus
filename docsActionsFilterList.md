# FilterList #
This is an action that is used to remove list items from a list.
| **Parameter** | **Description** |
|:--------------|:----------------|
|Action         |Choose wether to remove or keep list entries that match the condition below|
|List           |The list which is supposed to be filtered. In most cases this is a "${Sel}"-type [placeholder](docsGenericPlaceholders.md). Simply use the same placeholder further down in the action list to use the filtered list.|
|Operator       |See [If](docsConditionsIf.md)|
|Filter         |Each list item is compared to this value using the selected operator|
|Separator      |Separator character(s) by which the list shall be separated afterwards. If the list consists out of quoted entries separated by a space (often used for multiple file paths), this option is ignored|
|Stop action if all list entries were removed|If this is activated, and there are no list entries left after this operation, the current event is aborted.|

# Usage Examples #
  * 7plus uses this action to separate selected files by extension. You can press F3 in explorer, and it will open image files with the specified image editor, and it will open all other files with a text editor.
  * This might also be usable if you need to exchange the list separators of a list for a program that requires a specific format.