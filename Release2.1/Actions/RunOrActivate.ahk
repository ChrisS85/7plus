Action_RunOrActivate_Init(Action)
{
	Action.Category := "System"
	Action.WaitForFinish := 0
}
Action_RunOrActivate_ReadXML(Action, XMLAction)
{
	Action.Command := XMLAction.Command
	Action.WorkingDirectory := XMLAction.WorkingDirectory
	Action.WaitForFinish := XMLAction.WaitForFinish
}
Action_RunOrActivate_Execute(Action, Event)
{
	if(Action.tmpPid)
	{
		pid := Action.tmpPid
		Process, Exist, %pid%
		if(ErrorLevel)
			return -1
	}
	else
	{
		command := Event.ExpandPlaceholders(Action.Command)
		SplitPath, command, name
		if(InStr(name, " "))
			name := Substr(name, 1, InStr(name, " ") - 1)
		Process, Exist, %name%
		if(Errorlevel != 0)
			WinActivate ahk_pid %ErrorLevel%
		else
		{
		WorkingDirectory := Event.ExpandPlaceholders(Action.WorkingDirectory)
		if(Action.WaitForFinish)
		{
				Action.tmpPid := Run(command, WorkingDirectory)
				if(Action.tmpPid) ;If retrieved properly
					return -1
				MsgBox Waiting for %command% failed!
				return 0
			}
			else
				Run(command, WorkingDirectory)
		}
	}
		
	return 1
}
Action_RunOrActivate_DisplayString(Action)
{
	return "Run or activate " Action.Command
}
Action_RunOrActivate_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Command", "", "", "Command:","Browse", "Action_RunOrActivate_Browse", "Placeholders", "Action_RunOrActivate_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "WorkingDirectory", "", "", "Working Dir:","Browse", "Action_RunOrActivate_Browse_WD", "Placeholders", "Action_RunOrActivate_Placeholders_WD")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "WaitForFinish", "Wait for finish", "", "")
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "Command", "Select File", "", 1)
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Command")
	else if(GoToLabel = "Browse_WD")
		SubEventGUI_Browse(sActionGUI, "WorkingDirectory", "Select working directory", "", 1)
	else if(GoToLabel = "Placeholders_WD")
		SubEventGUI_Placeholders(sActionGUI, "WorkingDirectory")
}
Action_RunOrActivate_Browse:
Action_RunOrActivate_GuiShow("", "", "Browse")
return
Action_RunOrActivate_Placeholders:
Action_RunOrActivate_GuiShow("", "", "Placeholders")
return
Action_RunOrActivate_Browse_WD:
Action_RunOrActivate_GuiShow("", "", "Browse_WD")
return
Action_RunOrActivate_Placeholders_WD:
Action_RunOrActivate_GuiShow("", "", "Placeholders_WD")
return
Action_RunOrActivate_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 