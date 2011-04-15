Trigger_WindowStateChange_Init(Trigger)
{
	Trigger.Category := "Window"
	Trigger.Event := "Window minimized"
	WindowFilter_Init(Trigger)
}

Trigger_WindowStateChange_ReadXML(Trigger, XMLTrigger)
{
	WindowFilter_ReadXML(Trigger, XMLTrigger)
	Trigger.Event := XMLTrigger.Event
}

Trigger_WindowStateChange_Matches(Trigger, Filter)
{
	return Trigger.Event = Filter.Event && WindowFilter_Matches(Trigger, Trigger.Window, Filter)
}

Trigger_WindowStateChange_DisplayString(Trigger)
{
	return Trigger.Event ": " WindowFilter_DisplayString(Trigger)
}

Trigger_WindowStateChange_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "DropDownList", "Event", "Window minimized|Window maximized", "", "Event:")
	WindowFilter_GuiShow(Trigger, TriggerGUI)
}

Trigger_WindowStateChange_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger, TriggerGUI)
} 