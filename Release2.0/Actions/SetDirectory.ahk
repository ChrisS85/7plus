Action_SetDirectory_ReadXML(Action, ActionFileHandle)
{
	Action.Path := xpath(ActionFileHandle, "/Path/Text()")
	WindowFilter_ReadXML(Action,ActionFileHandle)
}
Action_SetDirectory_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Path[+1]/Text()", Action.Path)
	WindowFilter_WriteXML(Action, ActionFileHandle, Path)
}
Action_SetDirectory_Execute(Action, Event)
{
	hwnd := WindowFilter_Get(Action)
	path := Event.ExpandPlaceholders(Action.Path)
	StringReplace, path, path, ",,All
	outputdebug navigate %path% %hwnd%
	ShellNavigate(Path,hwnd)
	return 1
} 

Action_SetDirectory_DisplayString(Action)
{
	return "Set Explorer directory to: " Action.Path
}

Action_SetDirectory_Init(Action)
{
	Action.Category := "Explorer"
	Action.WindowMatchType := "Active"
}

Action_SetDirectory_GuiShow(Action, ActionGUI)
{
	x := ActionGui.x
	y := ActionGui.y
	y += 4
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, Path:
	
	x += 50
	y -= 4
	w := 200
	path := Action.Path
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndPath, %path%
	
	x -= 50
	y += 30
	ActionGUI.x := x
	ActionGUI.y := y
	WindowFilter_GUIShow(Action, ActionGUI)
	
	ActionGUI.Text1 := hwndtext1
	ActionGUI.Path:= hwndPath
}

Action_SetDirectory_GuiSubmit(Action, ActionGUI)
{
	text1 := ActionGUI.Text1
	hwndPath := ActionGUI.Path
	ControlGetText, Path, , ahk_id %hwndPath%
	Action.Path := Path
	WindowFilter_GUISubmit(Action, ActionGUI)
	WinKill, ahk_id %text1%
	WinKill, ahk_id %hwndPath%
} 