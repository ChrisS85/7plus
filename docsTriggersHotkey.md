# Hotkey #

The hotkey trigger is used to trigger actions when a specific key is pressed.

There are a few options in hotkey definition:
  * ~ (Native) : This means that the key will still be visible to other programs when pressed.
  * `*` (Wildcard) : This means that the key will also be accepted when modifier keys such as ALT are currently down.
  * < (Left pair only) : This is used in hotkeys that use modifier keys such as ALT. It means that only the left modifier keys are accepted.
  * > (Right pair only) : This is used in hotkeys that use modifier keys such as ALT. It means that only the right modifier keys are accepted.
  * UP : This means that the event will trigger when the hotkey is released. This is useful to prevent hotkey spamming by holding the key.

# Tips #
  * In many cases you will want to make sure that the hotkey does not overlap with hotkeys using the same key in other programs. This means that you need to make the hotkey trigger only under certain circumstances. Using conditions, you can only make it trigger when a certain program is active, for example.