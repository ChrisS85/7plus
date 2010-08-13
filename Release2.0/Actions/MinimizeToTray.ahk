Action_MinimizeToTray_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
}
Action_MinimizeToTray_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_MinimizeToTray_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinTraymin(hwnd)
	return 1
}
Action_MinimizeToTray_DisplayString(Action)
{
	return "Minimize " WindowFilter_DisplayString(Action) " to tray"
}
Action_MinimizeToTray_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_MinimizeToTray_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
} 