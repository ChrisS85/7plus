Action_WindowSendToBottom_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
}
Action_WindowSendToBottom_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
}
Action_WindowSendToBottom_Execute(Action)
{
	global PreviousWindow
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
	{
		WinGetClass, class, ahk_id %hwnd%
		if(class != "Shell_TrayWnd" && class != "WorkerW" && class != "Progman")
		{
			WinSet, Bottom,, ahk_id %hwnd%
			WinActivate ahk_id %PreviousWindow% ;Activate previous window so the window doesn't stay active
		}
	}
	return 1
}
Action_WindowSendToBottom_DisplayString(Action)
{
	return "Send window to bottom: " WindowFilter_DisplayString(Action)
}
Action_WindowSendToBottom_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowSendToBottom_GuiSubmit(Action, ActionGUI)
{
	WindowFilter_GuiSubmit(Action,ActionGUI)
}