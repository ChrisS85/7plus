 Action_ControlEvent_Init(Action)
{
	Condition_If_Init(Action)
	Action.Category := "7plus"
	Action.Action := "Enable Event"
	Action.Compare := ""
}

Action_ControlEvent_ReadXML(Action, XMLAction)
{
	Condition_If_ReadXML(Action, XMLAction)
	Action.ReadVar(XMLAction, "EventID")
	Action.ReadVar(XMLAction, "Action")
	if(Action.Action = "Copy Event")
	{
		Action.ReadVar(XMLAction, "EvaluateOnCopy")
		Action.ReadVar(XMLAction, "Placeholder")
		Action.ReadVar(XMLAction, "DeleteAfterUse")
	}
}

Action_ControlEvent_Execute(Action, Event)
{
	global Events, TemporaryEvents
	if(Condition_If_Evaluate(Action, Event))
	{
		outputdebug condition fulfilled
		TargetEvent := Events.SubItem("ID", Event.ExpandPlaceholders(Action.EventID))
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
		else if(Action.Action = "Copy Event")
		{
			Copy := EventSystem_RegisterEvent(TemporaryEvents, TargetEvent.DeepCopy(), 0)
			Copy.DeleteAfterUse := Action.DeleteAfterUse
			;Placeholders may be evaluated at the time of the copy operation, 
			;so they don't use placeholders which may have changed in the meantime
			if(Action.EvaluateOnCopy)
				objDeepPerform(Copy, "Event_ExpandPlaceHolders", Copy)
			Events.GlobalPlaceholders[Action.Placeholder] := Copy.ID
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
	static sActionGUI, sAction, PreviousSelection
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		sAction := Action
		PreviousSelection := ""
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action can do various stuff with other events. It is only performed if the condition below is matched. Leave both text fields empty to always perform it.")
		Condition_If_GuiShow(Action, ActionGUI, "")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Copy Event|Disable Event|Enable Event|Toggle Enable/Disable|Trigger Event", "Action_ControlEvent_SelectionChange", "Action:")
		SubEventGUI_Add(Action, ActionGUI, "ComboBox", "EventID", "TriggerType:", "", "Event:")
		Action_ControlEvent_GuiShow("", "","ControlEvent_SelectionChange")
	}
	else if(GoToLabel = "ControlEvent_SelectionChange")
	{
		ControlGetText, Action, , % "ahk_id " sActionGUI.DropDown_Action
		if(Action = "Copy Event")
		{
			if(Action != PreviousSelection)
			{
				sAction.EvaluateOnCopy := true
				sAction.DeleteAfterUse := true
				SubEventGUI_Add(sAction, sActionGUI, "Text", "Text", "Copied event is stored in placeholder (Enter without ${})")
				SubEventGUI_Add(sAction, sActionGUI, "Edit", "Placeholder", "", "", "Placeholder:")				
				; SubEventGUI_Add(sAction, sActionGUI, "Text", "Text1", "Placeholders can be evaluated when copying to make them use the current value.")
				SubEventGUI_Add(sAction, sActionGUI, "Checkbox", "EvaluateOnCopy", "Evaluate placeholders when copying to make them use the current value")
				SubEventGUI_Add(sAction, sActionGUI, "Checkbox", "DeleteAfterUse", "Delete copy after use")
			}
		}
		else
		{
			if(PreviousSelection = "Window")
				sActionGUI.y := sActionGUI.y - 130
		}
		PreviousSelection := Action
	}
}
Action_ControlEvent_SelectionChange:
Action_ControlEvent_GuiShow("","","ControlEvent_SelectionChange")
return
Action_ControlEvent_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  