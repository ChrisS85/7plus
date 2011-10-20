;This function needs to be used to add events, to allow syncing with settings window
Events_Add(Events, Event) 
{
	global TemporaryEvents
	Events.Insert(Event)
	if(SettingsActive() && Events != SettingsWindow.Events && Events != TemporaryEvents) ;Non-temporary and non-settings event that needs to be synced with an open settings gui
	{
		SettingsWindow.Events.Insert(Event.DeepCopy())
		SettingsWindow.RecreateTreeView()
	}
}

;This function needs to be used to remove events, to allow syncing with settings window
;It returns true when a category was deleted.
Events_Delete(Events, Event, UpdateGUI=true) 
{
	global TemporaryEvents	
	index := Events.FindKeyWithValue("ID", Event.ID)
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
	if(SettingsActive() && Events != SettingsWindow.Events) ;Remove the event on the settings page too
	{
		SettingsWindow.Events.Delete(SettingsWindow.Events.GetItemWithValue("ID", Event.ID), false)
		if(UpdateGUI)
			SettingsWindow.RecreateTreeView()
	}
	Events.HighestID := -1 ;Decrease HighestID to prevent ID changes when "reimporting" all events from the gui
	Loop % Events.MaxIndex()
		if(Events[A_Index].ID > Events.HighestID)
			Events.HighestID := Events[A_Index].ID
	if(index := Events.FindKeyWithValue("Category", Event.Category))
		return false
	Events.Categories.Remove(Events.Categories.IndexOf(Event.Category))
	return true
}

;Events overrides SubItem function so that it can redirect negative IDs to TemporaryEvents
Events_GetItemWithValue(Events, subitem, val)
{
	global TemporaryEvents
	if(subitem = "ID" && val < 0)
		return TemporaryEvents.GetItemWithValue(subitem, val)
	else
	{
		func := "CRichObject.GetItemWithValue"
		return %func%(Events,subitem, val)
	}
}

;Events overrides FindKeyWithValue function so that it can redirect negative IDs to TemporaryEvents
Events_FindKeyWithValue(Events, subitem, val)
{
	global TemporaryEvents
	if(subitem = "ID" && val < 0)
		return TemporaryEvents.FindKeyWithValue(subitem, val)
	else
	{
		func := "CRichObject.FindKeyWithValue"
		return %func%(Events,subitem, val)
	}
}