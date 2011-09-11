Trigger_ScreenCorner_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.Corner := 1
	Trigger.Time := 1000
}
Trigger_ScreenCorner_ReadXML(Trigger, XMLTrigger)
{
	Trigger.ReadVar(XMLTrigger, "Corner")
	Trigger.ReadVar(XMLTrigger, "Time")
}
Trigger_ScreenCorner_Enable(Trigger)
{
}
Trigger_ScreenCorner_Matches(Trigger, Filter)
{
	return Trigger.Corner = Filter.Corner ;type is checked elsewhere
}
Trigger_ScreenCorner_DisplayString(Trigger)
{
	return "Hovering over screen corner"
}
Trigger_ScreenCorner_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Desc", "This trigger is executed when the mouse hovers over a screen corner for a specified time.")
	SubEventGUI_Add(Trigger, TriggerGUI, "DropDownList", "Corner", "1: Upper Left|2: Upper Right|3: Lower Right|4: Lower Left", "", "Corner:")	
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Time", "", "", "Time[ms]:")
}
Trigger_ScreenCorner_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GUISubmit(Trigger, TriggerGUI)
}   