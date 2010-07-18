Action_ShowSettings_Init(Action)
{
	Action.Category := "7plus"
}
Action_ShowSettings_ReadXML(Action, ActionFileHandle)
{
}
Action_ShowSettings_Execute(Action, Event)
{
	DetectHiddenWindows, Off
	if(WinExist("7plus Settings"))
		WinActivate 7plus Settings
	else
		ShowSettings()
	return 1
} 
Action_ShowSettings_DisplayString(Action)
{
	return "Show 7plus Settings"
}
Action_ShowSettings_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_ShowSettings_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  