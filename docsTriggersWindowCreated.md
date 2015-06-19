# WindowCreated #

This trigger gets activated when a window gets created. You can limit it to specific windows by using the [window filter](docsGenericWindowFilter.md) controls.

# Tips #

  * A possible use for this is to prevent using certain programs, such as task manager for systems running in a kiosk mode. For this, add a [WindowClose](docsActionsWindowClose.md) action, possibly with the Force-close parameter set.