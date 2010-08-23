Action_SetWindowTitle_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "System"
	Action.Title := "7plus rocks!"
}
Action_SetWindowTitle_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.Title := XMLAction.Title
}
Action_SetWindowTitle_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	Title := Event.ExpandPlaceholders(Action.Title)
	SendMessage, 0xC, 0, "" Title "", , ahk_id %hwnd%
	return 1
}
Action_SetWindowTitle_DisplayString(Action)
{
	return "Set window title of " WindowFilter_DisplayString(Action) " to " Action.Title
}
Action_SetWindowTitle_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		WindowFilter_GuiShow(Action,ActionGUI)
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Title", "", "", "Title:", "Placeholders", "Action_SetWindowTitle_Placeholders_Title")
	}
	else if(GoToLabel = "Placeholders_Title")
		SubEventGUI_Placeholders(sActionGUI, "Title")
}
Action_SetWindowTitle_Placeholders_Title:
Action_SetWindowTitle_GuiShow("", "", "Placeholders_Title")
return
Action_SetWindowTitle_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  