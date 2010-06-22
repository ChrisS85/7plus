 Action_WindowClose_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowClose_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
}
Action_WindowClose_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinClose ahk_id %hwnd%
}