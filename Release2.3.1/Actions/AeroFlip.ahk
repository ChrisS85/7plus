Action_ShowAeroFlip_Init(Action)
{
	Action.Category := "System"
}
Action_ShowAeroFlip_ReadXML(Action, XMLAction)
{
}
Action_ShowAeroFlip_Execute(Action, Event)
{
	if(!WinActive("ahk_class Flip3D") && !WinActive("ahk_class TaskSwitcherWnd"))
	{
		if(Action.tmpIsRunning) ;Closed after waiting
		{
			Action.tmpIsRunning := 0
			return 1
		}
		else ;Show Aero Flip 3D
		{
			DllCall("Dwmapi.dll\DwmIsCompositionEnabled","IntP",Aero_On)
			if(Aero_On)
				Send ^#{Tab} 
			Else
				Send ^!{Tab}
			Action.tmpIsRunning := 1
			return - 1
		}
	}
	else if(Action.tmpIsRunning) ;Waiting for close
		return -1
	else ;Aero Flip is already triggered otherwise
		return 1
} 
Action_ShowAeroFlip_DisplayString(Action)
{
	return "Show Aero Flip 3D (or task switcher if unavailable)"
}
Action_ShowAeroFlip_GuiShow(Action, ActionGUI)
{
}
Action_ShowAeroFlip_GuiSubmit(Action, ActionGUI)
{
}     