 Action_WindowActivate_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowActivate_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
}
Action_WindowActivate_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinActivate ahk_id %hwnd%
}