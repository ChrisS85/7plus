Action_WindowClose_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
}
Action_WindowClose_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowClose_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_WriteXML(Action, ActionFileHandle, Path)
}
Action_WindowClose_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinClose ahk_id %hwnd%
}
Action_WindowClose_DisplayString(Action)
{
	return "Close Window " WindowFilter_DisplayString(Action)
}
Action_WindowClose_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowClose_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
}