Trigger_DoubleClickDesktop_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
}
Trigger_DoubleClickDesktop_ReadXML(Trigger, TriggerFileHandle)
{
}
Trigger_DoubleClickDesktop_Enable(Trigger)
{
}
Trigger_DoubleClickDesktop_Matches(Trigger, Filter)
{
	return true ;type is checked elsewhere
}
Trigger_DoubleClickDesktop_DisplayString(Trigger)
{
	return "Double click on empty desktop area"
}
Trigger_DoubleClickDesktop_GuiShow(Trigger, TriggerGUI)
{
}
Trigger_DoubleClickDesktop_GuiSubmit(Trigger, TriggerGUI)
{
}      