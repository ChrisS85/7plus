Trigger_Timer_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.ShowProgress := 0
	Trigger.Restart := 0
}
Trigger_Timer_ReadXML(Trigger, XMLTrigger)
{	
	Trigger.Time := XMLTrigger.Time
	Trigger.ShowProgress := XMLTrigger.ShowProgress
	Trigger.Restart := XMLTrigger.Restart
	Trigger.Text := XMLTrigger.Text
}

Trigger_Timer_Enable(Trigger, Event)
{
	if(!Trigger.tmpStart)
		Trigger_Timer_Start(Trigger)
	if(Trigger.ShowProgress)
	{
		if(!Trigger.tmpGUINum)
		{
			GUINum := GetFreeGuiNum(10)
			if(GUINum)
			{
				Trigger.tmpGUINum := GUINum
				Gui, %GUINum%:Add, Text, hwndEventName w200,% Trigger.Text ? Trigger.Text : Event.Name
				Gui, %GUINum%:Add, Progress, hwndProgress w200 -Smooth, 100
				GUI, %GUINum%:Add, Text, hwndText w200, Time left:
				GUI, %GUINum%:Add, Button, hwndStartPause gTimer_StartPause y4 w100, Pause
				GUI, %GUINum%:Add, Button, hwndStop gTimer_Stop y+4 w100, Stop
				GUI, %GUINum%:Add, Button, hwndReset gTimer_Reset y+4 w100, Reset
				GUI, %GUINum%:+AlwaysOnTop -SysMenu -Resize
				Sleep 500
				GUI, %GUINum%:Show,,Timer
				Trigger.tmpProgress := Progress
				Trigger.tmpText := Text
				Trigger.tmpStartPause := StartPause
				Trigger.tmpStop := Stop
				Trigger.tmpResetHandle := Reset
				Trigger.tmpEventName := EventName
				SetTimer, UpdateTimerProgress, 1000
			}
		}
	}
}
Trigger_Timer_PrepareCopy(Timer,Event)
{
	Event.Trigger.tmpState := Event.Enabled
}
Trigger_Timer_PrepareReplacement(Timer, Original, Copy)
{
	Copy.Trigger.tmpIsPaused := Original.Trigger.tmpIsPaused
	Copy.Trigger.tmpStart := Original.Trigger.tmpStart
	Copy.Trigger.tmpStartNice := Original.Trigger.tmpStartNice
	Copy.Trigger.tmpProgress := Original.Trigger.tmpProgress
	Copy.Trigger.tmpText := Original.Trigger.tmpText
	Copy.Trigger.tmpStartPause := Original.Trigger.tmpStartPause
	Copy.Trigger.tmpStop := Original.Trigger.tmpStop
	Copy.Trigger.tmpResetHandle := Original.Trigger.tmpResetHandle
	Copy.Trigger.tmpGUINum := Original.Trigger.tmpGUINum
	Copy.Trigger.tmpReset := Original.Trigger.tmpReset
	Copy.Trigger.tmpEventName := Original.Trigger.tmpEventName
}
Timer_StartPause:
Trigger_Timer_StartPause(TimerEventFromGUINumber(A_GUI).Trigger)
return
Timer_Stop:
Trigger_Timer_Stop(TimerEventFromGUINumber(A_GUI))
return
Timer_Reset:
Trigger_Timer_Reset(TimerEventFromGUINumber(A_GUI).Trigger)
return
AddTimer:
AddTimer()
return
AddTimer()
{
	global Events, Settings_Events
	Event := EventSystem_RegisterEvent("") ;Create new event without registering it in the event list so it won't increase max id
	Event.Trigger := EventSystem_CreateSubEvent("Trigger", "Timer")
	Event := GUI_EditEvent(Event)
	if(Event)
	{
		Events.HighestID := max(Events.HighestID, Settings_Events.HighestID) + 1
		Event.ID := Events.HighestID
		Events.Add(Event)
		Event.Enable()
	}
}
TimerEventFromGUINumber(number)
{
	global Events, TemporaryEvents
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "Timer" && Events[A_Index].Trigger.tmpGUINum = number)
			return Events[A_Index]
	}
	Loop % TemporaryEvents.len()
	{
		if(TemporaryEvents[A_Index].Trigger.Type = "Timer" && TemporaryEvents[A_Index].Trigger.tmpGUINum = number)
			return TemporaryEvents[A_Index]
	}
	return 0
}
Trigger_Timer_StartPause(Trigger)
{
	if(Trigger.tmpIsPaused)
		Trigger_Timer_Start(Trigger)
	else
		Trigger_Timer_Pause(Trigger)
}
Trigger_Timer_Start(Trigger)
{
	if(!Trigger.tmpIsPaused)
	{
		Trigger.tmpStart := A_TickCount
		Trigger.tmpStartNice := A_Now
	}
	else
	{
		Trigger.tmpStart := A_TickCount - Trigger.tmpIsPaused ;Also stores time that passed already
		nicetime := A_Now
		nicetime += -Trigger.tmpIsPaused * 1000, seconds
		Trigger.tmpStartNice := nicetime
	}
	Trigger.tmpIsPaused := false
	if(Trigger.ShowProgress && Trigger.tmpGUINum)
	{
		hwndStartPause := Trigger.tmpStartPause
		if(!Trigger.tmpReset)
			ControlSetText,,Pause, ahk_id %hwndStartPause%
	}
}
Trigger_Timer_Pause(Trigger)
{
	if(Trigger.ShowProgress && Trigger.tmpGUINum)
	{
		hwndStartPause := Trigger.tmpStartPause
		if(!Trigger.tmpReset)
			ControlSetText,,Start, ahk_id %hwndStartPause%
	}
	if(!Trigger.tmpIsPaused)
		Trigger.tmpIsPaused := A_TickCount - Trigger.tmpStart
}
Trigger_Timer_Stop(Event)
{
	Event.SetEnabled(false)
	Event.Trigger.Disable(Event)
}
Trigger_Timer_Reset(Trigger)
{
	Trigger.tmpReset := 1
	if(Trigger.tmpIsPaused)
		Trigger.tmpIsPaused := 0.001 ;one millisecond shouldn't be too bad :)
	Trigger.tmpStart := A_TickCount
	Trigger.tmpStartNice := A_Now
}
Trigger_Timer_Disable(Trigger, Event)
{
	if(Event.enabled) ;Avoid disabling timers when applying settings, unless real disable is desired
		return
	Trigger.tmpStart := ""
	Trigger.tmpStartNice := ""
	Trigger.tmpIsPaused := 0
	if(Trigger.ShowProgress)
	{
		GUINum := Trigger.tmpGUINum
		if(GUINum)
		{
			Trigger.tmpGUINum := ""
			Trigger.tmpProgress := ""
			Trigger.tmpText := ""
			Trigger.tmpEventName := ""
			GUI, %GUINum%:Destroy
		}
	}
}
Trigger_Timer_Delete(Trigger, Event)
{
	Event.Disable()
}
UpdateTimerProgress:
UpdateTimerProgress()
return
UpdateTimerProgress()
{
	global Events, TemporaryEvents
	Loop % Events.len()
	{
		Event := Events[A_Index]
		GoSub UpdateTimerProgress_InnerLoop
	}
	Loop % TemporaryEvents.len()
	{
		Event := TemporaryEvents[A_Index]
		GoSub UpdateTimerProgress_InnerLoop
	}
	return
	
	UpdateTimerProgress_InnerLoop:
	if(Event.Trigger.Type = "Timer") ;Update all timers
	{
		timer := Event.Trigger
		if(Event.Enabled && (!timer.tmpIsPaused || timer.tmpReset) && timer.ShowProgress && timer.tmpGUINum)
		{
			GUINum := timer.tmpGUINum
			progress := Round(100 - (A_TickCount - timer.tmpStart)/timer.Time * 100)
			hours := max(Floor((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 / 3600),0)
			minutes := max(Floor(((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 - hours * 3600)/60),0)
			seconds := max(Floor(((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 - hours * 3600 - minutes * 60))+1,0)
			Time := "Time left: " (strLen(hours) = 1 ? "0" hours : hours) ":" (strLen(minutes) = 1 ? "0" minutes : minutes) ":" (strLen(seconds) = 1 ? "0" seconds : seconds)
			hwndProgress := timer.tmpProgress
			SendMessage, 0x402, progress,0,, ahk_id %hwndProgress%
			hwndtext := timer.tmpText
			ControlSetText,,%Time%, ahk_id %hwndtext%
			hwndEventName := timer.tmpEventName
			timer.tmpReset := 0
		}
	}
	return
}

;Called every second to check if time has run out yet
Trigger_Timer_Matches(Trigger, Filter, Event)
{
	if(Trigger.tmpStart && !Trigger.tmpIsPaused && A_TickCount > (Trigger.tmpStart + Trigger.Time))
	{
		if(Trigger.Restart)
		{
			Trigger.tmpStart := 0
			Trigger.Enable(Event)
		}
		else
		{
			Event.SetEnabled(false)
			Event.Trigger.Disable(Event)
		}
		return true
	}
	return false
}

Trigger_Timer_DisplayString(Trigger)
{
	hours := Floor(Trigger.Time / 1000 / 3600)
	minutes := Floor((Trigger.Time / 1000 - hours * 3600)/60)
	seconds := Floor((Trigger.Time / 1000 - hours * 3600 - minutes * 60))
	start := Trigger.tmpStartNice
	FormatTime, start, start, Time
	return "Timer - Trigger in " (strLen(hours) = 1 ? "0" hours : hours) ":" (strLen(minutes) = 1 ? "0" minutes : minutes) ":" (strLen(seconds) = 1 ? "0" seconds : seconds)
}

Trigger_Timer_GuiShow(Trigger, TriggerGUI)
{
	hours := Floor(Trigger.Time / 1000 / 3600)
	minutes := Floor((Trigger.Time / 1000 - hours * 3600)/60)
	seconds := Floor((Trigger.Time / 1000 - hours * 3600 - minutes * 60))
	Trigger.tmpTime := (strLen(hours) = 1 ? "0" hours : hours) (strLen(minutes) = 1 ? "0" minutes : minutes) (strLen(seconds) = 1 ? "0" seconds : seconds)
	SubEventGUI_Add(Trigger, TriggerGUI, "Time", "tmpTime", "", "", "Start in:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "ShowProgress", "Show remaining time", "", "")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Restart", "Restart timer on zero", "", "")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Text", "", "", "Window text:")
}

Trigger_Timer_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger, TriggerGUI)
	hours := SubStr(Trigger.tmptime, 1, 2)
	minutes := SubStr(Trigger.tmptime, 3, 2)
	seconds := SubStr(Trigger.tmptime, 5, 2)
	Trigger.Time := (hours * 3600 + minutes * 60 + seconds) * 1000
} 

TriggerTimer:
TriggerTimer()
return
TriggerTimer()
{
	Trigger := EventSystem_CreateSubEvent("Trigger", "Timer")
	OnTrigger(Trigger)
}