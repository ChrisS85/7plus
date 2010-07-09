Trigger_None_Init(Trigger)
{
	Trigger.Category := "Other"
}

Trigger_None_Matches(Trigger, Filter)
{
	return false
}

Trigger_None_DisplayString(Trigger)
{
	return "None"
}

Trigger_None_GuiShow(WindowFilter, TriggerGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "Text", "Text", "This trigger type can only be triggered by a trigger action.", "", "")
}

Trigger_None_GuiSubmit(WindowFilter, TriggerGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}