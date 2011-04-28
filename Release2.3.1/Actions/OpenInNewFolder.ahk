Action_OpenInNewFolder_Init(Action)
{
	Action.Category := "Explorer"
}
Action_OpenInNewFolder_ReadXML(Action, XMLAction)
{
}
Action_OpenInNewFolder_Execute(Action, Event)
{
	OpenInNewFolder()
}
Action_OpenInNewFolder_DisplayString(Action)
{
	return "Open explorer folder under mouse in new window/tab"
}
Action_OpenInNewFolder_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_OpenInNewFolder_GuiSubmit(Action, ActionGUI)
{
}