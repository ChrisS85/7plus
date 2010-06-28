Action_WindowActivate_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
}
Action_WindowActivate_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowActivate_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_WriteXML(Action, ActionFileHandle, Path)
}
Action_WindowActivate_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinActivate ahk_id %hwnd%
}
Action_WindowActivate_DisplayString(Action)
{
	return "Activate Window " WindowFilter_DisplayString(Action)
}
Action_WindowActivate_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowActivate_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
}