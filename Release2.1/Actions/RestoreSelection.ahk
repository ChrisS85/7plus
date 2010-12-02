Action_RestoreSelection_Init(Action)
{
	Action.Category := "Explorer"
}
Action_RestoreSelection_ReadXML(Action, XMLAction)
{
}
Action_RestoreSelection_Execute(Action, Event)
{
	RestoreExplorerSelection()
	return 1
} 
Action_RestoreSelection_DisplayString(Action)
{
	return "Restore file selection"
}
Action_RestoreSelection_GuiShow(Action, ActionGUI)
{
}
Action_RestoreSelection_GuiSubmit(Action, ActionGUI)
{
}   