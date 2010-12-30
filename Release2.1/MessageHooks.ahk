; see http://msdn.microsoft.com/en-us/library/dd318066(VS.85).aspxs
HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime ){ 
	global HKShowSpaceAndSize,HKAutoCheck,TabNum,TabWindow,TabContainerList,UseTabs, Vista7, ResizeWindow, ShowResizeTooltip
	ListLines, Off
	;On dialog popup, check if its an explorer confirmation dialog
	if(event=0x00008002) ;EVENT_OBJECT_SHOW
	{
		if(HKAutoCheck && Vista7)
			FixExplorerConfirmationDialogs()
		return
	}
	;outputdebug WinEventHook(%event%, %hwnd%, %idObject%, %idChild%, %dwEventThread%, %dwmsEventTime%)
	if idObject or idChild
		return
	WinGet, style, Style, ahk_id %hwnd%
	if (style & 0x40000000)					;RETURN if hwnd is child window, for some reason idChild may be 0 for some children ?!?! ( I hate ms )
		return	
	if(event=0x0016) ;EVENT_SYSTEM_MINIMIZEEND
	{
		Trigger := EventSystem_CreateSubEvent("Trigger","WindowStateChange")
		Trigger.Window := hwnd
		Trigger.Event := "Window minimized"
		OnTrigger(Trigger)
	}
	if(event=0x8001 && UseTabs) ;EVENT_OBJECT_DESTROY
	{
		DecToHex(hwnd)
		if(TabContainerList.ContainsHWND(hwnd))		
		{
			UnregisterSelectionChangedEvents(hwnd)
			; outputdebug tab closed
			ExplorerDestroyed(hwnd)
		}
		return
	}
	if(event=0x800B) ;EVENT_OBJECT_LOCATIONCHANGE
	{
		WinGet, state, minmax, ahk_id %hwnd%
		if(state = 1)
		{
			Trigger := EventSystem_CreateSubEvent("Trigger","WindowStateChange")
			Trigger.Window := hwnd
			Trigger.Event := "Window maximized"
			OnTrigger(Trigger)
		}
	}
	if(event=0x800B && WinActive("ahk_group ExplorerGroup")) ;EVENT_OBJECT_LOCATIONCHANGE
	{
		if(UseTabs)
			UpdatePosition(TabNum,TabWindow)
		if(HKShowSpaceAndSize && A_OsVersion = "WIN_7")
			UpdateInfoPosition()
		return
	}
	if(event = 0x000A && ShowResizeTooltip)
	{
		ResizeWindow := hwnd
		SetTimer, ResizeWindowTooltip, 50
	}
	else if(event = 0x000B && ShowResizeTooltip)
	{
		ResizeWindow := ""
		SetTimer, ResizeWindowTooltip, Off
		Tooltip
	}
	ListLines, On
}
ResizeWindowTooltip:
ResizeWindowTooltip()
return
ResizeWindowTooltip()
{	
	global ResizeWindow
	static w,h
	WinGetPos, , , wn, hn, ahk_id %ResizeWindow%
	if(w && h && (w != wn || h != hn))
		Tooltip %w%/%h%
	w := wn
	h := hn
}
ShellMessage( wParam,lParam, msg)
{
	WasCritical := A_IsCritical
	Critical
	ListLines, Off
	global ExplorerPath, HKShowSpaceAndSize, BlinkingWindows, wtmwParam, SuppressTabEvents, UseTabs, PreviousWindow, PreviousExplorerPath,WindowList,Accessor
	Trigger := EventSystem_CreateSubEvent("Trigger", "OnMessage")
	Trigger.Message := msg
	Trigger.wParam := wParam
	Trigger.lParam := lParam
	OnTrigger(Trigger)
	; outputdebug shellmessage %wparam%
	If	(wParam=1||wParam=2)
	{
		Trigger := wParam = 1 ? EventSystem_CreateSubEvent("Trigger","WindowCreated") : EventSystem_CreateSubEvent("Trigger","WindowClosed")
		class:=WinGetClass("ahk_Id " lParam)
		; outputdebug(Trigger.Type " triggered! class:" class " hwnd: " lParam)
		Trigger.Window := lParam
		OnTrigger(Trigger)
	}
	; Execute a command based on wParam and lParam 
	
	;Code for "catching" minimize events. Does not work properly when minimize animation is enabled.
	;A CBT hook would be required for that, but it injects itsself into every process and can cause a huge system fuckup.
	;Some minimize events could be catched, like click on min button, but not sure if it's worth it
	/*
	if(wParam=5)
	{		
		outputdebug getminrect %lParam%
		hwnd := NumGet(lParam+0, 0, "UInt")
		;Disable Minimize/Restore animation
		RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		outputdebug animate is currently set to %animate%
		VarSetCapacity(struct, 8, 0)	
		NumPut(8, struct, 0, "UInt")
		NumPut(0, struct, 4, "Int")
		DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		WinActivate ahk_id %hwnd%
		;Possibly activate it again
		if(Animate=1)
		{
			NumPut(1, struct, 4, "UInt")
			DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		}
		outputdebug %hwnd%
		
	}
	*/
	
	;Blinking windows detection, add new blinking windows
	if(wParam=32774)
	{
		class:=WinGetClass("ahk_id " lParam)
		; outputdebug blinking window %class%
		if(BlinkingWindows.indexOf(lParam)=0)
		{			
			BlinkingWindows.Append(lParam)
			ct:=BlinkingWindows.len()
			; outputdebug add window, count is now %ct%
		}
	}
	
	;Window Activation
	if(wParam=4||wParam=32772) ;HSHELL_WINDOWACTIVATED||HSHELL_RUDEAPPACTIVATED
	{
		Trigger := Object("base", TriggerBase)
		Trigger.Type := "WindowActivated"
		OnTrigger(Trigger)
		;Blinking windows detection, remove activated windows
		if(x:=BlinkingWindows.indexOf(lParam))
			BlinkingWindows.Delete(x)
		DecToHex(lParam)
		class:=WinGetClass("ahk_id " lParam)
		if(Accessor.GUINum && WinGetTitle("A") != Accessor.WindowTitle)
			AccessorClose()
		;If we change from another program to explorer/desktop/dialog
		if(WinActive("ahk_group ExplorerGroup")||WinActive("ahk_group DesktopGroup")||IsDialog())
		{
			if(!WinActive("ahk_group DesktopGroup")) ;By doing this, recall explorer path works also when double clicking desktop to launch explorer
				ExplorerPath:=GetCurrentFolder()
				
			;Paste text/image as file file creation
			CreateFile()
		}
		if(WinActive("ahk_group ExplorerGroup"))
		{
			if(UseTabs)
			{
				if(WinExist("ahk_id " PreviousWindow " ahk_group ExplorerGroup"))
					ExplorerDeactivated(PreviousWindow)
				ExplorerActivated(lParam)
			}
			RegisterSelectionChangedEvents()
			;Explorer info stuff
			UpdateInfos(1)
			if(A_OSVersion="WIN_7" && HKShowSpaceAndSize)
				SetTimer, UpdateInfos, 100
		}
		Else if(UseTabs)
			ExplorerDeactivated(lParam)
		
		WindowList := Object()
		WinGet, hwnds, list,,, Program Manager
		Loop, %hwnds%
		{
			hwnd := hwnds%A_Index%
			WinGetClass, class, ahk_id %hwnd%
			WinGetTitle, title, ahk_id %hwnd%
			WindowList[hwnd] := Object("class",class,"title",title)
		}
	}
	;Redraw is fired on Explorer path change
	else if(wParam=6)
	{
		;Detect changed path		
		if(WinActive("ahk_group ExplorerGroup")||IsDialog())
		{
			newpath:=GetCurrentFolder()
			if(newpath && newpath!=ExplorerPath)
			{
				outputdebug Explorer path changed from %ExplorerPath% to %newpath%
				ExplorerPathChanged(ExplorerPath, newpath)
				PreviousExplorerPath := ExplorerPath
				ExplorerPath := newpath
				Trigger := EventSystem_CreateSubEvent("Trigger","ExplorerPathChanged")
				OnTrigger(Trigger)
				if(UseTabs && !SuppressTabEvents && hwnd:=WinActive("ahk_group ExplorerGroup"))
					UpdateTabs()
			}
		}
	}
	ListLines, On
	if(!WasCritical)
		Critical, Off
}
/*
UpdatePosition:
UpdatePosition()
return
*/
WM_LBUTTONUP(wParam,lParam,msg,hWnd){
	SetTimer, TooltipClose, -20
} 

WM_NOTIFY(wParam, lParam, msg, hWnd){ 
	WasCritical := A_IsCritical
	Critical
	ToolTip("",lParam,"") 
	if(!WasCritical)
		Critical, Off
} 
ToolTip: 
link:=ErrorLevel 
SetTimer, TooltipClose, off
ToolTip()
If(TooltipShowSettings && Link) { 
	ShowSettings()
	TooltipShowSettings:=false
}
Return 

ToolTipClose: 
Tooltip()
return