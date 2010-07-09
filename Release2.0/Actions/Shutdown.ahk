Action_Shutdown_Init(Action)
{
	Action.Category := "System"
	Action.ShutDownSelection := "Shutdown"
	Action.ForceClose := 0
}
Action_Shutdown_ReadXML(Action, ActionFileHandle)
{
	Action.ShutdownSelection := xpath(ActionFileHandle, "/ShutdownSelection/Text()")
	Action.ForceClose := xpath(ActionFileHandle, "/ForceClose/Text()")
}
Action_Shutdown_Execute(Action)
{
	if(Action.ShutdownSelection = "LogOff")
		code := 0
	else if(Action.ShutdownSelection = "Shutdown")
		code := 1 + 8
	else if(Action.ShutdownSelection = "Reboot")
		code := 2
	else
	{
		; Parameter #1: Pass 1 instead of 0 to hibernate rather than suspend.
		; Parameter #2: Pass 1 instead of 0 to suspend immediately rather than asking each application for permission.
		; Parameter #3: Pass 1 instead of 0 to disable all wake events.
		if(Action.ShutdownSelection = "Hibernate")
			DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
		else if(Action.ShutdownSelection = "Standby")
			DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
		return 1
	}
	if(Action.ForceClose)
		code += 4
	Shutdown, %code%
	return 1
} 

Action_Shutdown_DisplayString(Action)
{
	return Action.ShutdownSelection
}
Action_Shutdown_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "ShutdownSelection", "LogOff|Shutdown|Reboot|Hibernate|Standby", "", "Selection:")
	SubEventGUI_Add(Action, ActionGUI, "Checkbox", "ForceClose", "Force-close applications", "", "")
}

Action_Shutdown_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}