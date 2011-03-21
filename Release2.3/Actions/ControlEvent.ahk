 Action_ControlEvent_Init(Action)
{
	Condition_If_Init(Action)
	Action.Category := "7plus"
	Action.Action := "Enable Event"
	Action.Compare := ""
}

Action_ControlEvent_ReadXML(Action, XMLAction)
{
	Action.EventID := XMLAction.EventID
	Action.Action := XMLAction.Action
	Condition_If_ReadXML(Action, XMLAction)
}

Action_ControlEvent_Execute(Action, Event)
{
	global Events
	if(Condition_If_Evaluate(Action, Event))
	{
		outputdebug condition fulfilled
		TargetEvent := Events.SubItem("ID", Action.EventID)
		if(Action.Action = "Enable Event")
			TargetEvent.Enable()
		else if(Action.Action = "Disable Event")
		{
			outputdebug % "disable " TargetEvent.ID
			TargetEvent.Disable()
		}
		else if(Action.Action = "Toggle Enable/Disable")
			if(TargetEvent.Enabled)
				TargetEvent.Disable()
			else
				TargetEvent.Enable()
		else if(Action.Action = "Trigger Event")
		{
			Trigger := EventSystem_CreateSubEvent("Trigger", "Trigger")
			Trigger.TargetID := Action.EventID
			OnTrigger(Trigger)
		}
	}
	return 1
} 

Action_ControlEvent_DisplayString(Action)
{
	global Settings_Events
	return Action.Action ": " Action.EventID ": " Settings_Events.SubItem("ID", Action.EventID).Name	
}

Action_ControlEvent_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Enable Event|Disable Event|Toggle Enable/Disable|Trigger Event", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "EventID", "TriggerType:", "", "Event:")
	SubEventGUI_Add(Action, ActionGUI, "Text", "text1", "This action is only performed if the condition below is matched.")
	SubEventGUI_Add(Action, ActionGUI, "Text", "text2", "Leave both text fields empty to always perform it.")
	Condition_If_GuiShow(Action, ActionGUI, "")
}

Action_ControlEvent_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  