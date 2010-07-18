Trigger_ExplorerDoubleClickSpace_Init(Trigger)
{
	Trigger.Category := "Explorer"
}
Trigger_ExplorerDoubleClickSpace_ReadXML(Trigger, TriggerFileHandle)
{
}
Trigger_ExplorerDoubleClickSpace_Enable(Trigger)
{
}
Trigger_ExplorerDoubleClickSpace_Matches(Trigger, Filter)
{
	return true ;type is checked elsewhere
}
Trigger_ExplorerDoubleClickSpace_DisplayString(Trigger)
{
	return "Explorer: Double click on empty space"
}
Trigger_ExplorerDoubleClickSpace_GuiShow(Trigger, TriggerGUI)
{
}
Trigger_ExplorerDoubleClickSpace_GuiSubmit(Trigger, TriggerGUI)
{
}    