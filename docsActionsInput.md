# Input #
This action shows an input dialog box to ask the user for a value. The type of value can be specified, it's possible to use (file)paths, text, number, selection or time data types. It is possible to react to selections using the condition in the [ControlEvent](docsActionsControlEvent.md) action.
You may specify the window title and a text message for the user. Additionally you can also set if a cancel button should be used, that aborts all further actions in this event.

The result of the input action is stored in the placeholder specified in the action. This placeholder has a global scope, this means that it can be used in other events and will be available during the whole program runtime unless it gets overwritten.

# Usage examples #
  * The use of the selection and time datatypes is demonstrated in the dynamic timer feature.
  * 7plus uses this to query for filenames in screenshot upload function, and in CTRL+S file selection filter to let the user enter a filter string.

# Pre 2.3.0 #
The entered value is then accessed through the ${Input} [placeholder](docsGenericPlaceholders.md). Keep in mind that the scope of a placeholder is limited to the current event, so events triggered through this event won't be able to see it.