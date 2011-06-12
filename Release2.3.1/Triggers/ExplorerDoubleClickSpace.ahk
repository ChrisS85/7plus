Trigger_ExplorerDoubleClickSpace_Init(Trigger)
{
	Trigger.Category := "Explorer"
}
Trigger_ExplorerDoubleClickSpace_ReadXML(Trigger, XMLTrigger)
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
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Desc", "This trigger executes when an empty space in the explorer file list is double-clicked.")
}
Trigger_ExplorerDoubleClickSpace_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GUISubmit(Trigger, TriggerGUI)
}    