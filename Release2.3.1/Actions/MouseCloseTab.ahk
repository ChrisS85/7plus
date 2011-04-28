Action_MouseCloseTab_Init(Action)
{
	Action.Category := "Explorer"
}
Action_MouseCloseTab_ReadXML(Action, XMLAction)
{
}
Action_MouseCloseTab_Execute(Action, Event)
{
	MouseCloseTab()
}
Action_MouseCloseTab_DisplayString(Action)
{
	return "Close explorer tab under mouse"
}
Action_MouseCloseTab_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_MouseCloseTab_GuiSubmit(Action, ActionGUI)
{
}