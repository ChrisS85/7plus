Trigger_None_Init(Trigger)
{
	Trigger.Category := "Other"
}
Trigger_None_ReadXML(Trigger, XMLTrigger)
{
}

Trigger_None_Enable(Trigger)
{
}
Trigger_None_Disable(Trigger)
{
}
Trigger_None_Matches(Trigger, Filter)
{
	return false
}

Trigger_None_DisplayString(Trigger)
{
	return "None"
}

Trigger_None_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Text", "This trigger type can only be triggered by a trigger action.", "", "")
}

Trigger_None_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GUISubmit(Trigger, TriggerGUI)
}