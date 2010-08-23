Trigger_WindowActivated_Init(Trigger)
{
	Trigger.Category := "Window"
	WindowFilter_Init(Trigger)
}
Trigger_WindowActivated_ReadXML(Trigger, XMLTrigger)
{	
	WindowFilter_ReadXML(Trigger, XMLTrigger)
}

Trigger_WindowActivated_Matches(Trigger, Filter)
{
	return WindowFilter_Matches(Trigger, "A", Filter)
}

Trigger_WindowActivated_DisplayString(Trigger)
{
	return "Window Activated: " WindowFilter_DisplayString(Trigger)
}

Trigger_WindowActivated_GuiShow(Trigger, TriggerGUI)
{
	WindowFilter_GuiShow(Trigger, TriggerGUI)
}

Trigger_WindowActivated_GuiSubmit(Trigger, TriggerGUI)
{
	WindowFilter_GuiSubmit(Trigger, TriggerGUI)
}