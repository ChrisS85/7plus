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
Events_Delete(Events, Event, UpdateGUI=true) 
{
	global Settings_Events, TemporaryEvents	
	index := Events.indexOfSubItem("ID", Event.ID)
	if(!index)
		return
	Event := Events[index]	
	if(Events != TemporaryEvents && Event.ID < 0)
	{
		Events_Delete(TemporaryEvents, Event, UpdateGUI)
		return
	}
	Events[index].Delete()
	Events.Remove(index)
	if(Settings_Events && Events != Settings_Events) ;Remove the event on the settings page too
	{
		Settings_Events.Delete(Settings_Events.SubItem("ID", Event.ID), false)
		if(UpdateGUI)
			Settings_SetupEvents()
	}
	Events.HighestID := -1 ;Decrease HighestID to prevent ID changes when "reimporting" all events from the gui
	Loop % Events.len()
		if(Events[A_Index].ID > Events.HighestID)
			Events.HighestID := Events[A_Index].ID
	if(index := Events.IndexOfSubItem("Category", Event.Category))
		return false
	Events.Categories.Remove(Events.Categories.IndexOf(Event.Category))
	return true
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