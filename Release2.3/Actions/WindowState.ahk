Action_WindowState_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.Action := "Maximize"
}
Action_WindowState_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.Action := XMLAction.Action
	
	if(Action.Action = "Set Transparency")
		Action.Value := XMLAction.Value
}
Action_WindowState_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	WinGet, state, minmax, ahk_id %hwnd%
	if(Action.Action = "Maximize")
		WinMaximize("ahk_id " hwnd)
	else if(Action.Action = "Minimize")
		WinMinimize("ahk_id " hwnd)
	else if(Action.Action = "Restore")
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Toggle Max/Normal" && state = 1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Toggle Max/Normal")
		WinMaximize("ahk_id " hwnd)
	else if(Action.Action = "Toggle Min/Normal" && state = -1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Normal")
		WinMinimize("ahk_id " hwnd)
	else if(Action.Action = "Toggle Min/Max" && state = -1)
		WinMaximize("ahk_id " hwnd)
	else if(Action.Action = "Toggle Min/Max")
		WinMinimize("ahk_id " hwnd)
	else if(Action.Action = "Toggle Min/Previous state" && state = -1)
		WinActivate, ahk_id %hwnd%
	else if(Action.Action = "Toggle Min/Previous state")
		WinMinimize("ahk_id " hwnd)
	else if(Action.Action = "Maximize->Normal->Minimize" && state = 1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Maximize->Normal->Minimize" && state = 0)
		WinMinimize("ahk_id " hwnd)
	else if(Action.Action = "Minimize->Normal->Maximize" && state = -1)
		WinRestore, ahk_id %hwnd%
	else if(Action.Action = "Minimize->Normal->Maximize" && state = 0)
		WinMaximize("ahk_id " hwnd)
	else if(Action.Action = "Set always on top")
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%
	else if(Action.Action = "Disable always on top")
		WinSet, AlwaysOnTop, Off, ahk_id %hwnd%
	else if(Action.Action = "Toggle always on top")
		WinSet, AlwaysOnTop, Toggle, ahk_id %hwnd%
	else if(Action.Action = "Set Transparency")
	{
		newValue := Action.Value
		if(strStartsWith(newValue,"+")||strStartsWith(newValue,"-")||strStartsWith(newValue,"*")||strStartsWith(newValue,"/"))
		{
			operator := SubStr(newValue,1,1)
			newValue := SubStr(newValue,2)
			WinGet, oldValue, Transparent, ahk_id %hwnd%
			if(operator = "+")
				newValue += oldValue
			else if(operator = "-")
				newValue := oldValue - newValue
			else if(operator = "*")
				newValue := oldValue * newValue
			else if(operator = "/")
				newValue := oldValue / newValue
		}
		outputdebug % "old value " oldvalue " new value " newvalue " operator " operator
		WinSet, Transparent, %newValue%, ahk_id %hwnd%
	}
	return 1
}
Action_WindowState_DisplayString(Action)
{
	return Action.Action " " WindowFilter_DisplayString(Action)
}
Action_WindowState_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Maximize|Minimize|Restore|Toggle Max/Normal|Toggle Min/Normal|Toggle Min/Max|Toggle Min/Previous state|Maximize->Normal->Minimize|Minimize->Normal->Maximize|Set always on top|Disable always on top|Toggle always on top|Set Transparency", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "Text", "tmpHint", "The value below is only used for transparency. Prepend +,-,* and / for relative changes.")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Value", "", "", "Value:")
	WindowFilter_GuiShow(Action,ActionGUI)
}
Action_WindowState_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}