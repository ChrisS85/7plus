Action_MouseClick_Init(Action)
{
	Action.Category := "Input"
	Action.RestorePosition := 1
	Action.Relative := 1
	Action.Button := "Left"
}

Action_MouseClick_ReadXML(Action, XMLAction)
{
	Action.Button := XMLAction.Button
	Action.X := XMLAction.X
	Action.Y := XMLAction.Y
	Action.RestorePosition := XMLAction.RestorePosition
	Action.Relative := XMLAction.Relative
}
Action_MouseClick_Execute(Action, Event)
{
	global
	CoordMode, Mouse, Screen
	MouseGetPos, mx,my
	X := Event.ExpandPlaceholders(Action.X)
	Y := Event.ExpandPlaceholders(Action.Y)
	if(Action.Relative)
		CoordMode, Mouse, Relative
	Button := Action.Button	
	Click %Button% %X%, %Y%
	CoordMode, Mouse, Screen
	if(Action.RestorePosition)
		MouseMove, %mx%, %my%
	return 1
} 

Action_MouseClick_DisplayString(Action)
{
	return "Click " Action.Button " at " Action.X "/" Action.Y (Action.Relative ? " relative to current window" : "")
} 
Action_MouseClick_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI	
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Button", "Left||Middle|Right", "", "Button:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "X", "", "", "X:", "Placeholders", "Action_MouseClick_Placeholders_X")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Y", "", "", "Y:", "Placeholders", "Action_MouseClick_Placeholders_Y")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Relative", "Relative to current window")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "RestorePosition", "Restore previous mouse position")
	}
	else if(GoToLabel = "Placeholders_X")
		SubEventGUI_Placeholders(sActionGUI, "X")
	else if(GoToLabel = "Placeholders_Y")
		SubEventGUI_Placeholders(sActionGUI, "Y")
}
Action_MouseClick_Placeholders_X:
Action_MouseClick_GuiShow("", "", "Placeholders_X")
return
Action_MouseClick_Placeholders_Y:
Action_MouseClick_GuiShow("", "", "Placeholders_Y")
return

Action_MouseClick_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  