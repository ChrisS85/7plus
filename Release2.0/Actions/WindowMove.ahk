  Action_WindowActivate_ReadXML(Action, ActionFileHandle)
{
	WindowFilter_ReadXML(Action, ActionFileHandle)
	Action.X := xpath(ActionFileHandle, "/X/Text()")
	Action.Y := xpath(ActionFileHandle, "/Y/Text()")
}
Action_WindowActivate_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	WindowFilter_ReadXML(Action, ActionFileHandle, Path)
	xpath(ActionFileHandle, Path "X[+1]/Text()", Action.X)
	xpath(ActionFileHandle, Path "Y[+1]/Text()", Action.Y)
}
Action_WindowActivate_Execute(Action)
{
	hwnd := WindowFilter_Get(Action)
	X := Action.X
	Y := Action.Y
	if(hwnd != 0)
		WinMove, ahk_id %hwnd%,, %X%, %Y%
}