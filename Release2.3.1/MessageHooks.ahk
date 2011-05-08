; see http://msdn.microsoft.com/en-us/library/dd318066(VS.85).aspxs
HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime ){ 
	global HKShowSpaceAndSize,HKAutoCheck,TabNum,TabWindow,TabContainerList,UseTabs, Vista7, ResizeWindow, ShowResizeTooltip, Profiler
	ListLines, Off
	StartTime := A_TickCount
	hwnd += 0
	;On dialog popup, check if its an explorer confirmation dialog
	if(event=0x00008002) ;EVENT_OBJECT_SHOW
	{
		if(HKAutoCheck && Vista7)
			FixExplorerConfirmationDialogs()		
		Profiler.Total.HookProc += A_TickCount - StartTime
		Profiler.Current.HookProc += A_TickCount - StartTime
		return
	}
	if idObject or idChild ;Doesn't each much time, skip for profiling
		return
	WinGet, style, Style, ahk_id %hwnd%
	if (style & 0x40000000)	;return if hwnd is child window, for some reason idChild may be 0 for some children ?!?! ( I hate ms )
		return	
	if(event=0x0016) ;EVENT_SYSTEM_MINIMIZEEND
	{
		Trigger := EventSystem_CreateSubEvent("Trigger","WindowStateChange")
		Trigger.Window := hwnd
		Trigger.Event := "Window minimized"
		OnTrigger(Trigger)
	}
	else if(event=0x8001 && UseTabs) ;EVENT_OBJECT_DESTROY
	{
		; DecToHex(hwnd)
		; if(TabContainerList.ContainsHWND(hwnd))
	}
	else if(event=0x800B) ;EVENT_OBJECT_LOCATIONCHANGE
	{
		WinGet, state, minmax, ahk_id %hwnd%
		if(state = 1)
		{
			Trigger := EventSystem_CreateSubEvent("Trigger","WindowStateChange")
			Trigger.Window := hwnd
			Trigger.Event := "Window maximized"
			OnTrigger(Trigger)
		}
		if(InStr("CabinetWClass,ExploreWClass", WinGetClass("ahk_id " hwnd)))
			ExplorerMoved(hwnd)
	}	
	else if(event = 0x000A && ShowResizeTooltip)
	{
		ResizeWindow := hwnd
		SetTimer, ResizeWindowTooltip, 50
	}
	else if(event = 0x000B && ShowResizeTooltip)
	{
		ResizeWindow := ""
		SetTimer, ResizeWindowTooltip, Off
		ResizeWindowTooltip(true)
		Tooltip
	}	
	Profiler.Total.HookProc := Profiler.Total.HookProc + A_TickCount - StartTime
	Profiler.Current.HookProc := Profiler.Current.HookProc + A_TickCount - StartTime
	ListLines, On
}
ResizeWindowTooltip:
ResizeWindowTooltip()
return
ResizeWindowTooltip(reset = false)
{	
	global ResizeWindow
	static w,h
	if(reset)
	{
		w:=0
		h:=0
		return
	}
	WinGetPos, , , wn, hn, ahk_id %ResizeWindow%
	if(w && h && (w != wn || h != hn))
		Tooltip %w%/%h%
	w := wn
	h := hn
}

;See http://msdn.microsoft.com/en-us/library/ms644991(VS.85).aspx
ShellMessage( wParam, lParam, Msg)
{
	WasCritical := A_IsCritical
	Critical
	ListLines, Off
	global ExplorerPath, HKShowSpaceAndSize, BlinkingWindows, wtmlParam, SuppressTabEvents, UseTabs, PreviousWindow, PreviousExplorerPath,WindowList,Accessor, RecentCreateCloseEvents,Profiler,ToolWindows, ExplorerWindows, LastWindow, LastWindowClass
	StartTime := A_TickCount
	Trigger := EventSystem_CreateSubEvent("Trigger", "OnMessage")
	Trigger.Message := wParam
	Trigger.lParam := lParam
	Trigger.Msg := Msg
	OnTrigger(Trigger)
	If	(wParam=1||wParam=2) ;Window Created/Closed
	{
		lParam += 0
		;Keep a list of recently received create/close messages, because they can be sent multiple times and we only want one.
		if(!IsObject(RecentCreateCloseEvents))
			RecentCreateCloseEvents := Array()
		SetTimer, ClearRecentCreateCloseEvents, -300
		if(!RecentCreateCloseEvents.HasKey(lParam))
		{
			RecentCreateCloseEvents[lParam] := 1
			Trigger := wParam = 1 ? EventSystem_CreateSubEvent("Trigger","WindowCreated") : EventSystem_CreateSubEvent("Trigger","WindowClosed")
			class:=WinGetClass("ahk_Id " lParam)
			Trigger.Window := lParam
			OnTrigger(Trigger)
			;Keep a list of windows and their required info stored. This allows to identify windows which were closed recently.
			if(!WindowList)
				WindowList := Object()
			WinGet, hwnds, list,,, Program Manager
			Loop, %hwnds%
			{
				hwnd := hwnds%A_Index%+0
				WinGetTitle, title, ahk_id %hwnd%
				if(IsObject(WindowList[hwnd]))
					WindowList[hwnd].title := title
				else
				{
					WinGetClass, class, ahk_id %hwnd%
					WinGet, exe, ProcessName, ahk_id %hwnd%
					WindowList[hwnd] := Object("class", class, "title", title, "Executable", exe)
				}
			}
			;Remove all closed windows, except the most recently closed one.
			;NOTE: This could prevent some window identification from working in theory, but it is extremely unlikely 
			;      and won't happen unless multiple windows are closed rapidly.
			enum = WindowList._newEnum()
			while enum[hwnd, value]
				if(hwnd != lParam && !WindowList.HasKey(hwnd))
					WindowList.Remove(hwnd)
		}
		if(wParam=2)
		{
			; if(ExplorerWindows.SubItem("hwnd",lParam))
				; ExplorerDestroyed(lParam)
			Loop % ToolWindows.MaxIndex()
			{
				if(ToolWindows[A_Index].hParent = lParam && ToolWindows[A_Index].AutoClose)
				{
					WinClose % "ahk_id " ToolWindows[A_Index].hGui
					ToolWindows.Remove(A_Index)
					break
				}
			}
		}
	}	
	;Blinking windows detection, add new blinking windows
	else if(wParam=32774)
	{
		lParam += 0
		class:=WinGetClass("ahk_id " lParam)
		; outputdebug blinking window %class%
		if(BlinkingWindows.indexOf(lParam)=0)
		{			
			BlinkingWindows.Append(lParam)
			ct:=BlinkingWindows.len()
		}
	}	
	;Window Activation
	else if(wParam=4||wParam=32772) ;HSHELL_WINDOWACTIVATED||HSHELL_RUDEAPPACTIVATED
	{
		lParam += 0
		Trigger := Object("base", TriggerBase)
		Trigger.Type := "WindowActivated"
		OnTrigger(Trigger)
		;Blinking windows detection, remove activated windows
		if(x:=BlinkingWindows.indexOf(lParam))
			BlinkingWindows.Delete(x)
		; DecToHex(lParam)
		class:=WinGetClass("ahk_id " lParam)
		if(Accessor.GUINum && WinGetTitle("A") != Accessor.WindowTitle)
			AccessorClose()
		;If we change from another program to explorer/desktop/dialog
		if(WinActive("ahk_group ExplorerGroup")||WinActive("ahk_group DesktopGroup")||IsDialog())
		{
			if(!WinActive("ahk_group DesktopGroup")) ;By doing this, recall explorer path works also when double clicking desktop to launch explorer
				ExplorerPath:=GetCurrentFolder()
				
			;Paste text/image as file file creation
			CreateFileFromClipboard()
		}
		if(InStr("CabinetWClass,ExploreWClass", LastWindowClass) && LastWindowClass && !ExplorerWindows.TabContainerList.TabCreationInProgress && !ExplorerWindows.TabContainerList.TabActivationInProgress)
			ExplorerDeactivated(LastWindow)
		LastWindow := lParam
		LastWindowClass := WinGetClass("ahk_id " lParam)
		if(InStr("CabinetWClass,ExploreWClass", LastWindowClass) && LastWindowClass && !ExplorerWindows.TabContainerList.TabCreationInProgress && !ExplorerWindows.TabContainerList.TabActivationInProgress)
			ExplorerActivated(LastWindow)
	}
	;Redraw is fired on Explorer path change
	else if(wParam=6)
	{
		lParam += 0
		;Detect changed path		
		if(InStr("CabinetWClass,ExploreWClass", WinGetClass("ahk_id " lParam)))
		{
			ExplorerPathChanged(ExplorerWindows.SubItem("hwnd", lParam))
			; newpath:=GetCurrentFolder()
			; if(newpath && newpath!=ExplorerPath)
			; {
				; outputdebug Explorer path changed from %ExplorerPath% to %newpath%
				; ExplorerPathChanged(ExplorerPath, newpath)
				; PreviousExplorerPath := ExplorerPath
				; ExplorerPath := newpath
				; Trigger := EventSystem_CreateSubEvent("Trigger","ExplorerPathChanged")
				; OnTrigger(Trigger)
				; if(UseTabs && !SuppressTabEvents && hwnd:=WinActive("ahk_group ExplorerGroup"))
					; UpdateTabs()
			; }
		}
	}
	Profiler.Total.ShellMessage := Profiler.Total.ShellMessage + A_TickCount - StartTime
	Profiler.Current.ShellMessage := Profiler.Current.ShellMessage + A_TickCount - StartTime
	ListLines, On
	if(!WasCritical)
		Critical, Off
}

;Timer for clearing the list of recently received create/close events
ClearRecentCreateCloseEvents:
RecentCreateCloseEvents := Array()
return