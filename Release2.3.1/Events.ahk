;This function needs to be used to add events, to allow syncing with settings window
Events_Add(Events, Event) 
{
	global Settings_Events, TemporaryEvents
	Events.append(Event)
	if(Settings_Events && Events != Settings_Events && Events != TemporaryEvents)
	{
		Settings_Events.append(Event.DeepCopy())
		Settings_SetupEvents()
	}
}

;This function needs to be used to remove events, to allow syncing with settings window
Events_Remove(Events, Event, UpdateGUI=true) 
{
	global Settings_Events, TemporaryEvents
	if(Events != TemporaryEvents && Event.ID < 0)
	{
		Events_Remove(TemporaryEvents, Event, UpdateGUI)
		return
	}
	index := Events.indexOfSubItem("ID", Event.ID)
	Events[index].Delete()
	Events.Delete(index)
	if(Settings_Events && Events != Settings_Events)
	{
		Settings_Events.Delete(Settings_Events.indexOfSubItem("ID", Event.ID))
		if(UpdateGUI)
			Settings_SetupEvents()
	}
}

;Events overrides SubItem function so that it can redirect negative IDs to TemporaryEvents
Events_SubItem(Events, subitem, val)
{
	global TemporaryEvents
	if(subitem = "ID" && val < 0)
		return TemporaryEvents.SubItem(subitem, val)
	else
		return Array_SubItem(Events,subitem, val)
}

;Events overrides indexOfSubItem function so that it can redirect negative IDs to TemporaryEvents
Events_indexOfSubItem(Events, subitem, val)
{
	global TemporaryEvents
	if(subitem = "ID" && val < 0)
		return TemporaryEvents.indexOfSubItem(subitem, val)
	else
		return Array_indexOfSubItem(Events,subitem, val)
}