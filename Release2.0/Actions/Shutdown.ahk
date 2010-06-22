Action_Shutdown_ReadXML(Action, ActionFileHandle)
{
	Action.ShutdownSelection := xpath(ActionFileHandle, "/ShutdownSelection/Text()")
	Action.ForceClose := xpath(ActionFileHandle, "/ForceClose/Text()")
}
Action_Shutdown_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "ShutdownSelection[+1]/Text()", Action.ShutdownSelection)
	xpath(ActionFileHandle, Path "ForceClose[+1]/Text()", Action.ForceClose)
}
Action_Shutdown_Execute(Action)
{
	if(Action.ShutdownSelection = "Logoff")
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
		return
	}
	if(Action.ForceClose)
		code += 4
	Shutdown, %code%
	return
} 