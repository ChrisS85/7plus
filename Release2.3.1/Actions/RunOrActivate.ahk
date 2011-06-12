Action_RunOrActivate_Init(Action)
{
	Action_Run_Init(Action)
	Action.Category := "System"
}
Action_RunOrActivate_ReadXML(Action, XMLAction)
{
	Action_Run_ReadXML(Action, XMLAction)
}
Action_RunOrActivate_Execute(Action, Event)
{
	if(Action.tmpPid)
		return Action_Run_Execute(Action, Event)
	else
	{
		Process, Exist, %name%
		if(Errorlevel != 0)
			WinActivate ahk_pid %ErrorLevel%
		else
			return Action_Run_Execute(Action, Event)
	}
	return 1
}
Action_RunOrActivate_DisplayString(Action)
{
	return "Run or activate " Action.Command
}
Action_RunOrActivate_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action will run a program or activate it if it is already running.")
	Action_Run_GuiShow(Action, ActionGUI)
}
Action_RunOrActivate_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 