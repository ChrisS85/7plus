;Enabled state needs to be set through this function, to allow syncing with settings window
Event_SetEnabled(Event,Value) 
{
	global Events
	Event.Enabled := Value
	if(SettingsActive() && Events.SubItem("ID", Event.ID)) ;if settings are open and updating a regular event, update its counterpart in SettingsWindow.Events
	{	
		SettingsWindow.Events.SubItem("ID", Event.ID).Enabled := Value
		SettingsWindow.FillEventsList()
	}
}
Event_Delete(Event)
{
	Event.Trigger.Delete(Event)
}
Event_Enable(Event)
{
	Event.SetEnabled(true)
	Event.Trigger.Enable(Event)
}

Event_Disable(Event)
{
	Event.SetEnabled(false)
	Event.Trigger.Disable(Event)
}
;Applies a patch to an Event, overwriting only some of its values
Event_ApplyPatch(Event, Patch, Level=0)
{
	enum := Patch._newEnum()
	while enum[key, value]
	{
		if(key != "PatchOnly")
			Event[key] := value
	}
}