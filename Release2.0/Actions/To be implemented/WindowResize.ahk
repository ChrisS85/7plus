 Action_WindowResize_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)	
	Action.Width := xpath(ActionFileHandle, "/Width/Text()")
	Action.Height := xpath(ActionFileHandle, "/Height/Text()")
}
Action_WindowResize_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
	xpath(ActionFileHandle, Path "Width[+1]/Text()", Action.Width)
	xpath(ActionFileHandle, Path "Height[+1]/Text()", Action.Height)	
}
Action_WindowResize_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	if(hwnd != 0)
	{
		WinGetPos, X, Y, , , ahk_id %hwnd%
		Width := Action.Width
		Height := Action.Height
		WinMove ahk_id %hwnd%, %X%, %Y%, %Width%, %Height%
	}
} 