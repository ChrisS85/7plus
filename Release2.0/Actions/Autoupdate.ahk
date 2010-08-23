Action_AutoUpdate_Init(Action)
{
	Action.Category := "7plus"
}
Action_AutoUpdate_ReadXML(Action, XMLAction)
{
}
Action_AutoUpdate_Execute(Action, Event)
{
	AutoUpdate()
	return 1
} 
Action_AutoUpdate_DisplayString(Action)
{
	return "7plus Autoupdate"
}
Action_AutoUpdate_GuiShow(Action, ActionGUI)
{
}
Action_AutoUpdate_GuiSubmit(Action, ActionGUI)
{
}     