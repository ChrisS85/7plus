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

Action_Shutdown_Init(Action)
{
	Action.Category := "System"
	Action.ShutDownSelection := "Shutdown"
}

Action_Shutdown_GuiShow(Action, ActionGUI)
{
	x := ActionGui.x
	y := ActionGui.y
	y += 4
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, Selection:
	
	x += 50
	y -= 4
	
	if(Action.ShutdownSelection = "LogOff")
		Gui, Add, DropDownList, x%x% y%y% hwndhwndSelection, LogOff||ShutDown|Reboot|Hibernate|Standby
	else if(Action.ShutdownSelection = "Shutdown")
		Gui, Add, DropDownList, x%x% y%y% hwndhwndSelection, LogOff|ShutDown||Reboot|Hibernate|Standby
	else if(Action.ShutdownSelection = "Reboot")
		Gui, Add, DropDownList, x%x% y%y% hwndhwndSelection, LogOff|ShutDown|Reboot||Hibernate|Standby
	else if(Action.ShutdownSelection = "Hibernate")
		Gui, Add, DropDownList, x%x% y%y% hwndhwndSelection, LogOff||ShutDown|Reboot|Hibernate||Standby
	else if(Action.ShutdownSelection = "Standby")
		Gui, Add, DropDownList, x%x% y%y% hwndhwndSelection, LogOff||ShutDown|Reboot|Hibernate|Standby||
	
	x -= 50
	y += 30
	
	if(Action.ForceClose)
		Gui, Add, Checkbox, x%x% y%y% w200 hwndhwndForceClose Checked, Force-close applications
	else
		Gui, Add, Checkbox, x%x% y%y% w200 hwndhwndForceClose, Force-close applications
	
	ActionGUI.Text1 := hwndtext1
	ActionGUI.Selection := hwndSelection
	ActionGUI.ForceClose := hwndForceClose
}

Action_Shutdown_GuiSubmit(Action, ActionGUI)
{
	text1 := ActionGUI.Text1
	hwndSelection := ActionGUI.Selection
	hwndForceClose := ActionGUI.ForceClose
	ControlGetText, Selection, , ahk_id %hwndSelection%
	Action.ShutdownSelection := Selection
	ControlGet, ForceClose, Checked, , ,ahk_id %hwndForceClose%
	Action.ForceClose := ForceClose
	WinKill, ahk_id %text1%
	WinKill, ahk_id %hwndSelection%
	WinKill, ahk_id %hwndForceClose%
}