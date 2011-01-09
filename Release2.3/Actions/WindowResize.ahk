Action_WindowResize_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.CenterX := 0
	Action.CenterY := 0
	Action.Width := "100%"
	Action.Height := "100%"
}
Action_WindowResize_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.Width := XMLAction.Width
	Action.Height := XMLAction.Height
	Action.CenterX := XMLAction.CenterX
	Action.CenterY := XMLAction.CenterY
}
Action_WindowResize_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	WinGetPos, curX, curY, curW, curH, ahk_id %hwnd%
	
	Width := Event.ExpandPlaceholders(Action.Width)
	Height := Event.ExpandPlaceholders(Action.Height)
	
	WidthValue := strTrimLeft(strTrimLeft(strTrimLeft(strTrimLeft(strTrimRight(Width,"%"),"*"),"/"),"-"),"+")
	HeightValue := strTrimLeft(strTrimLeft(strTrimLeft(strTrimLeft(strTrimRight(Height,"%"),"*"),"/"),"-"),"+")
	
	if(strEndsWith(Width,"%"))
		WidthValue *= A_ScreenWidth/100
	if(strEndsWith(Height,"%"))
		HeightValue *= A_ScreenHeight/100
		
	if(strStartsWith(Width,"+"))
		WidthValue += curW
	if(strStartsWith(Height,"+"))
		HeightValue += curH
		
	if(strStartsWith(Width,"-"))
		WidthValue -= curW
	if(strStartsWith(Height,"-"))
		HeightValue -= curH
		
	if(strStartsWith(Width,"*"))
		WidthValue *= curW
	if(strStartsWith(Height,"*"))
		HeightValue *= curH
		
	if(strStartsWith(Width,"/"))
		WidthValue /= curW
	if(strStartsWith(Height,"/"))
		HeightValue /= curH
		
	if(Action.CenterX)
		curX -= (WidthValue - curW) / 2
	if(Action.CenterY)
		curY -= (HeightValue - curH) / 2
		
	WinMove,ahk_id %hwnd%,,%curX%,%curY%,%WidthValue%,%HeightValue%
	return 1
}
Action_WindowResize_DisplayString(Action)
{
	return "Resize Window " WindowFilter_DisplayString(Action) " to " Action.Width "/" Action.Height
}
Action_WindowResize_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		WindowFilter_GuiShow(Action,ActionGUI)
		SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Formats: ""100"", ""100%"", ""10%"", ""*2""")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Width", "", "", "Width:", "Placeholders", "Action_WindowResize_Placeholders_X")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Height", "", "", "Height:", "Placeholders", "Action_WindowResize_Placeholders_Y")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "CenterX", "Use X center of window")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "CenterY", "Use Y center of window")
	}
	else if(GoToLabel = "Placeholders_X")
		SubEventGUI_Placeholders(sActionGUI, "X")
	else if(GoToLabel = "Placeholders_Y")
		SubEventGUI_Placeholders(sActionGUI, "Y")
}
Action_WindowResize_Placeholders_X:
Action_SetDirectory_GuiShow("", "", "Placeholders_X")
return
Action_WindowResize_Placeholders_Y:
Action_SetDirectory_GuiShow("", "", "Placeholders_Y")
return
Action_WindowResize_GuiSubmit(Action, ActionGUI)
{
	;WindowFilter_GuiSubmit(Action,ActionGUI)
	SubEventGUI_GUISubmit(Action, ActionGUI)
}