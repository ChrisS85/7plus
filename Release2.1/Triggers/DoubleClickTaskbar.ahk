Trigger_DoubleClickTaskbar_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
}
Trigger_DoubleClickTaskbar_ReadXML(Trigger, XMLTrigger)
{
}
Trigger_DoubleClickTaskbar_Enable(Trigger)
{
}
Trigger_DoubleClickTaskbar_Matches(Trigger, Filter)
{
	return true ;type is checked elsewhere
}
Trigger_DoubleClickTaskbar_DisplayString(Trigger)
{
	return "Double click on empty taskbar area"
}
Trigger_DoubleClickTaskbar_GuiShow(Trigger, TriggerGUI)
{
}
Trigger_DoubleClickTaskbar_GuiSubmit(Trigger, TriggerGUI)
{
}     