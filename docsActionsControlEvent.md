# ControlEvent #

This action is used to control other events. It is possible to trigger other events, and to enable/disable them. You can also toggle between enabled and disabled state.
The ControlEvent also has the possibility to be executed only when a condition is fulfilled. For the meanings of those parameters, refer to the [If](docsConditionsIf.md) condition. This is also demonstrated in the dynamic timer feature.

# Copy Event #
A special feature of this action is its ability to copy another event. This is used if an event needs to be executed in parallel. Most events support this by design, but some, like timers, can only be run once at a time. By copying the event, a temporary duplicate is created that won't show up in the settings window and won't be saved. It is possible to have it delete itself after it was executed, like the "Delete after use" action.
There is also an option that will evaluate all placeholders in the copied event at the time of the copying action. By using this option one can make sure that the event won't see future changes in placeholder values.
The use of this feature is demonstrated in the dynamic timer function.

# Tips #

If an event is supposed to only get triggered through such a trigger action, it is best practice to use a [None](docsTriggersNone.md) trigger, so it does not get triggered under other circumstances.