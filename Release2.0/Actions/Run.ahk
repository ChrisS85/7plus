Action_Run_Init(Action)
{
	Action.Category := "System"
	Action.WaitForFinish := 0
}
Action_Run_ReadXML(Action, ActionFileHandle)
{
	Action.Command := xpath(ActionFileHandle, "/Command/Text()")
	Action.WaitForFinish := xpath(ActionFileHandle, "/WaitForFinish/Text()")
}
Action_Run_Execute(Action, Event)
{
	if(!Action.Pid)
	{
		command := Event.ExpandPlaceholders(Action.Command)
		if(Action.WaitForFinish)
		{
			Action.Pid := Run(command)
			if(Action.Pid) ;If retrieved properly
				return -1
			MsgBox Waiting for %command% failed!
			return 0
		}
		else
			Run(command)
	}
	else
	{
		pid := Action.Pid
		Process, Exist, %pid%
		if(ErrorLevel)
			return -1
	}
}
Action_Run_DisplayString(Action)
{
	return "Run " Action.Command
}
Action_Run_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Command", "", "", "Command:","Browse", "Action_Run_Browse", "Placeholders", "Action_Run_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "WaitForFinish", "Wait for finish", "", "")
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "Command")
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Command")
}
Action_Run_Browse:
Action_Run_GuiShow("", "", "Browse")
return
Action_Run_Placeholders:
Action_Run_GuiShow("", "", "Placeholders")
return

Action_Run_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}