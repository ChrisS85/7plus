 Action_Delete_Init(Action)
{
	Action_FileOperation_Init(Action)
}

Action_Delete_ReadXML(Action, XMLAction)
{
	Action_FileOperation_ReadXML(Action, XMLAction)
}

Action_Delete_Execute(Action, Event)
{
	outputdebug file delete
	Action_FileOperation_ProcessPaths(Action, Event, sources, targets, flags)
	ShellFileOperation(0x3, sources, "", flags)  
	return 1
}
Action_Delete_DisplayString(Action)
{
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