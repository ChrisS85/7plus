 Action_ControlTimer_Init(Action)
{
	Action.Category := "7plus"
	Action.Action := "Start timer"
}

Action_ControlTimer_ReadXML(Action, XMLAction)
{
	Action.TimerID := XMLAction.TimerID
	Action.Action := XMLAction.Action
}

Action_ControlTimer_Execute(Action, Timer)
{
	global Events
	Event := Events[Events.FindID(Action.TimerID)]
	if(Action.Action = "Start timer" && (!Event.Trigger.tmpStart || Event.Trigger.tmpIsPaused))
	{
		Event.Enable()
		Trigger_Timer_Start(Event.Trigger)
	}
	else if(Action.Action = "Stop timer")
		Trigger_Timer_Stop(Event)
	else if(Action.Action = "Pause timer")
		Trigger_Timer_Pause(Event.Trigger)
	else if(Action.Action = "Start/Pause timer")
		Trigger_Timer_StartPause(Event.Trigger)
	else if(Action.Action = "Reset timer")
		Trigger_Timer_Reset(Event.Trigger)
	return 1
} 

Action_ControlTimer_DisplayString(Action)
{
	global Settings_Events
	return Action.Action ": " Action.TimerID ": " Settings_Events[Settings_Events.FindID(Action.TimerID)].Name	
}

Action_ControlTimer_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Start timer|Stop timer|Pause timer|Start/Pause timer|Reset timer", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "TimerID", "TriggerType:Timer", "", "Timer:")
}

Action_ControlTimer_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}   