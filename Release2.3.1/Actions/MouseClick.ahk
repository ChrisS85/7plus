Action_MouseClick_Init(Action)
{
	Action.Category := "Input"
	Action.RestorePosition := 1
	Action.Relative := 1
	Action.Button := "Left"
	Action.Double := 0
}

Action_MouseClick_ReadXML(Action, XMLAction)
{
	Action.Button := XMLAction.HasKey("Button") ? XMLAction.Button : Action.Button
	Action.X := XMLAction.HasKey("x") ? XMLAction.X : Action.X
	Action.Y := XMLAction.HasKey("y") ? XMLAction.Y : Action.Y
	Action.RestorePosition := XMLAction.HasKey("RestorePosition") ? XMLAction.RestorePosition : Action.RestorePosition
	Action.Relative :=XMLAction.HasKey("Relative") ? XMLAction.Relative : Action.Relative
	Action.Double := XMLAction.HasKey("Double") ? XMLAction.Double : Action.Double
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
	Double := Action.Double ? 2 : 1
	Click %Button% %X%, %Y% %Double%
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
		SubEventGUI_Add(Action, ActionGUI, "Edit", "X", "", "", "X:", "Placeholders", "Action_MouseClick_Placeholders_X","","","Leave empty to click at current cursor position.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Y", "", "", "Y:", "Placeholders", "Action_MouseClick_Placeholders_Y","","","Leave empty to click at current cursor position.")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Relative", "Position relative to active window")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "RestorePosition", "Restore previous mouse position")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Double", "Double click")
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