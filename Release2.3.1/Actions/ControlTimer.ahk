 Action_ControlTimer_Init(Action)
{
	Action.Category := "7plus"
	Action.Action := "Start timer"
}

Action_ControlTimer_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "TimerID")
	Action.ReadVar(XMLAction, "Action")
	if(Action.Action = "Set time")
		Action.ReadVar(XMLAction, "Time")
}

Action_ControlTimer_Execute(Action, ThisEvent)
{
	global Events
	Event := Events.SubItem("ID", ThisEvent.ExpandPlaceholders(Action.TimerID))
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
	else if(Action.Action = "Set time")
	{
		Time := Event.ExpandPlaceholders(Action.Time)
		if(RegExMatch(Time, "\d\d\:\d\d\:\d\d"))
		{
			hours := SubStr(Time, 1, 2)
			minutes := SubStr(Time, 4, 2)
			seconds := SubStr(Time, 7, 2)
			Event.Trigger.Time := (hours * 3600 + minutes * 60 + seconds) * 1000
		}
		else
			Msgbox Control Timer: "%Time%": Wrong time format! Format needs to be HH:MM:SS. A placeholder from an input action with Datatype=Time can also be used.
	}
	return 1
} 

Action_ControlTimer_DisplayString(Action)
{
	global Settings_Events
	return Action.Action ": " Action.TimerID ": " Settings_Events.SubItem("ID", Action.TimerID).Name	
}

Action_ControlTimer_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	static sActionGUI, sAction, PreviousSelection
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		sAction := Action
		PreviousSelection := ""
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action controls the behavior of timer (windows).")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Set time|Start timer|Stop timer|Pause timer|Start/Pause timer|Reset timer", "Action_ControlTimer_SelectionChange", "Action:")
		SubEventGUI_Add(Action, ActionGUI, "ComboBox", "TimerID", "TriggerType:Timer", "", "Timer:","","","","","The id of the timer event.")
		Action_ControlTimer_GuiShow("", "","ControlTimer_SelectionChange")
	}
	else if(GoToLabel = "ControlTimer_SelectionChange")
	{
		ControlGetText, Action, , % "ahk_id " sActionGUI.DropDown_Action
		if(Action = "Set time")
		{
			if(Action != PreviousSelection)
			{
				SubEventGUI_Add(sAction, sActionGUI, "Text", "Text1", "Time format: HH:MM:SS.")
				SubEventGUI_Add(sAction, sActionGUI, "Text", "Text2", "A placeholder from an input action with time format may be used.")
				SubEventGUI_Add(sAction, sActionGUI, "Edit", "Time", "", "", "Time:", "Placeholders", "Action_ControlTimer_Placeholder")
			}
		}
		else
		{
			Desc_Time := sActionGUI.Desc_Time
			Edit_Time := sActionGUI.Edit_Time
			Button1_Time := sActionGUI.Button1_Time
							
			ControlGetText, Time, , % "ahk_id " sActionGUI.Edit_Time
			sAction.Time := Time
			
			WinKill, % "ahk_id " sActionGUI.Desc_Time
			WinKill, % "ahk_id " sActionGUI.Edit_Time
			WinKill, % "ahk_id " sActionGUI.Button1_Time
			WinKill, % "ahk_id " sActionGUI.Text_Text1
			WinKill, % "ahk_id " sActionGUI.Text_Text2
			if(PreviousSelection = "Set time")
				sActionGUI.y := sActionGUI.y - 70
		}
		PreviousSelection := Action
	}
	else if(GoToLabel = "Placeholder_Time")
		SubEventGUI_Placeholders(sActionGUI, "Time")
	else if(GoToLabel = "Placeholder_Timer")
		SubEventGUI_Placeholders(sActionGUI, "TimerID")
}
Action_ControlTimer_SelectionChange:
Action_ControlTimer_GuiShow("","","ControlTimer_SelectionChange")
return
Action_ControlTimer_Placeholder:
Action_ControlTimer_GuiShow("","","Placeholder_Time")
return
Action_ControlTimer_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}   