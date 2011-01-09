Action_Wait_Init(Action)
{
	Action.Category := "7plus"
	Action.Time := 1000
}
Action_Wait_ReadXML(Action, XMLAction)
{
	Action.Time := XMLAction.Time
}
Action_Wait_Execute(Action,Event)
{
	if(!Action.tmpStartTime) ;First trigger, store start time
	{
		Action.tmpStartTime := A_TickCount
		return -1
	}
	else if(A_TickCount > Action.tmpStartTime + Action.Time) ;If wait time has run out
	{
		Action.Time := 0
		return 1
	}
	else ;Still waiting
		return -1
}
Action_Wait_DisplayString(Action)
{
	return "Wait " Action.Time "ms"
}
Action_Wait_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Time", "", "", "Time (ms):", "", "")
}
Action_Wait_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 