;Generic Run interface for subevents. They can implement this interface like this:
;static _ImplementsRun := ImplementRunInterface(CSubEvent)
;It's important to use a "_" or "tmp" at the start of the name to mark this property as temporary so it won't be saved.
ImplementRunInterface(Run)
{	
	Run.WaitForFinish := false
	Run.RunAsAdmin := false
	Run.Command := "cmd.exe"
	Run.WorkingDirectory := ""
	if(Run.HasKey("__Class"))
	{
		Run.RunExecute := Func("Run_Execute")
		Run.RunDisplayString := Func("Run_DisplayString")
		Run.RunGUIShow := Func("Run_GUIShow")
		Run.RunGUISubmit := Func("Run_GUISubmit")
	}
}

Run_Execute(SubEvent, Event)
{
	if(!SubEvent.tmpPid)
	{
		command := Event.ExpandPlaceholders(SubEvent.Command)
		WorkingDirectory := Event.ExpandPlaceholders(SubEvent.WorkingDirectory)
		if(SubEvent.WaitForFinish)
		{
			SubEvent.tmpPid := Run(command, WorkingDirectory, "", !SubEvent.RunAsAdmin)
			if(SubEvent.tmpPid) ;If retrieved properly
				return -1
			MsgBox Waiting for %command% failed!
			return 0
		}
		else
			Run(command, WorkingDirectory, "", !SubEvent.RunAsAdmin)
	}
	else
	{
		pid := SubEvent.tmpPid
		Process, Exist, %pid%
		if(ErrorLevel)
			return -1
	}
	return 1
}

Run_DisplayString(SubEvent)
{
	return "Run " SubEvent.Command
}

Run_GuiShow(SubEvent, GUI, GoToLabel = "")
{
	if(GoToLabel = "")
	{
		SubEvent.tmpRunGUI := GUI
		SubEvent.AddControl(GUI, "Text", "Text", "Enclose paths with spaces in quotes and append parameters in command field.")
		SubEvent.AddControl(GUI, "Edit", "Command", "", "", "Command:","Browse", "Action_Run_Browse", "Placeholders", "Action_Run_Placeholders")
		SubEvent.AddControl(GUI, "Edit", "WorkingDirectory", "", "", "Working Dir:","Browse", "Action_Run_Browse_WD", "Placeholders", "Action_Run_Placeholders_WD")
		SubEvent.AddControl(GUI, "Checkbox", "WaitForFinish", "Wait for finish", "", "")
		SubEvent.AddControl(GUI, "Checkbox", "RunAsAdmin", "Run as admin", "", "")
	}
	else if(GoToLabel = "Browse")
		SubEvent.SelectFile(SubEvent.tmpRunGUI, "Command", "Select File", "", 1)
	else if(GoToLabel = "Placeholders")
		ShowPlaceholderMenu(SubEvent.tmpRunGUI, "Command")
	else if(GoToLabel = "Browse_WD")
		SubEvent.Browse(SubEvent.tmpRunGUI, "WorkingDirectory", "Select working directory", "", 1)
	else if(GoToLabel = "Placeholders_WD")
		ShowPlaceholderMenu(SubEvent.tmpRunGUI, "WorkingDirectory")
}
Run_GUISubmit(SubEvent, GUI)
{
	SubEvent.Remove("tmpRunGUI")
}
Action_Run_Browse:
GetCurrentSubEvent().RunGuiShow("", "Browse")
return
Action_Run_Placeholders:
GetCurrentSubEvent().RunGuiShow("", "Placeholders")
return
Action_Run_Browse_WD:
GetCurrentSubEvent().RunGuiShow("", "Browse_WD")
return
Action_Run_Placeholders_WD:
GetCurrentSubEvent().RunGuiShow("", "Placeholders_WD")
return