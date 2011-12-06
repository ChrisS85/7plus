IsMouseOverDesktop()
{
	MouseGetPos, , ,Window , UnderMouse
	WinGetClass, winclass , ahk_id %Window%
	if (winclass="WorkerW"||winclass="Progman")
		return true
	return false
}

InFileList()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
	  focussed:=XPGetFocussed()

	if(WinActive("ahk_group ExplorerGroup"))
	{		
		if((A_OSVersion="WIN_7" && focussed="DirectUIHWND3") || (A_OSVersion!="WIN_7" && focussed="SysListView321"))
			return true
	}
	else if((x:=IsDialog())=1)
	{
		if((A_OSVersion="WIN_7" && focussed="DirectUIHWND2") || (A_OSVersion!="WIN_7" && focussed="SysListView321"))
			return true
	}
	else if(x=2)
	{
		if(focussed="SysListView321")
			return true
	}
	return false
}

IsMouseOverFileList()
{
	CoordMode,Mouse,Relative
	MouseGetPos, MouseX, MouseY,Window , UnderMouse
	WinGetClass, winclass , ahk_id %Window%
	if(A_OSVersion="WIN_7" && (winclass="CabinetWClass" || winclass="ExploreWClass")) ;Win7 Explorer
	{		
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND3, A
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height))
			return true		
	}	
	else if((z:=IsDialog(window))=1) ;New dialogs
	{
		outputdebug new dialog
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND2, A
		outputdebug x %MouseX% y %mousey% x%cx% y%cy% w%width% h%height%
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height)) ;Checking for area because rename might be in process and mouse might be over edit control
			return true
	}
	else if(winclass="CabinetWClass" || winclass="ExploreWClass" || z=2) ;Old dialogs or Vista/XP
	{
		ControlGetPos , cX, cY, Width, Height, SysListView321, A
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height) && UnderMouse = "SysListView321") ;Additional check needed for XP because of header
			return true			
	}
	return false
}

InTree()
{
	if(WinActive("ahk_group ExplorerGroup")||IsDialog()=1) ;Explorer or new dialog
	{
		if(A_OSVersion="WIN_7")
			ControlGetFocus focussed, A
		else
		  focussed:=XPGetFocussed()
		if(focussed="SysTreeView321")
			return true
	}
	return false
}
IsRenaming()
{		
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
		focussed:=XPGetFocussed()
	if(WinActive("ahk_group ExplorerGroup")) ;Explorer
	{
		if(strStartsWith(focussed,"Edit"))
		{
			if(A_OSVersion="WIN_7")
				ControlGetPos , X, Y, Width, Height, DirectUIHWND3, A
			else
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			if(IsInArea(X1,Y1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1, X, Y, Width, Height)&&IsInArea(X1,Y1+Height1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				return true
		}
	}
	else if (WinActive("ahk_group DesktopGroup")) ;Desktop
	{
		if(focussed="Edit1")
			return true
	}
	else if((x:=IsDialog())) ;FileDialogs
	{		
		if(strStartsWith(focussed,"Edit1"))
		{
			;figure out if the the edit control is inside the DirectUIHWND2 or SysListView321
			if(x=1 && A_OSVersion="WIN_7") ;New Dialogs
				ControlGetPos , X, Y, Width, Height, DirectUIHWND2, A
			else ;Old Dialogs
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			if(IsInArea(X1,Y1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1, X, Y, Width, Height)&&IsInArea(X1,Y1+Height1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				return true
		}
	}
	return false
}
IsInAddressBar()
{		
  if(A_OSVersion="WIN_7")
    ControlGetFocus focussed, A
	else
		focussed:=XPGetFocussed()
	if(WinActive("ahk_group ExplorerGroup")) ;Explorer
	{		
		if(focussed = "Edit1" && !IsRenaming()) ;Renaming Control can be Edit1 when rename is made before addressbar is focussed
			return true
	}
	else if(IsDialog() = 1) ;New Dialogs
	{
		if(focussed = "Edit2") ;Seems to be Edit2 all the time...
			return true
	}
	return false
}
SetFocusToFileView()
{
	if(WinActive("ahk_group ExplorerGroup"))
	{
		if(A_OSVersion="WIN_7")
			ControlFocus DirectUIHWND3, A
		else ;XP, Vista
		 	ControlFocus SysListView321, A
	}
	else if((x:=IsDialog())=1) ;New Dialogs
	{
		if(A_OSVersion="WIN_7")
			ControlFocus DirectUIHWND2, A
		else
			ControlFocus SysListView321, A		
	}
	else if(x=2) ;Old Dialogs
	{
		ControlFocus SysListView321, A
	}
	return
}

FixExplorerConfirmationDialogs()
{
	global ExplorerConfirmationDialogTitle, ExplorerConfirmationDialogButton
	;Check if titles were acquired and if this is a proper dialog
	if(ExplorerConfirmationDialogTitle.MaxIndex() > 0 && z:=IsExplorerConfirmationDialog())
	{
		if(z=2 || z=6)
			Control, Check , , Button4, A
		else if (z=5)
			Control, Check , , Button5, A
		else
		{
			;just check both, lazyness and low number seem to warrant it :D
			Control, Check , , % ExplorerConfirmationDialogButton[1], A
			Control, Check , , % ExplorerConfirmationDialogButton[2], A
		}
	}
}

IsExplorerConfirmationDialog()
{
	global
	if(WinActive("ahk_class #32770"))
	{
		WinGetTitle, title, A
		loop % ExplorerConfirmationDialogTitle.MaxIndex()
			if(strStartsWith(title, ExplorerConfirmationDialogTitle[A_INDEX]))
				return A_Index
	}
	return 0
}

AcquireExplorerConfirmationDialogStrings()
{
	global
	ExplorerConfirmationDialogTitle := Array(TranslateMUI(Shell32MUIPath,16705), TranslateMUI(Shell32MUIPath,16877), TranslateMUI(Shell32MUIPath,16875), TranslateMUI(Shell32MUIPath,16875), TranslateMUI(Shell32MUIPath,16706), TranslateMUI(Shell32MUIPath,16864))
	ExplorerConfirmationDialogButton:=Array(strStripRight(TranslateMUI(Shell32MUIPath,16928),"%"), strStripRight(TranslateMUI(Shell32MUIPath,17039),"%"), TranslateMUI(Shell32MUIPath,16663))
}

;Mouse "gestures" (hold left/right and click right/left)
#if Settings.Explorer.MouseGestures && GetKeyState("RButton") && (WinActive("ahk_group ExplorerGroup")||IsDialog()) && IsMouseOverFileList()
LButton::
	SuppressRButtonUp:=true
	Shell_GoBack()
	return
#if

#if Settings.Explorer.MouseGestures && SuppressRButtonUp
~RButton UP::
	SuppressRButtonUp:=false
	Send, {Esc}
	Return
#if

#if Settings.Explorer.MouseGestures && GetKeyState("LButton","P") && (WinActive("ahk_group ExplorerGroup")||IsDialog()) && IsMouseOverFileList()
RButton::
	Shell_GoForward()
	SuppressRButtonUp:=true
	Return
#if

;Enter:Execute focussed file
#if Settings.Explorer.ImproveEnter && WinActive("ahk_group ExplorerGroup") && InFileList() && !IsRenaming() && !IsContextMenuActive()
Enter::
Return::
	files:=GetSelectedFiles()
	focussed:=GetFocussedFile()
	if(!files&&focussed)
		Send {Space}{Enter}
	else
		Send {Enter}
	return
#if

;Function(s) to align explorer windows side by side and to launch explorer with last used directory
#if (Settings.Explorer.RememberPath && Settings.Explorer.CurrentPath != "") || Settings.Explorer.AlignNewExplorer && WinActive("ahk_group ExplorerGroup")
#e::RunExplorer()
#if
RunExplorer()
{
	active:=WinActive("ahk_group ExplorerGroup")
	if(active && Settings.Explorer.AlignNewExplorer)
	{
		WinRestore ahk_id %active%
		if(A_OSVersion="WIN_7")
		{
			WinGetPos, x,y,w,h,ahk_id %active%
			x++
			WinMove, ahk_id %active%,, %x%, %y%
			Send #{Left}
		}
		Else
		{
			GetActiveMonitorWorkspaceArea(x,y,w,h,active)
			w := Round(w/2)
			WinMove, ahk_id %active%,, %x%,%y%,%w%,%h%
		}
	}
	if(Settings.Explorer.RememberPath && Settings.Explorer.CurrentPath)
		Run, % "Explorer """ Settings.Explorer.CurrentPath """"
	Else
		run, % "Explorer C:"
	if(Settings.Explorer.AlignNewExplorer && active)
	{
		WinWaitNotActive ahk_id %active%
		Timeout := 10000
		Start := A_TickCount
		Loop ;Make sure new window is really active
		{ 
			Sleep 10 
			active2 := WinActive("ahk_group ExplorerGroup")
			if((active2 && active2 != active) || A_TickCount - Start > Timeout)
				   Break 
		}
		Start := A_TickCount
		Loop ;Wait until new window is visible
		{
			Sleep 10
			WinGet,visible,style, ahk_id %active2%
			if(visible & 0x10000000 || A_TickCount - Start > Timeout)
				break
		}
		if(A_OSVersion="WIN_7")
			Send #{Right}
		else
		{
			x += w
			WinMove, ahk_id %active2%,, %x%,%y%,%w%,%h%
		}
	}
	Return
}

#MaxThreadsPerHotkey 2
#if (Vista7 && IsWindowUnderCursor("WorkerW")) || (!Vista7 && IsWindowUnderCursor("ProgMan"))
~LButton::
CurrentDesktopFiles:=GetSelectedFiles()
; outputdebug current: "%CurrentDesktopFiles%" previous: %PreviousDesktopFiles%
; outputdebug % "is doubleclick: """ IsDoubleClick() """ no files: """ (CurrentDesktopFiles = "") """"
; outputdebug(A_TimeSincePriorHotkey " < " DllCall("GetDoubleClickTime") " && " A_ThisHotkey "=" A_PriorHotkey)
if(IsDoubleClick() && CurrentDesktopFiles = "")
{
	Trigger := new CDoubleClickDesktopTrigger()
	EventSystem.OnTrigger(Trigger)
}
Return
#if

#MaxThreadsPerHotkey 1
;Double click upwards is buggy in filedialogs, so only explorer for now until someone comes up with non-intrusive getpath, getselectedfiles functionsunrel
#if !IsDialog() && IsMouseOverFileList() && GetKeyState("RButton")!=1
;LButton on empty space in explorer -> go upwards
~LButton::		
CoordMode,Mouse,Relative
;wait until button is released again
KeyWait, LButton
;Time for a doubleclick in windows
WaitTime:=DllCall("GetDoubleClickTime")/1000
MouseGetPos, Click1X, Click1Y
;This check is needed so that we don't send CTRL+C in a textfield control, which would disrupt the text entering process
;Make sure only filelist is focussed
if(!IsRenaming() && InFileList())
{
	path:=GetCurrentFolder()
	files:=GetSelectedFiles()
	;if more time than a double click time has passed, consider this a new series of double clicks
	if(A_TickCount-time1>WaitTime*1000)
	{
		time1:=A_TickCount
		path1:=path
	}
	else
	{			
		;if less time has passed, the previous double click was cancelled for some reason and we need to check its dir too to see directory changes
		time1:=A_TickCount
		if(path!=path1)
		{
			time1:=0
			return
		}					
	}
	;this check is required so that it's possible to count any double click and not every second. If at this place a file is selected, 
	;it would swallow the second click otherwise and won't be able to count it in a double clickwait for anotherat this plac
	if (files!="")
		return
	;wait for second click
	KeyWait, LButton, D T%WaitTime% 
	If(errorlevel=0)
	{
		MouseGetPos, Click2X, Click2Y
		if(abs(Click1X-Click2X)**2+abs(Click1Y-Click2Y)**2>16) ;Max 4 pixels between clicks
			return
	
		path1:=GetCurrentFolder()
		if(path = path1) 
		{	
			if(InFileList()&&IsMouseOverFileList()) 
			{			
				;check if no files selected after second click either
				files:=GetSelectedFiles()
				if (!files)
				{
					Trigger := new CExplorerDoubleClickSpaceTrigger()
					EventSystem.OnTrigger(Trigger)
					/*
					if (Vista7 && !strEndsWith(path1,".search-ms"))
						Send !{Up}
					else
						Send {Backspace}
					*/
					time1:=0
				}
			}	
		}
	}
	
}	
Return
#if

#if IsMouseOverTaskList() ;Can't add the conditions below here right now, because IsDoubleClick seems to fail when called in the #if condition
LButton::
outputdebug lbutton
if(IsDoubleClick() && IsMouseOverFreeTaskListSpace())
{
	outputdebug doubleclicktaskbar
	Trigger := new CDoubleClickTaskbarTrigger()
	EventSystem.OnTrigger(Trigger)
}
else
{
	Click Left Down
	while(GetKeyState("LButton", "P"))
		Sleep 50
	Click Left Up
}
return
#if
/*
#if !IsFullScreen()
^MButton::
+MButton::
MButton::
key:=GetKeyState("CTRL") ? "^" : ""
key.=GetKeyState("ALT") ? "!" : ""
key.=GetKeyState("SHIFT") ? "+" : ""
key.=(GetKeyState("RWIN") || GetKeyState("LWIN")) ? "#" : ""
Handled:=TaskbuttonClose()
if(!Handled)
	Handled:=ToggleWallpaper()
if(!Handled)
	Handled:=OpenInNewFolder()
if (!Handled && Handled:=IsMouseOverTabButton())
	MouseCloseTab()
	
; This is not perfect, as hotkeys defined further down in the events list are not considered for catching keys. 
; A better solution might be to evaluate all matching hotkeys conditions and check if any of it want to hide the key from the system
if(!Handled && IsObject(Trigger := HotkeyShouldFire(A_ThisHotkey)))
{
	HotkeyTrigger(A_ThisHotkey)
	Handled := !InStr(Trigger.Key, "~")
}
if(!Handled)
{
	Send %key%{MButton down}
	KeyWait, MButton
	Send {MButton up}
}
return 
#if
*/
;Middle click on desktop -> Change wallpaper

;Scroll tree list with mouse wheel
#if (Settings.Explorer.ScrollTreeUnderMouse && ((IsWindowUnderCursor("#32770") && IsDialog()) || IsWindowUnderCursor("CabinetWClass")||IsWindowUnderCursor("ExploreWClass")) && !IsRenaming())||(IsObject(Accessor) && Accessor.GUINum && WinActive(Accessor.WindowTitle))
WheelUp::
WheelDown::
Wheel()
return
Wheel()
{
	WasCritical := A_IsCritical
	Critical 
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY 
	DllCall("SendMessage","PTR",DllCall( "WindowFromPoint", "INT64", MouseX | (MouseY << 32), "Ptr"),"UInt", 0x20A, "PTR",(120 * (A_ThisHotkey = "WheelUp" ? 1 : -1)) << 16,"PTR", ( MouseY << 16 )|MouseX)
	if(!WasCritical)
		Critical, Off
	return
}
#if

InitExplorerWindows()
{
	global ExplorerWindows, Vista7, shell32MUIpath
	ExplorerWindows := Array()
	RegisterExplorerWindows()
	TabContainerList := Array()
	if(Vista7)
		TabContainerList.Font := "Segoe UI"
	Else
		TabContainerList.Font := "Tahoma"
	TabContainerList.FontSize := 12
	TabContainerList.hPadding := 4
	TabContainerList.vPadding := 2
	TabContainerList.height := 20
	TabContainerList.TabWidth := 100
	TabContainerList.InActiveHeightDifference := 2
	TabContainerList.MinWidth := 40
	ExplorerWindows.TabContainerList := TabContainerList
	if(A_OSVersion = "WIN_7")
	{
		ExplorerWindows.InfoGUI_FreeText := TranslateMUI(shell32MUIpath,12336) ;Aquire a translated version of "free"
		ExplorerWindows.InfoGUI_FreeText:=SubStr(ExplorerWindows.InfoGUI_FreeText,InStr(ExplorerWindows.InfoGUI_FreeText," ",0,0)+1)
	}
}
;Find all explorer windows, register them in ExplorerWindows array and set up events and info gui
RegisterExplorerWindows()
{
	global ExplorerWindows
	; for item in ComObjCreate("Shell.Application").Windows
		; ComObjConnect(item, "Explorer")
	; ShellWindows := ComObjCreate("Shell.Application").Windows
	; ComObjConnect(ShellWindows, "Explorer")
	WinGet, hWndList, List, ahk_group ExplorerGroup
	Loop % hwndList
	{
		if(!ExplorerWindows.FindKeyWithValue("hwnd", hWndList%A_Index%+0))
			ExplorerWindows.Insert(new CExplorerWindow(hwndList%A_Index%+0))
	}
	
	SetTimer, WaitForClose, 1000
}

;Registers all explorer windows for SelectionChanged events. Called when explorer changes path
RegisterSelectionChangedEvents()
{
	global ExplorerWindows
	Loop % ExplorerWindows.MaxIndex()
		ExplorerWindows[A_Index].RegisterSelectionChangedEvent()
}
/*
;Unregister an explorer window for SelectionChanged events
UnregisterSelectionChangedEvents(hwnd)
{
	global RegisteredSelectionChangedWindows
	i := RegisteredSelectionChangedWindows.FindKeyWithValue("hwnd", hwnd)
	if(i > 0)
		RegisteredSelectionChangedWindows.Delete(i)
}
*/
RestoreExplorerSelection()
{
	global ExplorerWindows
	hwnd := WinActive("ahk_group ExplorerGroup")+0
	if(hwnd)
	{
		ExplorerWindow := ExplorerWindows.GetItemWithValue("hWnd",hwnd)
		if(!IsObject(ExplorerWindow.Selection.History))
			outputdebug % "Explorer window " hwnd " is not registered!"
		if(ExplorerWindow.Selection.History.MaxIndex() > 1)
		{		
			outputdebug % "Explorer window " hwnd "restore selection"
			Selection := ExplorerWindow.Selection.History[ExplorerWindow.Selection.History.MaxIndex() - 1]
			; A SelectionChanged event will be fired 2 times that needs to be suppressed? 
			;Why is it fired 2 times instead of one time for each file? -> Probably because of timing
			ExplorerWindow.Selection.IgnoreNextEvent := 2 
			outputdebug % "Explorer window " hwnd " expecting " ExplorerWindow.Selection.IgnoreNextEvent " selection events."
			SelectFiles(Selection,1,0,1,1,hwnd)
			ExplorerWindow.Selection.History.Delete(ExplorerWindow.Selection.History.MaxIndex())
		}
		else
			outputdebug % "Explorer window " hwnd " is registered but has no history"
	}
}

;===============;
;Explorer related Events;
;===============;

;Called when an explorer window is activated.
ExplorerActivated(hwnd)
{
	global TabNum, TabWindow, SuppressTabEvents, ExplorerWindows
	if(!ExplorerWindows.FindKeyWithValue("hwnd",hwnd))
		ExplorerWindows.Insert(new CExplorerWindow(hwnd))
	RegisterSelectionChangedEvents() ;Is this needed? only as backup probably
	; if(SuppressTabEvents)
		; return
	; if(TabContainerList.active=hwnd) ;If active hwnd is set to this window already, activation shall be handled elsewhere
		; return
	; DecToHex(hwnd)
	; if(TabContainer:=TabContainerList.ContainsHWND(hwnd))
	; {
		; TabContainerOld:=TabContainerList.ContainsHWND(TabContainerList.active)
		; ; outputdebug set active
		; OldTab:=TabContainer.active
		; TabContainerList.active:=hwnd
		; TabContainer.active:=hwnd
		
		; if(TabContainer!=TabContainerOld)
			; UpdateTabs()
		; UpdatePosition(TabNum, TabWindow)
		
		; ;SetTimer, UpdatePosition, 100
	; }
}

;This routine polls the existance of explorer windows since they disappear rather randomly.
WaitForClose:
CheckForClosedExplorerWindows()
return
CheckForClosedExplorerWindows()
{
	DetectHiddenWindows, On
	for index, ExplorerWindow in ExplorerWindows
	{
		if(!WinExist("ahk_id " ExplorerWindow.hwnd))
		{
			ExplorerDestroyed(ExplorerWindow.hwnd)
			Loop % ToolWindows.MaxIndex() ;This code from Messagehooks.ahk is added here again since explorer close events don't work properly and need to be handled this way
			{
				if(ToolWindows[A_Index].hParent = ExplorerWindow.hwnd && ToolWindows[A_Index].AutoClose)
				{
					WinClose % "ahk_id " ToolWindows[A_Index].hGui
					ToolWindows.Remove(A_Index)
					break
				}
			}
			SlideWindows.WindowClosed(ExplorerWindow.hwnd)
			break
		}
	}
	return
}

;Called when an explorer window gets deactivated.
ExplorerDeactivated(hwnd)
{
	global TabContainerList, TabNum, TabWindow,SuppressTabEvents
	; hwnd:=WinExist("A")
	; if(hwnd=TabWindow)
		; return
	; if(SuppressTabEvents)
		; return
	; TabContainerList.active:=0
	; UpdatePosition(TabNum, TabWindow)
	; ;SetTimer, UpdatePosition, Off
}
;TODO: Continue here, implement delete method and check draw timer deactivation
;Called when an explorer window gets destroyed.
ExplorerDestroyed(hwnd)
{
	global TabContainerList, ExplorerWindows
	outputdebug explorer destroyed
	TabContainer:=ExplorerWindows.GetItemWithValue("hwnd", hwnd+0).TabContainer
	if(index := ExplorerWindows.FindKeyWithValue("hwnd", hwnd))
		ExplorerWindows.Remove(index) ;This will destroy the info gui as well
	if(ExplorerWindows.TabContainerList.TabCloseInProgress) ;If this is set, then this event was caused by a tab closing action and must not trigger further tab close functions
	{
		ExplorerWindows.TabContainerList.TabCloseInProgress := false
		return
	}
	if(!TabContainer)
		return
	TabContainer.TabClosed(hwnd)
	if(Settings.Explorer.Tabs.TabWindowClose = 1)
		TabContainer.CloseAllTabs()
	return
}
ExplorerMoved(hwnd)
{
	global ExplorerWindows
	if(!IsObject(ExplorerWindows))
		return
	ExplorerWindow := ExplorerWindows.GetItemWithValue("hwnd", hwnd)
	if(IsObject(ExplorerWindow))
	{
		if(Settings.Explorer.Tabs.UseTabs && IsObject(ExplorerWindow.TabContainer) && IsObject(ExplorerWindows.TabContainerList) &&  !ExplorerWindows.TabContainerList.TabActivationInProgress)
			ExplorerWindow.TabContainer.UpdatePosition()
		if(Settings.Explorer.AdvancedStatusBarInfo && A_OsVersion = "WIN_7")
			ExplorerWindow.InfoGUI.UpdateInfoPosition()
	}
}
;Called when active explorer changes its path.
ExplorerPathChanged(ExplorerWindow)
{
	global vista7
	if(!IsObject(ExplorerWindow))
		return
	OldPath := ExplorerWindow.Path
	ExplorerWindow.RegisterSelectionChangedEvent() ;This will also refresh the path in ExplorerWindow
	Path := ExplorerWindow.Path
	if(OldPath = Path)
		return
	ExplorerWindow.DisplayName := GetCurrentFolder(ExplorerWindow.hwnd, 1)
	if(Settings.Explorer.Tabs.UseTabs && IsObject(ExplorerWindow.TabContainer))
		ExplorerWindow.TabContainer.UpdateTabs()
	;focus first file
	if(Settings.Explorer.AutoSelectFirstFile)
	{
		SplitPath, Path, name, dir,,,drive
		x:=GetSelectedFiles()
		if(!x && dir && (!vista7||SubStr(Path, 1 ,40)!="::{26EE0668-A00A-44D7-9371-BEB064C98683}"))
		{
			if(A_OSVersion="WIN_7")
			{
				ControlGetFocus focussed, A
				ControlFocus DirectUIHWND3, A
				ControlSend DirectUIHWND3, {Home}{Space},A
			}
			else
			{
				focussed:=XPGetFocussed()
				ControlFocus SysListView321, A
				ControlSend SysListView321, {Home},A
			}
			Sleep 50 ;Better wait some time
			ControlFocus %focussed%, A
		}
	}
}
;Called when selection changes in an explorer window. If the shell is restarted, old windows won't be recognized anymore.
ExplorerSelectionChanged(ExplorerCOMObject)
{
	global ExplorerWindows
	; Critical ;This apparently makes it stop working and blocks the explorer window somehow
	Critical, Off
	outputdebug explorer selection changed
	Loop % ExplorerWindows.MaxIndex()
	{
		if(ExplorerWindows[A_Index].Selection.COMObject = ExplorerCOMObject)
		{
			index := A_Index
			break
		}
	}
	if(!index)
		return
	outputdebug com object found
	if(ExplorerWindows[index].Selection.IgnoreNextEvent > 0)
	{
		ExplorerWindows[index].Selection.IgnoreNextEvent := ExplorerWindows[index].Selection.IgnoreNextEvent - 1
		outputdebug % "expecting " ExplorerWindows[index].Selection.IgnoreNextEvent " more events."
		return
	}
	outputdebug nothing to ignore
	ExplorerWindows[index].Selection.History.Insert(ToArray(GetSelectedFiles(0, ExplorerWindows[index].hwnd)))
	if(ExplorerWindows[index].Selection.History.MaxIndex() > 10)
		ExplorerWindows[index].Selection.History.Delete(1)
	if(A_OSVersion = "WIN_7")
		ExplorerWindows[index].InfoGUI.UpdateInfos(ExplorerWindows[index]) ;Update the info GUI to reflect selection change
	outputdebug explorer selection change end
	; Critical, Off
}
class InfoGUI
{
	__New(hParent)
	{
		if(A_OSVersion != "WIN_7")
			return 0
		GuiNum := GetFreeGuiNum(1, this.__Class)
		this.GuiNum := GuiNum
		Gui, %GuiNum%: font, s9, Segoe UI 
		Gui, %GuiNum%: Add, Text, x60 y0 w70 h12, %A_Space%
		Gui, %GuiNum%: Add, Text, x0 y0 w60 h12, %A_Space%
		Gui, %GuiNum%: -Caption  +LastFound +ToolWindow
		Gui, %GuiNum%: Color, FFFFFF
		Gui, %GuiNum%: +LastFound
		WinSet, TransColor, FFFFFF
		AttachToolWindow(hParent, GuiNum, true)
		this.hWnd := WinExist() +0
		this.hParent := hParent+0
	}
	__Delete()
	{
		Gui % this.GuiNum ":Destroy"
	}
	UpdateInfos(ExplorerWindow)
	{
		global ExplorerWindows
		if(A_OSVersion != "WIN_7")
			return
		totalsize:=0
		realfiles:=false ;check if only folders are selected
		History :=ExplorerWindow.Selection.History[ExplorerWindow.Selection.History.MaxIndex()]
		Loop % History.MaxIndex()
		{
			FileGetSize, size, % ExplorerWindow.Path "\" History[A_Index]
			if(!realfiles)
				realfiles:=!InStr(FileExist(ExplorerWindow.Path "\" History[A_Index]), "D")
			totalsize+=size
		}
		DriveSpaceFree, free, % ExplorerWindow.Path
		free := FormatFileSize(free * 1048576)
		GuiControl % this.GUINum ":Text", Static1, % free " " ExplorerWindows.InfoGUI_FreeText
		if(realfiles)
		{
			totalsize := FormatFileSize(totalsize)
			GuiControl % this.GUINum ":Text", Static2, %totalsize%
		}
		else
			GuiControl % this.GUINum ":Text", Static2, %A_Space%
		this.UpdateInfoPosition()
	}
	UpdateInfoPosition()
	{
		ControlGet, visible, visible, , msctls_statusbar321, % "ahk_id " this.hParent ;Check if status bar is visible
		if(visible)
		{
			WinGetPos , X, Y, Width, Height, % "ahk_id " this.hParent
			ControlGetPos , , cY, , cHeight, msctls_statusbar321, % "ahk_id " this.hParent
			InfoX:=X+Width-370
			InfoY:=Round(Y+cY+cHeight/2-6) ; +Height-26
			outputdebug % "show " this.GUINum
			if(Width>540)
				Gui, % this.GuiNum ":Show", AutoSize NA x%InfoX% y%InfoY%
		}
		else
		{
			outputdebug % "hide " this.GUINum
			Gui, % this.GuiNum ": Hide"
		}
	}
}

;TODO: Figure out how to receive explorer close event and proper path change
Class CExplorerWindow
{	
    __New(hWnd, Path="")
    {
		global InfoGUI
		this.hWnd := hWnd
		this.Path := Path ? Path : GetCurrentFolder(hWnd)
		this.DisplayName := GetCurrentFolder(hWnd, 1)
		if(A_OSVersion = "WIN_7")
			this.InfoGUI := new InfoGUI(hWnd)
		this.Selection := Object()
		this.RegisterSelectionChangedEvent()
    }
	RegisterSelectionChangedEvent()
	{
		global ExplorerWindows
		for Item in ComObjCreate("Shell.Application").Windows
		{
			if(Item.hWnd != this.hWnd)
				continue
			if(!this.Selection.COMObject) ;New explorer window
			{
				doc:=Item.Document
				if(!doc)
					return 0
				ComObjConnect(doc, "Explorer")
				this.Selection.COMObject := doc
				this.Selection.History := Array(this.GetSelectedFiles(0))
			}
			else ;explorer window is already registered, lets see if its view changed
			{
				doc:=Item.Document
				if(!doc)
					continue			
				Path := doc.Folder.Self.path
				if(!Path)
					continue
				if(this.Path != Path) ;Compare by path since the COM wrapper objects are different
				{
					ComObjConnect(doc, "Explorer")
					this.Selection.COMObject := doc
					this.Selection.History := Array(this.GetSelectedFiles(0)) ;Recreate array to remove selection history from previous folder
					this.Path := Path
				}
			}
		}
	}
	GetSelectedFiles(FullName)
	{
		return ToArray(GetSelectedFiles(FullName, this.hWnd))
	}
}