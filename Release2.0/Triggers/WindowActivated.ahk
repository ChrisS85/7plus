Trigger_WindowActivated_ReadXML(Trigger, TriggerFileHandle)
{	
	WindowFilter_ReadXML(Trigger, TriggerFileHandle)
}

Trigger_WindowActivated_WriteXML(Trigger, ByRef TriggerFileHandle, Path)
{
	WindowFilter_WriteXML(Trigger, TriggerFileHandle, Path)
}

Trigger_WindowActivated_Enable(Trigger)
{
}

Trigger_WindowActivated_Matches(Trigger, Filter)
{
	return WindowFilter_Matches(Trigger, "A", Filter)
}
