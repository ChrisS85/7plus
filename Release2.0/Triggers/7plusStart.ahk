Trigger_7plusStart_Init(Trigger)
{
	Trigger.Category := "7plus"
}
Trigger_7plusStart_ReadXML(Trigger, TriggerFileHandle)
{
}
Trigger_7plusStart_Enable(Trigger)
{
}
Trigger_7plusStart_Matches(Trigger, Filter)
{
	return true ;type is checked elsewhere
}
Trigger_7plusStart_DisplayString(Trigger)
{
	return "7plus Startup"
}
Trigger_7plusStart_GuiShow(Trigger, TriggerGUI)
{
}
Trigger_7plusStart_GuiSubmit(Trigger, TriggerGUI)
{
}  