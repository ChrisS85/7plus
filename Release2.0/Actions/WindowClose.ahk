Action_WindowClose_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.ForceClose := 0
}
Action_WindowClose_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
	Action.ForceClose := xpath(TriggerFileHandle, "/ForceClose/Text()")
}
Action_WindowClose_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
	{
		if(Action.ForceClose)
			CloseKill(hwnd)
		else
			WinClose ahk_id %hwnd%
	}
	return 1
}
Action_WindowClose_DisplayString(Action)
{
	return "Close Window " WindowFilter_DisplayString(Action)
}
Action_WindowClose_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
	SubEventGUI_Add(Action, ActionGUI, "Checkbox", "ForceClose", "Force-close applications", "", "")
}
Action_WindowClose_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
}