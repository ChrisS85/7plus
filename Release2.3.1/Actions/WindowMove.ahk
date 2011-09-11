Action_WindowMove_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.CenterX := 0
	Action.CenterY := 0
	Action.X := 0
	Action.Y := 0
}
Action_WindowMove_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.ReadVar(XMLAction, "X")
	Action.ReadVar(XMLAction, "Y")
	Action.ReadVar(XMLAction, "CenterX")
	Action.ReadVar(XMLAction, "CenterY")
}
Action_WindowMove_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	WinGetPos, curX, curY, curW, curH, ahk_id %hwnd%
	X := Event.ExpandPlaceholders(Action.X)
	Y := Event.ExpandPlaceholders(Action.Y)
	XValue := strTrimLeft(strTrimLeft(strTrimRight(X,"%"),"-"),"+")
	YValue := strTrimLeft(strTrimLeft(strTrimRight(Y,"%"),"-"),"+")
	if(strEndsWith(X,"%"))
		XValue *= A_ScreenWidth/100
	if(strEndsWith(Y,"%"))
		YValue *= A_ScreenHeight/100
	if(strStartsWith(X,"+"))
		XValue += curX
	if(strStartsWith(Y,"+"))
		YValue += curY
	if(strStartsWith(X,"-"))
		XValue -= curX
	if(strStartsWith(Y,"-"))
		YValue -= curY
	if(Action.CenterX)
		XValue -= curW / 2
	if(Action.CenterY)
		YValue -= curH / 2
	WinMove,ahk_id %hwnd%,,%XValue%,%YValue%
	return 1
}
Action_WindowMove_DisplayString(Action)
{
	return "Move Window " WindowFilter_DisplayString(Action) " to " Action.X "/" Action.Y
}
Action_WindowMove_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		WindowFilter_GuiShow(Action,ActionGUI)
		SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Formats: ""100"", ""+100"", ""10%"", ""-10%""")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "X", "", "", "X:", "Placeholders", "Action_WindowMove_Placeholders_X")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Y", "", "", "Y:", "Placeholders", "Action_WindowMove_Placeholders_Y")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "CenterX", "Use X center of window")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "CenterY", "Use Y center of window")
	}
	else if(GoToLabel = "Placeholders_X")
		SubEventGUI_Placeholders(sActionGUI, "X")
	else if(GoToLabel = "Placeholders_Y")
		SubEventGUI_Placeholders(sActionGUI, "Y")
}
Action_WindowMove_Placeholders_X:
Action_SetDirectory_GuiShow("", "", "Placeholders_X")
return
Action_WindowMove_Placeholders_Y:
Action_SetDirectory_GuiShow("", "", "Placeholders_Y")
return
Action_WindowMove_GuiSubmit(Action, ActionGUI)
{
	;WindowFilter_GuiSubmit(Action,ActionGUI)
	SubEventGUI_GUISubmit(Action, ActionGUI)
}