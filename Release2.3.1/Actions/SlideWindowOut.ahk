Action_SlideWindowOut_Init(Action)
{
	Action.Category := "Window"
	Action.Direction := 1 ;Left
}
Action_SlideWindowOut_ReadXML(Action, XMLAction)
{
	Action.Direction := XMLAction.Direction
}
Action_SlideWindowOut_Execute(Action)
{
	global CSlideWindow, SlideWindows
	outputdebug slide out action
	hwnd := WinExist("A")
	SlideWindow := SlideWindows.GetByWindowHandle(hwnd, ChildIndex)
	if(IsObject(SlideWindow))
	{
		if(Action.Direction = SlideWindow.Direction)
			SlideWindow.SlideOut()
		else if(abs(Action.Direction - SlideWindow.Direction) = 2) ;Opposite direction
			SlideWindow.Release()
		return 1
	}
	SlideWindow := new CSlideWindow(hwnd, Action.Direction)
	outputdebug object created
	if(IsObject(SlideWindow))
		SlideWindows.Append(SlideWindow)
	outputdebug % "len: " SlideWindows.len()
	return 1
} 

Action_SlideWindowOut_DisplayString(Action)
{
	return "Slide active window out of the screen"
}
Action_SlideWindowOut_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Direction", "1: Left|2: Top|3: Right|4: Bottom", "", "Direction:")
}

Action_SlideWindowOut_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}