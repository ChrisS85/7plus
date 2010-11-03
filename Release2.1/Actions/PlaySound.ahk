Action_PlaySound_Init(Action)
{
	Action.Category := "System"
}

Action_PlaySound_ReadXML(Action, XMLAction)
{
	Action.File := XMLAction.File
}

Action_PlaySound_DisplayString(Action)
{
	return "Play " Action.File
}
Action_PlaySound_Execute(Action, Event)
{
	file := UnQuote(Action.File)
	SoundPlay, % file
	return 1
}
Action_PlaySound_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "File", "", "", "Sound file:", "Browse", "Action_PlaySound_Browse", "Placeholders", "Action_PlaySound_Placeholders_File")
		SubEventGUI_Add(Action, ActionGUI, "Button", "", "System Sounds", "Action_PlaySound_Help")
	}
	else if(GoToLabel = "Placeholders_File")
		SubEventGUI_Placeholders(sActionGUI, "File")	
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "File")
	else if(GoToLabel = "Help")
		run, http://www.autohotkey.net/docs/commands/SoundPlay.htm
}
Action_PlaySound_Placeholders_File:
Action_PlaySound_GuiShow("", "", "Placeholders_File")
return
Action_PlaySound_Browse:
Action_PlaySound_GuiShow(Action, ActionGUI, "Browse")
return
Action_PlaySound_Help:
Action_PlaySound_GuiShow("", "", "Help")
return
Action_PlaySound_GUISubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}