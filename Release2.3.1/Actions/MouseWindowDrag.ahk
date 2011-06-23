Action_MouseWindowDrag_Init(Action)
{
	Action.Category := "Window"
}
Action_MouseWindowDrag_ReadXML(Action, XMLAction)
{
}
Action_MouseWindowDrag_Execute(Action, Event, Parameter="")
{
	global EventSchedule
	static sAction, sEvent
	if(!Parameter)
	{
		if(IsObject(sEvent) && !IsObject(sAction)) ;This only happens when the event has finished already
		{
			sEvent := ""
			return 1
		}
		else if(IsObject(sAction)) ;Dragging still in progress
			return -1
		Loop % EventSchedule.len() ;Make sure no drag event is in progress
		{
			if(EventSchedule[A_Index].ID = Event.ID)
				continue
			if(EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowResize") || EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowDrag"))
				return 0
		}
		sAction := Action
		sEvent := Event
		CoordMode, Mouse, Screen
		MouseGetPos, Drag_OriginalMouseX, Drag_OriginalMouseY, Drag_HWND
		WinGetPos, Drag_OriginalWindowX, Drag_OriginalWindowY,,, ahk_id %Drag_HWND%
		Action.tmpOriginalMouseX := Drag_OriginalMouseX
		Action.tmpOriginalMouseY := Drag_OriginalMouseY
		Action.tmpOriginalWindowX := Drag_OriginalWindowX
		Action.tmpOriginalWindowY := Drag_OriginalWindowY
		Action.tmpHWND := Drag_HWND
		Action.tmpActiveWindow := WinExist("A")
		SetTimer, Action_MouseWindowDrag_Timer, 10
	}
	else
	{
		Key := ExtractKey(sEvent.Trigger.Type = "Hotkey" && sEvent.Trigger.Key ? sEvent.Trigger.Key : "LButton")
		GetKeyState, KeyState, %Key%, P
		if(KeyState = "U")  ; Button has been released, so drag is complete.
		{
			SetTimer, Action_MouseWindowDrag_Timer, off
			sAction := ""
			return 1
		}
		GetKeyState, EscapeState, Escape, P
		if(EscapeState = "D" || WinExist("A") != sAction.tmpActiveWindow)  ; Escape has been pressed or another program was activated, so drag is cancelled.
		{
			SetTimer, Action_MouseWindowDrag_Timer, off
			WinMove, % "ahk_id " sAction.tmpHWND,, % sAction.tmpOriginalWindowX, % sAction.tmpOriginalWindowY
			sAction := ""
			return 0
		}
		CoordMode, Mouse, Screen
		MouseGetPos, MouseX, MouseY
		WinGetPos, WinX, WinY,,, % "ahk_id " sAction.tmpHWND
		SetWinDelay, -1 
		newx := sAction.tmpOriginalWindowX + MouseX - sAction.tmpOriginalMouseX
		newy := sAction.tmpOriginalWindowY + MouseY - sAction.tmpOriginalMouseY
		if(abs(MouseX - sAction.tmpOriginalMouseX) > 10 || abs(MouseY - sAction.tmpOriginalMouseY) > 10) ;Allow alt-left clicks
			WinMove, % "ahk_id " sAction.tmpHWND,, newx, newy
	}
	return -1
} 
Action_MouseWindowDrag_DisplayString(Action)
{
	return "Drag window with mouse"
}
Action_MouseWindowDrag_GuiShow(Action, ActionGUI)
{
}
Action_MouseWindowDrag_GuiSubmit(Action, ActionGUI)
{
}

Action_MouseWindowDrag_Timer:
Action_MouseWindowDrag_Execute("","","Timer")
return