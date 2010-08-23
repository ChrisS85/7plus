Action_SetDirectory_Init(Action)
{
	Action.Category := "Explorer"
	Action.WindowMatchType := "Active"
}
Action_SetDirectory_ReadXML(Action, XMLAction)
{
	Action.Path := XMLAction.Path
	WindowFilter_ReadXML(Action,XMLAction)
}
Action_SetDirectory_Execute(Action, Event)
{
	hwnd := WindowFilter_Get(Action)
	path := Event.ExpandPlaceholders(Action.Path)
	StringReplace, path, path, ",,All
	outputdebug navigate %path% %hwnd%
	if(Path = "Back")
		Shell_GoBack(hwnd)
	else if(Path = "Forward")
		Shell_GoForward(hwnd)
	else if(Path = "Upward")
		Shell_GoUpward()
	else
		ShellNavigate(Path,hwnd)
	return 1
} 

Action_SetDirectory_DisplayString(Action)
{
	return "Set Explorer directory to: " Action.Path
}
Action_SetDirectory_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Hint", "You may also enter ""Back"",""Forward"" and ""Upward"" here.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Path", "", "", "Path:","Browse", "Action_SetDirectory_Browse", "Placeholders", "Action_SetDirectory_Placeholders")
		WindowFilter_GuiShow(Action, ActionGUI)
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_Browse(sActionGUI, "Path")
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Path")
}
Action_SetDirectory_Browse:
Action_SetDirectory_GuiShow("", "", "Browse")
return
Action_SetDirectory_Placeholders:
Action_SetDirectory_GuiShow("", "", "Placeholders")
return

Action_SetDirectory_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 