Action_WindowShow_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
}
Action_WindowShow_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowShow_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinShow ahk_id %hwnd%
	return 1
}
Action_WindowShow_DisplayString(Action)
{
	return "Show Window " WindowFilter_DisplayString(Action)
}
Action_WindowShow_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowShow_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
}