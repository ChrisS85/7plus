Action_WindowState_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)	
	Action.State := xpath(ActionFileHandle, "/State/Text()")
}
Action_WindowState_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
	xpath(ActionFileHandle, Path "State[+1]/Text()", Action.State)	
}
Action_WindowState_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
	{
		if(Action.State = "Minimize")
			WinMinimize ahk_id %hwnd%
		else if(Action.State = "Restore")
			WinRestore ahk_id %hwnd%
		else if(Action.State = "Maximize")
			WinMaximize ahk_id %hwnd%
	}
} 