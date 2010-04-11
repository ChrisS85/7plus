HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime ){ 
	global HKShowSpaceAndSize,HKAutoCheck	
	;timer while explorer is moved for info gui update
	if(A_OSVersion="WIN_7" && HKShowSpaceAndSize && WinActive("ahk_group ExplorerGroup"))
	{
		if(event = 10) 
			settimer,MoveExplorer,10    
	  else if (event=11)
			settimer,MoveExplorer, off		 
	} 	   
	
	;On dialog popup, check if its an explorer confirmation dialog
	if(event=0x00008002) ;EVENT_OBJECT_SHOW
	{	
		if(HKAutoCheck)
			FixExplorerConfirmationDialogs()
	}
}

ShellMessage( wParam,lParam ) 
{
	global Vista7, ExplorerPath,hwnd1,HKShowSpaceAndSize,BlinkingWindows
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
		outputdebug blinking window %class%
		if(BlinkingWindows.indexOf(lParam)=0)
		{			
			BlinkingWindows.Append(lParam)
			ct:=BlinkingWindows.len()
			outputdebug add window, count is now %ct%
		}
	}
	
	;Window Activation
	if(wParam=4||wParam=32772) ;HSHELL_WINDOWACTIVATED||HSHELL_RUDEAPPACTIVATED
	{
		;Explorer info stuff
		if(A_OSVersion="WIN_7" && HKShowSpaceAndSize)
		{
			SetTimer, UpdateInfos, 100
		}
		;Blinking windows detection, remove activated windows
		if(x:=BlinkingWindows.indexOf(lParam))
			BlinkingWindows.Delete(x)
		outputdebug activate
		;If we change from another program to explorer/desktop/dialog
		if(WinActive("ahk_group ExplorerGroup")||WinActive("ahk_group DesktopGroup")||IsDialog())
    {
    	;Backup current clipboard contents and write "simple" text/image data in clipboard while explorer is active
			ExplorerPath:=GetCurrentFolder()
			;Paste text/image as file file creation
			CreateFile()
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
    		ExplorerPath:=newpath
    	}
    }
  }
}

WM_LBUTTONUP(wParam,lParam,msg,hWnd){
	SetTimer, TooltipClose, -20
} 

WM_NOTIFY(wParam, lParam, msg, hWnd){ 
	Critical
  ToolTip("",lParam,"") 
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

API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) { 
   DllCall("CoInitialize", "uint", 0) 
   return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "uint", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags) 
}
