 Action_Copy_Init(Action)
{
	Action_FileOperation_Init(Action)
}

Action_Copy_ReadXML(Action, XMLAction)
{
	Action_FileOperation_ReadXML(Action, XMLAction)
}

Action_Copy_Execute(Action, Event)
{
	Action_FileOperation_ProcessPaths(Action, Event, sources, targets, flags)
	ShellFileOperation(0x2, sources, targets, flags)  
	return 1
}
Action_Copy_DisplayString(Action)
{
	global Settings_Events
	return Action_FileOperation_DisplayString(Action)
}

Action_Copy_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	Action_FileOperation_GuiShow(Action, ActionGUI)
}
Action_Copy_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}   