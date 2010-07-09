 Action_Delete_Init(Action)
{
	Action_FileOperation_Init(Action)
}

Action_Delete_ReadXML(Action, ActionFileHandle)
{
	Action_FileOperation_ReadXML(Action, ActionFileHandle)
}

Action_Delete_Execute(Action, Event)
{
	Action_FileOperation_ProcessPaths(Action, Event, sources, targets, flags)
	ShellFileOperation(0x3, sources, "", flags)  
	return 1
}
Action_Delete_DisplayString(Action)
{
	global Settings_Events
	return Action_FileOperation_DisplayString(Action)
}

Action_Delete_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFile", "", "", "Source File(s):", "Placeholders", "Action_Delete_Placeholders_Source")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Silent", "Silent", "", "")
	}
	else if(GoToLabel = "PlaceholdersSource")
		SubEventGUI_Placeholders(sActionGUI, "SourceFile")
}
Action_Delete_Placeholders_Source:
Action_Delete_GuiShow("", "", "PlaceholdersSource")
return

Action_Delete_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}    