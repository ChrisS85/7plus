Action_TaskButtonClose_Init(Action)
{
	Action.Category := "Windows"
}
Action_TaskButtonClose_ReadXML(Action, XMLAction)
{
}
Action_TaskButtonClose_Execute(Action, Event)
{
	TaskButtonClose()
}
Action_TaskButtonClose_DisplayString(Action)
{
	return "Close window belonging to task button under the mouse"
}
Action_TaskButtonClose_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_TaskButtonClose_GuiSubmit(Action, ActionGUI)
{
}