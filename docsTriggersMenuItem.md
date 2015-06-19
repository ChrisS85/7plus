# MenuItem #
This trigger represents a menu item in a custom menu. By creating events with such triggers, the menus are generated and can be shown with the [ShowMenu](docsActionsShowMenu.md) action.

The menu property refers to the name of the menu this item belongs to.
The name property is simply the name that appears in the menu.

Submenus can be created by creating a MenuItem event with a submenu value set. Items can be added to this submenu by setting the item name to the name of the submenu value. The event defining the submenu can stay empty, as it is never executed.