Action_Restart7plus_Init(Action)
{
	Action.Category := "7plus"
}
Action_Restart7plus_ReadXML(Action, ActionFileHandle)
{
}
Action_Restart7plus_Execute(Action, Event)
{
	reload
	return 1
} 
Action_Restart7plus_DisplayString(Action)
{
	return "Restart 7plus"
}
Action_Restart7plus_GuiShow(Action, ActionGUI)
{
}
Action_Restart7plus_GuiSubmit(Action, ActionGUI)
{
}   