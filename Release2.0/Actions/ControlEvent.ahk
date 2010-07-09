 Action_ControlEvent_Init(Action)
{
	Action.Category := "7plus"
	Action.Action := "Enable Event"
}

Action_ControlEvent_ReadXML(Action, ActionFileHandle)
{
	Action.EventID := xpath(ActionFileHandle, "/EventID/Text()")
	Action.Action := xpath(ActionFileHandle, "/Action/Text()")
}

Action_ControlEvent_Execute(Action, Event)
{
	global Events
	if(Action.Action = "Enable Event")
		Events[Events.FindID(Action.EventID)].Enable()
	else if(Action.Action = "Disable Event")
		Events[Events.FindID(Action.EventID)].Disable()
	else if(Action.Action = "Toggle Enable/Disable")
		if(Events[Events.FindID(Action.EventID)].Enabled)
			Events[Events.FindID(Action.EventID)].Disable()
		else
			Events[Events.FindID(Action.EventID)].Enable()
	else if(Action.Action = "Trigger Event")
	{
		Trigger := EventSystem_CreateSubEvent("Trigger", "Trigger")
		Trigger.TargetID := Action.EventID
		OnTrigger(Trigger)
	}
	return 1
} 

Action_ControlEvent_DisplayString(Action)
{
	global Settings_Events
	return Action.Action ": " Action.EventID ": " Settings_Events[Settings_Events.FindID(Action.EventID)].Name	
}

Action_ControlEvent_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Enable Event|Disable Event|Toggle Enable/Disable|Trigger Event", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "EventID", "TriggerType:", "", "Event:")
}

Action_ControlEvent_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  