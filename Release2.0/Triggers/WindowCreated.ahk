Trigger_WindowCreated_Init(Trigger)
{
	Trigger.Category := "Window"
	WindowFilter_Init(Trigger)
}
Trigger_WindowCreated_ReadXML(Trigger, TriggerFileHandle)
{	
	WindowFilter_ReadXML(Trigger, TriggerFileHandle)
}

Trigger_WindowCreated_WriteXML(Trigger, ByRef TriggerFileHandle, Path)
{
	WindowFilter_WriteXML(Trigger, TriggerFileHandle, Path)
}

Trigger_WindowCreated_Enable(Trigger)
{
}

Trigger_WindowCreated_Matches(Trigger, Filter)
{
	outputdebug Trigger_WindowCreated_Matches
	return WindowFilter_Matches(Trigger, Trigger.Window, Filter)
}

Trigger_WindowCreated_DisplayString(Trigger)
{
	return "Window Created: " WindowFilter_DisplayString(Trigger)
}

Trigger_WindowCreated_GuiShow(Trigger, TriggerGUI)
{
	WindowFilter_GuiShow(Trigger, TriggerGUI)
}

Trigger_WindowCreated_GuiSubmit(Trigger, TriggerGUI)
{
	WindowFilter_GuiSubmit(Trigger, TriggerGUI)
}