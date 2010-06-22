 Action_WindowShow_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
}
Action_WindowShow_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
}
Action_WindowShow_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
		WinShow ahk_id %hwnd%
} 