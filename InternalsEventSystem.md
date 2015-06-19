# General #
The Event System is the core component of 7plus. An event consists of a Trigger, a list of conditions and a list of actions (and some more settings). These components are referred to as SubEvents from now on.

Events are used throughout the whole program. This includes not just the user defined events, but also some events that get dynamically created in 7plus (e.g. to execute something with a delay, to upload some files,...).

# Event System #
The CEventSystem class is the main class that contains and manages all event-related things.

# Event Schedule #
When an event gets triggered, a copy of it is put on a queue that gets processed on a timed schedule. For each event on the schedule the conditions are evaluated. If the conditions are fulfilled, the actions of the event are performed in the order of the list. When all actions have been performed the event is removed from the schedule.

# Event #
Events are defined by the CEvent class. They consist of said SubEvents, have a name, a category, an ID and optionally an "OfficialEvent" ID to mark the event as one that originally shipped with 7plus.
The ID is a simple number that uniquely identifies an event during program runtime, but not in XML files from other users (see Loading / Storing).

# Event lists #
There exist two instances of the CEvents class in 7plus, one for the events defined by the user and one for temporary events. These don't appear in the configuration list and don't persist after program exit. This class provides methods to load/save the events from/in XML files, and methods to add/remove events to/from this list. In addition, this class controls the assignment of IDs during loading or creation of an event.

# Trigger #
There are all kinds of triggers in 7plus that allow to react to many different things. These triggers aren't just passive, instead they also add new menu entries, buttons, hotkeys, or timer windows that can be controlled. When something happens that could theoretically be catched by a timer in the event system, a template timer with parameters relevant to the current situation is generated and EventSystem.OnTrigger(TemplateTrigger) is called. This function calls Event.TriggerThisEvent(TemplateTrigger) for all defined events in 7plus which in turn calls Event.Trigger.Matches(TemplateTrigger) and checks some other things to determine if the event should get triggered. The single instances of the CTrigger class implement the Matches function and compare the parameters of the template trigger to decide if they should get triggered.

The CTrigger class has Enable() and Disable() functions that are used to setup the relevant menu entries/buttons/whatever when an event with this trigger is enabled or disabled.

# Condition #
The conditions of an event determine if it can get executed. A class deriving from CCondition needs to implement an Evaluate() method that returns true when the condition is fulfilled.

By default the conditions in the list are linked by AND operators, but there is also an OR operator which is implemented as a condition. It's not really a condition per se as its Evaluate() method is never called but it gets treated as one when it comes to saving/loading and visualizing the conditions in the event editor.

The AND operator takes precedence over the OR operator. This means that the OR operator separates the events in groups of which one must be fulfilled for the event to execute.

# Action #
The actions are responsible for doing all the work when an event is finally executed. A class deriving from CAction implements an Execute() method that performs the tasks. This method returns 1 on successful execution, 0 if there was an error or -1 if this action takes longer to finish. In this case, the event is skipped on the current scheduling process and the Execute() method is called again on the next call of the timed schedule. This allows to create actions that wait for specific things to happen or actions that do asynchronous operations such as uploading files to an FTP server.

# Placeholders #
Placeholders are used for dynamic evaluation of certain properties, much like variables in program code. A placeholder is marked by ${Identifier}. Placeholders are expanded to their values by calling ExpandedString := Event.ExpandPlaceholders(StringContainingPlaceholders). The fields in the single SubEvents use a Placeholders button that shows a list of possible placeholders (not all though) that can be used to indicate that this field supports placeholders.

There is a global list of placeholders stored in EventSystem.GlobalPlaceholders and a local one for each event in Event.Placeholders. Triggers often provide local placeholders that provide details about how the event was triggered (like the selected file of a shell context menu Trigger). Conditions often use placeholders to define themselves, most notably the If condition which may compare window classes, titles, Explorer paths, ... in the form of placeholders. Actions also create local placeholders (like the Input action that shows a dialog to let the user enter something).

# Loading / Saving #
Events are saved in XML files which basically map the internal structure of the involved classes, excluding some keys. Every SubEvent can define properties that should get serialized by using the static modifier. If there are static variables that must not be serialized their names need to start with "". When an event file is loaded it can happen that the IDs of the events in the file are increased to avoid collisions with the already loaded events from other files. The CEvents instances keep a HighestID value that tracks the assigned IDs and assigns new ones with higher values than this value. When imported events have values lower than this value, an offset is added to all imported events so that their IDs are higher than the previous HighestID value. Properties of SubEvents with names that end with "ID" are also increased by this offset. This makes it possible to point to other events while still being able to serialize the events and use IDs that can change.

# Patching Events #
During the update process the event configuration of the user is patched. The patch can modify/replace the official events, add new events or remove official events. Events which are created by the user are left as they are. To generate a patch file, enable debug mode (in Misc) and click on Export on the All Events page. A file dialog will appear to select the base file to base the patch on. Select the All Events.xml file from the previous release and the patch will be created in Events\ReleasePatch\Version.xml where version is the current version of 7plus. Additionally all event categories are exported in separate files in Events\.
Exporting the events like this creates OfficialEvent values for every event that doesn't already have one.

A patch can overwrite values of an event. This includes the SubEvents, however, they are not patched but replaced completely for simplicity. If, for example, a patch modifies an action of an event that uses a Hotkey trigger, the hotkey assignment will be unaffected by the patch (so the users change here is preserved) but the Actions list will be completely replaced.

To identify the official events in user installations which may have ID offsets the OfficialEvent ID is used which is always the same.
There is a slight problem with the current concept that can happen here: If an event is patched that has an action that links to another event and the IDs in the user configuration have offsets the targeted Event in the action will be wrong. This is probably solvable by targeting the OfficialEvent property instead where possible but hasn't been implemented yet. An alternative would be to completely replace the involved events with new ones if it's ever necessary.