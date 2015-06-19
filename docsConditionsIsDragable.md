# IsDragable #

This condition checks if a window may be dragged by the [MouseWindowDrag](docsActionsMouseWindowDrag.md) and [MouseWindowResize](docsActionsMouseWindowResize.md) actions. It automatically excludes Notepad++ and Scite because they have a ALT+Left drag column selection and this key is typically used with those actions.