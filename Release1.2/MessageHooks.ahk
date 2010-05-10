HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime ){ 
	global HKShowSpaceAndSize,HKAutoCheck,TabNum,TabWindow,TabContainerList
	
	;On dialog popup, check if its an explorer confirmation dialog
	if(event=0x00008002) ;EVENT_OBJECT_SHOW
	{	
		if(HKAutoCheck)
			FixExplorerConfirmationDialogs()
	}
	
	if idObject or idChild
		return
	WinGet, style, Style, ahk_id %hwnd%
	if (style & 0x40000000)					;RETURN if hwnd is child window, for some reason idChild may be 0 for some children ?!?! ( I hate ms )
		return

	;timer while explorer is moved for info gui update
	if(false && A_OSVersion="WIN_7" && HKShowSpaceAndSize && WinActive("ahk_group ExplorerGroup"))
	{
		if(event = 10) 
			settimer,MoveExplorer,10    
	  else if (event=11)
			settimer,MoveExplorer, off		 
	} 	   	
	
	if(event=0x8001) ;EVENT_OBJECT_DESTROY
	{
		DecToHex(hwnd)
		if(TabContainerList.ContainsHWND(hwnd))		
		{
			outputdebug tab closed
			ExplorerDestroyed(hwnd)
		}
	}
	if(event=0x800B && WinActive("ahk_group ExplorerGroup"))
	{
		UpdatePosition(TabNum,TabWindow)
		UpdateInfoPosition()
	}
}

ShellMessage( wParam,lParam, msg) 
{
	Critical
	global Vista7, ExplorerPath,hwnd1,HKShowSpaceAndSize,BlinkingWindows,wtmwParam,TabContainerList, SuppressTabEvents
	
	;Traymin
	If	msg=1028
	{
		If	wParam=1028
			Return
		Else If lParam=0x205 ; RButton 
		{ 
			wtmwParam := wParam
			Menu, wtmMenu, Show 
		}
		Else If	(lParam=0x201||lParam=0x207)
			WinTraymin(wParam,3)
		Return 0
	}
	Else If	(wParam=1||wParam=2)
	{
		WinTraymin(lParam,wParam)
		return 0
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
		;Blinking windows detection, remove activated windows
		if(x:=BlinkingWindows.indexOf(lParam))
			BlinkingWindows.Delete(x)
		DecToHex(lParam)
		class:=WinGetClass("ahk_id " lParam)
		outputdebug activate %class% %lParam%
		;If we change from another program to explorer/desktop/dialog
		if(WinActive("ahk_group ExplorerGroup")||WinActive("ahk_group DesktopGroup")||IsDialog())
		{
			;Backup current clipboard contents and write "simple" text/image data in clipboard while explorer is active
			ExplorerPath:=GetCurrentFolder()
			;Paste text/image as file file creation
			CreateFile()
		}
		if(WinActive("ahk_group ExplorerGroup"))
		{
			ExplorerActivated(lParam)
			;Explorer info stuff
			if(A_OSVersion="WIN_7" && HKShowSpaceAndSize)
			{
				SetTimer, UpdateInfos, 100
			}
		}
		Else
		{
			;SetTimer, ExplorerDeactivated, -10
			ExplorerDeactivated(lParam)
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
			if(!SuppressTabEvents && hwnd:=WinActive("ahk_group ExplorerGroup"))
			{
				UpdateTabs()
				/*
				SplitPath,newpath, name
				if(!name)
					name:=newpath
				GuiControl, %TabNum%:,Tab%hwnd%,%name%
				*/
			}
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