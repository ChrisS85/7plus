Trigger_ExplorerPathChanged_Init(Trigger)
{
	Trigger.Category := "Explorer"
}
Trigger_ExplorerPathChanged_ReadXML(Trigger, TriggerFileHandle)
{
}
Trigger_ExplorerPathChanged_WriteXML(Trigger, ByRef TriggerFileHandle, Path)
{	
}
Trigger_ExplorerPathChanged_Enable(Trigger)
{
}
Trigger_ExplorerPathChanged_Matches(Trigger, Filter)
{
	return true ;type is checked elsewhere
}
Trigger_ExplorerPathChanged_DisplayString(Trigger)
{
	return "Explorer path changed"
}
Trigger_ExplorerPathChanged_GuiShow(Trigger, TriggerGUI)
{
}
Trigger_ExplorerPathChanged_GuiSubmit(Trigger, TriggerGUI)
{
}   