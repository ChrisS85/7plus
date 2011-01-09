;This function needs to be used to add events, to allow syncing with settings window
Events_Add(Events, Event) 
{
	global Settings_Events
	outputdebug addEvent()
	Events.append(Event)
	if(Settings_Events && Events != Settings_Events)
	{
		outputdebug add event to settings
		Settings_Events.append(Event.DeepCopy())
		Settings_SetupEvents()
	}
}

;This function needs to be used to remove events, to allow syncing with settings window
Events_Remove(Events, Event) 
{
	global Settings_Events
	index := Events.indexOfSubItem("ID", Event.ID)
	Events[index].Delete()
	Events.Delete(index)
	if(Settings_Events && Events != Settings_Events)
	{
		Settings_Events.Delete(Settings_Events.indexOfSubItem("ID", Event.ID))
		Settings_SetupEvents()
	}
}