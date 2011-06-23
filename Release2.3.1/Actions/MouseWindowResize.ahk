Action_MouseWindowResize_Init(Action)
{
	Action.Category := "Window"
}
Action_MouseWindowResize_ReadXML(Action, XMLAction)
{
}
Action_MouseWindowResize_Execute(Action, Event, Parameter="")
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
			outputdebug % EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowResize") "||" EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowDrag")
			if(EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowResize") || EventSchedule[A_Index].Actions.SubItem("Type", "MouseWindowDrag"))
				return 0
		}
		sAction := Action
		sEvent := Event
		CoordMode, Mouse, Screen
		MouseGetPos, Drag_OriginalMouseX, Drag_OriginalMouseY, Drag_HWND
		WinGetPos, Drag_OriginalWindowX, Drag_OriginalWindowY,Drag_OriginalWindowW,Drag_OriginalWindowH, ahk_id %Drag_HWND%
		Action.tmpOriginalMouseX := Drag_OriginalMouseX
		Action.tmpOriginalMouseY := Drag_OriginalMouseY
		Action.tmpOriginalWindowX := Drag_OriginalWindowX
		Action.tmpOriginalWindowY := Drag_OriginalWindowY
		Action.tmpOriginalWindowW := Drag_OriginalWindowW
		Action.tmpOriginalWindowH := Drag_OriginalWindowH
		Action.tmpLeft := Drag_OriginalMouseX < Drag_OriginalWindowX + Drag_OriginalWindowW / 2
		Action.tmpTop := Drag_OriginalMouseY < Drag_OriginalWindowY + Drag_OriginalWindowH / 2
		Action.tmpHWND := Drag_HWND
		Action.tmpActiveWindow := WinExist("A")
		SetTimer, Action_MouseWindowResize_Timer, 10
	}
	else
	{
		Key := ExtractKey(sEvent.Trigger.Type = "Hotkey" && sEvent.Trigger.Key ? sEvent.Trigger.Key : "LButton")
		GetKeyState, KeyState, %Key%, P
		if(KeyState = "U")  ; Button has been released, so drag is complete.
		{
			SetTimer, Action_MouseWindowResize_Timer, off
			sAction := ""
			return 1
		}
		GetKeyState, EscapeState, Escape, P
		if(EscapeState = "D" || WinExist("A") != sAction.tmpActiveWindow)  ; Escape has been pressed or another program was activated, so drag is cancelled.
		{
			SetTimer, Action_MouseWindowResize_Timer, off
			WinMove, % "ahk_id " sAction.tmpHWND,, % sAction.tmpOriginalWindowX, % sAction.tmpOriginalWindowY, % sAction.tmpOriginalWindowW, % sAction.tmpOriginalWindowH
			sAction := ""
			return 0
		}
		CoordMode, Mouse, Screen
		MouseGetPos, MouseX, MouseY
		WinGetPos, WinX, WinY,,, % "ahk_id " sAction.tmpHWND
		SetWinDelay, -1 
		newx := sAction.tmpLeft ? sAction.tmpOriginalWindowX + MouseX - sAction.tmpOriginalMouseX : sAction.tmpOriginalWindowX
		newy := sAction.tmpTop ? sAction.tmpOriginalWindowY + MouseY - sAction.tmpOriginalMouseY : sAction.tmpOriginalWindowY
		neww := sAction.tmpLeft ? sAction.tmpOriginalWindowW + sAction.tmpOriginalWindowX - newx  : sAction.tmpOriginalWindowW + MouseX - sAction.tmpOriginalMouseX 
		newh := sAction.tmpTop ? sAction.tmpOriginalWindowH + sAction.tmpOriginalWindowY - newy  : sAction.tmpOriginalWindowH + MouseY - sAction.tmpOriginalMouseY 
		if(abs(MouseX - sAction.tmpOriginalMouseX) > 10 || abs(MouseY - sAction.tmpOriginalMouseY) > 10)
			WinMove, % "ahk_id " sAction.tmpHWND,, newx, newy, neww, newh
	}
	return -1
} 
Action_MouseWindowResize_DisplayString(Action)
{
	return "Resize window under cursor with mouse"
}
Action_MouseWindowResize_GuiShow(Action, ActionGUI)
{
}
Action_MouseWindowResize_GuiSubmit(Action, ActionGUI)
{
}

Action_MouseWindowResize_Timer:
Action_MouseWindowResize_Execute("","","Timer")
return