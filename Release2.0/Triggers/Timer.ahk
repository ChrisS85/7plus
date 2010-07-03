Trigger_Timer_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.ShowProgress := 0
	Trigger.Restart := 0
	outputdebug("Init" Trigger.showprogress)
}
Trigger_Timer_ReadXML(Trigger, TriggerFileHandle)
{	
	Trigger.Time := xpath(TriggerFileHandle, "/Time/Text()")
	Trigger.ShowProgress := xpath(TriggerFileHandle, "/ShowProgress/Text()")
	Trigger.Restart := xpath(TriggerFileHandle, "/Restart/Text()")
	outputdebug("read" Trigger.Showprogress)
}

Trigger_Timer_Enable(Trigger, Event)
{
	if(!Trigger.tmpStart)
		Trigger_Timer_Start(Trigger)
	if(Trigger.ShowProgress)
	{
		x := Trigger.tmpGUINum
		outputdebug x %x%
		MainText := Event.Name
		if(!Trigger.tmpGUINum)
		{
			outputdebug enable
			GUINum := GetFreeGuiNum(10)
			if(GUINum)
			{
				outputdebug guinum found
				Trigger.tmpGUINum := GUINum
				Gui, %GUINum%:Add, Text, w200,%MainText%
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
				Trigger.tmpReset := Reset
				;Progress, %GUINum%:M P100  ,Time left: , %MainText%, %Title%
				SetTimer, UpdateTimerProgress, 1000
			}
		}
	}
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
TimerEventFromGUINumber(number)
{
	global Events
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "Timer" && Events[A_Index].Trigger.tmpGUINum = number)
			return Events[A_Index]
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
	Event.enabled := false
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
	if(Trigger.ShowProgress)
	{
		GUINum := Trigger.tmpGUINum
		if(GUINum)
		{
			Trigger.tmpGUINum := ""
			Trigger.tmpProgress := ""
			Trigger.tmpText := ""
			GUI, %GUINum%:Destroy
			outputdebug disable
			;Progress, %GUINum%:Off
		}
	}
}
UpdateTimerProgress:
UpdateTimerProgress()
return
UpdateTimerProgress()
{
	global Events
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "Timer")
		{
			timer := Events[A_Index].Trigger
			if(Events[A_Index].Enabled && (!timer.tmpIsPaused || timer.tmpReset) && timer.ShowProgress && timer.tmpGUINum)
			{
				GUINum := timer.tmpGUINum
				progress := Round(100 - (A_TickCount - timer.tmpStart)/timer.Time * 100)
				hours := Floor((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 / 3600)
				minutes := Floor(((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 - hours * 3600)/60)
				seconds := Floor(((timer.Time - (A_TickCount - timer.tmpStart)) / 1000 - hours * 3600 - minutes * 60))
				Time := "Time left: " (strLen(hours) = 1 ? "0" hours : hours) ":" (strLen(minutes) = 1 ? "0" minutes : minutes) ":" (strLen(seconds) = 1 ? "0" seconds : seconds)
				hwndProgress := timer.tmpProgress
				SendMessage, 0x402, progress,0,, ahk_id %hwndProgress%
				hwndtext := timer.tmpText
				ControlSetText,,%Time%, ahk_id %hwndtext%
				timer.tmpReset := 0
				outputdebug update %hwndprogress% %progress% pos %errorlevel%
				;SendMessage, 0x00E3, 1, 0, , ahk_id %hwndProgress%		
				outputdebug range %errorlevel%
				;Progress, %GUINum%:%progress%, %Time%, %MainText%, Timer
			}
		}
	 }
}
Trigger_Timer_Matches(Trigger, Filter, Event)
{
	if(Trigger.tmpStart && !Trigger.tmpIsPaused && A_TickCount > (Trigger.tmpStart + Trigger.Time))
	{
		if(Trigger.Restart)
			Trigger.Enable(Event)
		else
		{
			Event.Enabled := 0
			Event.Trigger.Disable(Event)
		}
		return true
	}
	return false
}

Trigger_Timer_DisplayString(Trigger)
{
	outputdebug("Trigger time in ms:" Trigger.time)
	hours := Floor(Trigger.Time / 1000 / 3600)
	minutes := Floor((Trigger.Time / 1000 - hours * 3600)/60)
	seconds := Floor((Trigger.Time / 1000 - hours * 3600 - minutes * 60))
	start := Trigger.tmpStartNice
	FormatTime, start, start, Time
	return "Timer - Trigger in " (strLen(hours) = 1 ? "0" hours : hours) ":" (strLen(minutes) = 1 ? "0" minutes : minutes) ":" (strLen(seconds) = 1 ? "0" seconds : seconds) (Trigger.tmpIsPaused ? ", currently paused" : ", started at " start)
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
}

Trigger_Timer_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger, TriggerGUI)
	outputdebug("time " trigger.tmptime)
	hours := SubStr(Trigger.tmptime, 1, 2)
	minutes := SubStr(Trigger.tmptime, 3, 2)
	seconds := SubStr(Trigger.tmptime, 5, 2)
	outputdebug %hours%:%minutes%:%seconds%
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