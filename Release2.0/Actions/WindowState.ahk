Action_WindowState_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.Action := "Maximize"
}
Action_WindowState_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
	Action.Action := xpath(ActionFileHandle, "/Action/Text()")
}
Action_WindowState_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	WinGet, state, minmax, ahk_id %hwnd%
	
	if(Action.Action = "Maximize")
		WinMaximize, ahk_id %hwnd%
	else if(Action.Action = "Minimize")
		WinMinimize, ahk_id %hwnd%
	else if(Action.Action = "Restore")
	{
		WinRestore, ahk_id %hwnd%
		WinRestore, ahk_id %hwnd%
	}
	else if(Action.Action = "Toggle Max/Normal" && state = 1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Toggle Max/Normal")
		WinMaximize, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Normal" && state = -1)
	{
		WinRestore, ahk_id %hwnd%
		WinRestore, ahk_id %hwnd%
	}
	else if(Action.Action = "Toggle Min/Normal")
		WinMinimize, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Max" && state = -1)
		WinMaximize, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Max")
		WinMinimize, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Previous state" && state = -1)
		WinActivate, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Previous state")
		WinMinimize, ahk_id %hwnd%
	else if(Action.Action = "Maximize->Normal->Minimize" && state = 1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Maximize->Normal->Minimize" && state = 0)
		WinMinimize, ahk_id %hwnd%
	else if(Action.Action = "Minimize->Normal->Maximize" && state = -1)
	{
		WinRestore, ahk_id %hwnd%
		WinRestore, ahk_id %hwnd%
	}
	else if(Action.Action = "Minimize->Normal->Maximize" && state = 0)
		WinMaximize, ahk_id %hwnd%
	else if(Action.Action = "Set always on top")
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%
	else if(Action.Action = "Disable always on top")
		WinSet, AlwaysOnTop, Off, ahk_id %hwnd%
	else if(Action.Action = "Toggle always on top")
		WinSet, AlwaysOnTop, Toggle, ahk_id %hwnd%
	return 1
}
Action_WindowState_DisplayString(Action)
{
	return Action.Action " " WindowFilter_DisplayString(Action)
}
Action_WindowState_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Maximize|Minimize|Restore|Toggle Max/Normal|Toggle Min/Normal|Toggle Min/Max|Toggle Min/Previous state|Maximize->Normal->Minimize|Minimize->Normal->Maximize|Set always on top|Disable always on top|Toggle always on top", "", "Action:")
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowState_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}