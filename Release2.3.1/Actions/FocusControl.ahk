Action_FocusControl_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "Window"
	Action.TargetControl := "Edit1"
}
Action_FocusControl_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.TargetControl := XMLAction.TargetControl
}
Action_FocusControl_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	TargetControl := Action.TargetControl
	if(IsNumeric(TargetControl))
		ControlFocus, ,ahk_id %TargetControl%
	else
		ControlFocus, %TargetControl%, ahk_id %hwnd%
	return 1
}
Action_FocusControl_DisplayString(Action)
{
	return "Focus " Action.TargetControl ", " WindowFilter_DisplayString(Action)
}
Action_FocusControl_GuiShow(Action, ActionGUI)
{
	WindowFilter_GuiShow(Action,ActionGUI)
	SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Enter a window handle, a ClassNN (e.g. ""Edit1""), or text of the control here.")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetControl", "", "", "Target Control:")
}

Action_FocusControl_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 