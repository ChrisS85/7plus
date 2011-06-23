Action_InvertSelection_Init(Action)
{
	Action.Category := "Explorer"
}

Action_InvertSelection_ReadXML(Action, XMLAction)
{
}
Action_InvertSelection_Execute(Action, Event)
{
	global
	InvertSelection(WinExist("A"))
	return 1
} 

Action_InvertSelection_DisplayString(Action)
{
	return "Invert selection of active explorer window"
} 
Action_InvertSelection_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}

Action_InvertSelection_GuiSubmit(Action, ActionGUI)
{
}