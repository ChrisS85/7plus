Action_Exit7plus_Init(Action)
{
	Action.Category := "7plus"
}
Action_Exit7plus_ReadXML(Action, XMLAction)
{
}
Action_Exit7plus_Execute(Action, Event)
{
	GoSub ExitSub
	return 1
} 
Action_Exit7plus_DisplayString(Action)
{
	return "Exit 7plus"
}
Action_Exit7plus_GuiShow(Action, ActionGUI)
{
}
Action_Exit7plus_GuiSubmit(Action, ActionGUI)
{
}    