﻿Trigger_WindowClosed_Init(Trigger)
{
	Trigger.Category := "Window"
	WindowFilter_Init(Trigger)
}
Trigger_WindowClosed_ReadXML(Trigger, XMLTrigger)
{	
	WindowFilter_ReadXML(Trigger, XMLTrigger)
}

Trigger_WindowClosed_Matches(Trigger, Filter)
{
	return WindowFilter_Matches(Trigger, Filter.Window, Filter)
}

Trigger_WindowClosed_DisplayString(Trigger)
{
	return "Window Closed: " WindowFilter_DisplayString(Trigger)
}

Trigger_WindowClosed_GuiShow(Trigger, TriggerGUI)
{
	WindowFilter_GuiShow(Trigger, TriggerGUI)
}

Trigger_WindowClosed_GuiSubmit(Trigger, TriggerGUI)
{
	WindowFilter_GuiSubmit(Trigger, TriggerGUI)
} 