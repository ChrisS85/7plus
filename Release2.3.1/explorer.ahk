XPGetFocussed()
{
  WinGet ctrlList, ControlList, A 
  ctrlHwnd:=GetFocusedControl()
  ; Built an array indexing the control names by their hwnd 
  Loop Parse, ctrlList, `n 
  {
    ControlGet hwnd, Hwnd, , %A_LoopField%, A 
    hwnd += 0   ; Convert from hexa to decimal 
    if(hwnd=ctrlHwnd)
      return A_LoopField
  } 
}

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
	global
	;Check if titles were acquired and if this is a proper dialog
	if(ExplorerConfirmationDialogTitle1 && z:=IsExplorerConfirmationDialog())
	{
		if(z=2 || z=6)
		{
			Control, Check , , Button4, A	
		}
		else if (z=5)
		{
			Control, Check , , Button5, A
		}
		else
		{
			;just check both, lazyness and low number seem to warrant it :D
			Control, Check , , %ExplorerConfirmationDialogButton1%, A	
			Control, Check , , %ExplorerConfirmationDialogButton2%, A
		}
	}
}

IsExplorerConfirmationDialog()
{
	global
	if(WinActive("ahk_class #32770"))
	{
		WinGetTitle, title, A
		loop 6
			if(strStartsWith(title,a:=ExplorerConfirmationDialogTitle%A_INDEX%))
			{
				x:=ExplorerConfirmationDialogTitle%A_INDEX%
				return A_Index
			}
	}
	return 0
}

AcquireExplorerConfirmationDialogStrings()
{
	global shell32MUIpath
	VarSetCapacity(buffer, 85*2)
	length:=DllCall("GetUserDefaultLocaleName","UIntP",buffer,"UInt",85)
	if(A_IsUnicode)
		locale := StrGet(buffer)
	shell32MUIpath:=A_WinDir "\winsxs\*_microsoft-windows-*resources*" locale "*" ;\x86_microsoft-windows-shell32.resources_31bf3856ad364e35_6.1.7600.16385_de-de_b08f46c44b512da0\shell32.dll.mui
	loop %shell32MUIpath%,2,0
	{
		if(FileExist(A_LoopFileFullPath "\shell32.dll.mui"))
		{
			shell32MUIpath:=A_LoopFileFullPath "\shell32.dll.mui"
			found:=true
			break
		}
	}
	if(found)
	{
		global ExplorerConfirmationDialogTitle1:=TranslateMUI(shell32MUIpath,16705)
		global ExplorerConfirmationDialogTitle2:=TranslateMUI(shell32MUIpath,16877)
		global ExplorerConfirmationDialogTitle3:=TranslateMUI(shell32MUIpath,16875)
		global ExplorerConfirmationDialogTitle4:=TranslateMUI(shell32MUIpath,16876)
		global ExplorerConfirmationDialogTitle5:=TranslateMUI(shell32MUIpath,16706)
		global ExplorerConfirmationDialogTitle6:=TranslateMUI(shell32MUIpath,16864)
		global ExplorerConfirmationDialogButton1:=strStripRight(TranslateMUI(shell32MUIpath,16928),"%")
		global ExplorerConfirmationDialogButton2:=strStripRight(TranslateMUI(shell32MUIpath,17039),"%")
		global ExplorerConfirmationDialogButton3:=TranslateMUI(shell32MUIpath,16663)
		return true
	}
	Outputdebug Failed to acquire translated Explorer dialog names
	return false
}

;Mouse "gestures" (hold left/right and click right/left)
#if HKMouseGestures && GetKeyState("RButton") && (WinActive("ahk_group ExplorerGroup")||IsDialog()) && IsMouseOverFileList()
LButton::
	SuppressRButtonUp:=true
	Shell_GoBack()
	return
#if

#if HKMouseGestures && SuppressRButtonUp
~RButton UP::
	SuppressRButtonUp:=false
	Send, {Esc}
	Return
#if

#if HKMouseGestures && GetKeyState("LButton","P") && (WinActive("ahk_group ExplorerGroup")||IsDialog()) && IsMouseOverFileList()
RButton::
	Shell_GoForward()
	SuppressRButtonUp:=true
	Return
#if

;Enter:Execute focussed file
#if HKImproveEnter && WinActive("ahk_group ExplorerGroup") && InFileList() && !IsRenaming() && !IsContextMenuActive()
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
#if (RecallExplorerPath && ExplorerPath != "") || AlignExplorer && WinActive("ahk_group ExplorerGroup")
#e::RunExplorer()
#if
RunExplorer()
{
	global AlignExplorer, RecallExplorerPath, ExplorerPath
	active:=WinActive("ahk_group ExplorerGroup")
	if(active && AlignExplorer)
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
	if(RecallExplorerPath && ExplorerPath)
		Run(A_WinDir "\explorer.exe /n,/e," ExplorerPath)
	Else
		run, "%A_WinDir%\explorer.exe" "",, UseErrorLevel
	if(AlignExplorer && active)
	{
		WinWaitNotActive ahk_id %active%	
		Loop ;Make sure new window is really active
		{ 
			Sleep 10 
			active2 := WinActive("ahk_group ExplorerGroup")
			if(active2 && active2 != active)
				   Break 
		}
		Loop ;Wait until new window is visible
		{
			Sleep 10
			WinGet,visible,style, ahk_id %active2%
			if(visible & 0x10000000)
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
	Trigger := EventSystem_CreateSubEvent("Trigger","DoubleClickDesktop")
	OnTrigger(Trigger)
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
					Trigger := EventSystem_CreateSubEvent("Trigger","ExplorerDoubleClickSpace")
					OnTrigger(Trigger)
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
if(IsDoubleClick() && IsMouseOverFreeTaskListSpace())
{
	outputdebug doubleclicktaskbar
	Trigger := EventSystem_CreateSubEvent("Trigger", "DoubleClickTaskbar")
	OnTrigger(Trigger)
}
else
{
	Send {LButton Down}
	while(GetKeyState("LButton", "P"))
		Sleep 50
	Send {LButton Up}
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
OpenInNewFolder()
{
	global UseTabs, MiddleOpenFolder
 	if(!WinActive("ahk_group ExplorerGroup")||!IsMouseOverFileList())
 		return false	
	selected:=GetSelectedFiles(0)
	Send {LButton}
	Sleep 100
	if(InStr(FileExist(undermouse:=GetSelectedFiles()), "D"))
		dir:=true
	if(select!=selected)
		SelectFiles(selected,1,0,0)
	if(!dir)
		return false
	if(MiddleOpenFolder = 1)
		Run(A_WinDir "\explorer.exe /n,/e," undermouse)
	else if(MiddleOpenFolder = 2 && UseTabs)
		CreateTab(0,undermouse, 1)
	else if(MiddleOpenFolder = 3 && UseTabs)
		CreateTab(0,undermouse, 0)
	return true
}
;Middle click on desktop -> Change wallpaper
ToggleWallpaper()
{
	global
	if(!IsMouseOverDesktop() || A_OSVersion != "WIN_7")
		return false
	ShellContextMenu("Desktop",1)
	return true
}

;Scroll tree list with mouse wheel
#if (ScrollUnderMouse && ((IsWindowUnderCursor("#32770") && IsDialog()) || IsWindowUnderCursor("CabinetWClass")||IsWindowUnderCursor("ExploreWClass")) && !IsRenaming())||(Accessor.GUINum && WinActive(Accessor.WindowTitle))
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

#if HKInvertSelection && WinActive("ahk_group ExplorerGroup") && GetKeyState("CONTROL", "P")
^i UP::InvertSelection(WinExist("A"))
#if

;Makes a currently active explorer window show all files contained in "files" list. Only folders are used, files are ignored.
;files is a `n separated list of complete paths
FlatView(files)
{
	if(files = "")
		return
		
	Path := FindFreeFileName(A_Temp "\7plus\FlatView.search-ms")
	searchString=
	(
	<?xml version="1.0"?>
	<persistedQuery version="1.0">
		<viewInfo viewMode="details" iconSize="16" stackIconSize="0" displayName="Test" autoListFlags="0">
			<visibleColumns>
				<column viewField="System.ItemNameDisplay"/>
				<column viewField="System.ItemTypeText"/>
				<column viewField="System.Size"/>
				<column viewField="System.ItemFolderPathDisplayNarrow"/>
			</visibleColumns>
			<sortList>
				<sort viewField="System.Search.Rank" direction="descending"/>
				<sort viewField="System.ItemNameDisplay" direction="ascending"/>
			</sortList>
		</viewInfo>
		<query>
			<attributes/>
			<kindList>
				<kind name="item"/>
			</kindList>
			<scope>
	)
	Loop % files.len()
	{ 
		if(InStr(FileExist(files[A_Index]), "D"))
			searchString:=searchString "<include path=""" files[A_Index] """/>"
	}
	searchString.="</scope></query></persistedQuery>"
	Fileappend,%searchString%, %Path%
	SetDirectory(Path)
}
InitInfoGui()
{
	global ExplorerWindows
	freetext:=TranslateMUI(shell32MUIpath,12336) ;Aquire a translated version of "free"outputdebug freetext %freetext%
	freetext:=SubStr(freetext,InStr(freetext," ",0,0)+1)
	ExplorerWindows.InfoGuiStuff := Object("FreeText", freetext)
}
ShouldShowInfo(ExplorerWindow)
{
	global 7plus_Blocked
	if(7plus_Blocked)
		return false
	ControlGet, visible, visible, , msctls_statusbar321, % "ahk_id " ExplorerWindow.hwnd ;Check if status bar is visible
	if(!visible)
		return false
	return true
}

UpdateInfos:
UpdateInfos()
return
;TODO: Continue here and rework the update code. Maybe move it inside the Explorer window class.
UpdateInfos(ExplorerWindow)
{
	global freetext, newstring, freestring
	static selectedfiles1, currentfolder1
	Loop % ExplorerWindows.len()
	{
		files:=GetSelectedFiles()
		path:=GetCurrentFolder()
		if(files=selectedfiles1 && path=currentfolder1 && !force)
			return
		selectedfiles1:=files
		currentfolder1:=path
		totalsize:=0
		count:=0
		realfiles:=0 ;check if only folders are selected
		Loop, Parse, files, `n,`r
		{
			FileGetSize, size, %A_LoopField%
			if(realfiles=0)	  		
				realfiles:=!InStr(FileExist(A_LoopField), "D")
			totalsize+=size
			count++
		}
		
		DriveSpaceFree, free, %Path%
		freeunit:=6
		totalunit:=0
		if(totalsize!=0)
		{
			while(totalsize>1024 && totalunit<12)
			{
				totalsize/=1024.0
				totalunit+=3
			}
			while(totalsize<1&&totalunit>=0)
			{
				totalsize*=1024.0
				totalunit=3
			}
		}
		if(free!=0)
		{
			while(free>1024 && freeunit<12)
			{
				free/=1024.0
				freeunit+=3
			}
			while(free<1&&freeunit>=0)
			{
				free*=1024.0
				freeunit-=3
			}
		}
		if(freeunit=0) 
			freeunit=B
		else if(freeunit=3) 
			freeunit=KB
		else if(freeunit=6) 
			freeunit=MB
		else if(freeunit=9)
			freeunit=GB
		else if(freeunit=12)
			freeunit=TB
		if(totalunit=0)
			totalunit=B
		else if(totalunit=3)
			totalunit=KB
		else if(totalunit=6)
			totalunit=MB
		else if(totalunit=9)
			totalunit=GB
		else if(totalunit=12)
			totalunit=TB
		if(free)
		{
			SetFormat float,0.2
			free+=0
			text=%free%%freeunit% %freetext%
			if(text!=freestring)
			{
				GuiControl 2:Text, FreeSpace, %free%%freeunit% %freetext%
				freestring:=text
			}
		}
		else
		{
			text=%A_Space%
			if(text!=freestring)
			{
				GuiControl 2:Text, FreeSpace, %A_Space%
				freestring:=text
			}
		}
		if(count && realfiles)
		{
			SetFormat float,0.2
			totalsize+=0
			text=%totalsize%%totalunit%
			if(text!=newstring)
			{
				GuiControl 2:Text, SelectedFileSize, %totalsize%%totalunit%
				newstring:=text
			}
		}
		else
		{
			text=%A_Space%
			if(text!=newstring)
			{
				GuiControl 2:Text, SelectedFileSize, %A_Space%
				newstring:=text
			}
		}
		UpdateInfoPosition()
	}
	return
}

MoveExplorer:
UpdateInfoPosition()
;UpdatePosition(TabNum,TabWindow)
return
UpdateInfoPosition()
{
	Gui, 2: -Caption  +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
	if(ShouldShowInfo())
	{
		WinGetPos , X, Y, Width, Height, A
		ControlGetPos , , cY, , cHeight, msctls_statusbar321, A
		InfoX:=X+Width-370
		InfoY:=Y+cY+cHeight/2-6 ;+Height-26
		if(Width>540)
			Gui, 2:Show, AutoSize NA x%InfoX% y%InfoY%
	}
	else
		Gui, 2:Hide
}

;Find all explorer windows, register them in ExplorerWindows array and set up events and info gui
RegisterExplorerWindows()
{
	global ExplorerWindows, ExplorerWindow
	WinGet, hWndList, List, ahk_group ExplorerGroup
	Loop % hwndList0
	{
		if(!ExplorerWindows.IndexOfSubItem("hwnd", hWndList%A_Index%))
			ExplorerWindows.append(new ExplorerWindow(hwndList%A_Index%))
	}
}
;Registers all explorer windows for SelectionChanged events. Called when explorer changes path
RegisterSelectionChangedEvents()
{
	global ExplorerWindows
	Loop % ExplorerWindows.len()
		ExplorerWindows[A_Index].RegisterSelectionChangedEvent()
}
/*
;Unregister an explorer window for SelectionChanged events
UnregisterSelectionChangedEvents(hwnd)
{
	global RegisteredSelectionChangedWindows
	i := RegisteredSelectionChangedWindows.indexOfSubItem("hwnd", hwnd)
	if(i > 0)
		RegisteredSelectionChangedWindows.Delete(i)
}
*/
RestoreExplorerSelection()
{
	global ExplorerWindows
	hwnd := WinActive("ahk_group ExplorerGroup")
	if(hwnd)
	{
		ExplorerWindow := ExplorerWindows.SubItem("hWnd",hwnd)
		if(!IsObject(ExplorerWindow.Selection.History))
			outputdebug % "Explorer window " hwnd " is not registered!"
		if(ExplorerWindow.Selection.History.len() > 1)
		{		
			outputdebug % "Explorer window " hwnd "restore selection"
			Selection := ExplorerWindow.Selection.History[ExplorerWindow.Selection.History.len() - 1]
			; A SelectionChanged event will be fired 2 times that needs to be suppressed? 
			;Why is it fired 2 times instead of one time for each file? -> Probably because of timing
			ExplorerWindow.Selection.IgnoreNextEvent := 2 
			outputdebug % "Explorer window " hwnd " expecting " ExplorerWindow.Selection.IgnoreNextEvent " selection events."
			SelectFiles(Selection,1,0,1,1,hwnd)
			ExplorerWindow.Selection.History.Delete(ExplorerWindow.Selection.History.len())
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
	global TabContainerList, TabNum, TabWindow, SuppressTabEvents, HKShowSpaceAndSize, ExplorerWindows, ExplorerWindow
	if(!ExplorerWindows.IndexOfSubItem("hwnd",hwnd))
		ExplorerWindows.Append(new ExplorerWindow(hwnd))
	RegisterSelectionChangedEvents()
	;Explorer info stuff
	; if(A_OSVersion="WIN_7" && HKShowSpaceAndSize)
	; {
		; UpdateInfos(1)
		; SetTimer, UpdateInfos, 100
	; }
	if(SuppressTabEvents)
		return
	if(TabContainerList.active=hwnd) ;If active hwnd is set to this window already, activation shall be handled elsewhere
		return
	DecToHex(hwnd)
	if(TabContainer:=TabContainerList.ContainsHWND(hwnd))
	{
		TabContainerOld:=TabContainerList.ContainsHWND(TabContainerList.active)
		;outputdebug set active
		OldTab:=TabContainer.active
		TabContainerList.active:=hwnd
		TabContainer.active:=hwnd
		
		if(TabContainer!=TabContainerOld)
			UpdateTabs()
		UpdatePosition(TabNum, TabWindow)
		
		;SetTimer, UpdatePosition, 100
	}
}
;Called when an explorer window gets deactivated.
ExplorerDeactivated(hwnd)
{
	global TabContainerList, TabNum, TabWindow,SuppressTabEvents, HKShowSpaceAndSize
	hwnd:=WinExist("A")
	if(hwnd=TabWindow)
		return
	; if(HKShowSpaceAndSize && A_OsVersion = "WIN_7")
		; UpdateInfoPosition()
	if(SuppressTabEvents)
		return
	TabContainerList.active:=0
	UpdatePosition(TabNum, TabWindow)
	;SetTimer, UpdatePosition, Off
}
;Called when an explorer window gets destroyed.
ExplorerDestroyed(hwnd)
{
	global TabContainerList,TabWindowClose, ExplorerWindows
	outputdebug ExplorerDestroyed()
	if(index := ExplorerWindows.IndexOfSubItem("hwnd", hwnd))
		ExplorerWindows.Remove(index) ;This will destroy the info gui as well
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(!TabContainer)
		return
	if(TabWindowClose = 0)
		CloseTab(hwnd,TabContainer)
	else if(TabWindowClose = 1)
		TabContainer.CloseAllTabs()
	return
}
;Called when active explorer changes its path.
ExplorerPathChanged(from, to)
{
	global vista7, HKSelectFirstFile
	RegisterSelectionChangedEvents() ;Need to reregister for this event
	;focus first file
	if(HKSelectFirstFile)
	{
		SplitPath, to, name, dir,,,drive
		x:=GetSelectedFiles()
		if(!x && dir && (!vista7||SubStr(to, 1 ,40)!="::{26EE0668-A00A-44D7-9371-BEB064C98683}"))
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
	outputdebug ExplorerSelectionChanged
	Loop % ExplorerWindows.Len()
	{
		if(ExplorerWindows[A_Index].Selection.COMObject = ExplorerCOMObject)
		{
			index := A_Index
			break
		}
	}
	if(!index)
		return
	if(ExplorerWindows[A_Index].Selection.IgnoreNextEvent > 0)
	{
		ExplorerWindows[A_Index].Selection.IgnoreNextEvent := ExplorerWindows[A_Index].Selection.IgnoreNextEvent - 1
		outputdebug % "expecting " ExplorerWindows[A_Index].Selection.IgnoreNextEvent " more events."
		return
	}
	ExplorerWindows[A_Index].Selection.History.append(ToArray(GetSelectedFiles(0, ExplorerWindows[A_Index].hwnd)))
	if(ExplorerWindows[A_Index].Selection.History.len() > 10)
		ExplorerWindows[A_Index].Selection.History.Delete(1)
	UpdateInfos(ExplorerWindow) ;Update the info GUI to reflect selection change
	; Critical, Off
}

class ExplorerWindow
{
    var hWnd := 0
	var Path := ""
    __New(hWnd, Path="")
    {
        this.hWnd := hWnd
		this.Path := Path ? Path : GetCurrentFolder(hWnd)
		this.InfoGUI := this.CreateInfoGUI()
		Selection := Object()
		this.RegisterSelectionChangedEvent()
    }
	__Delete()
	{
		DestroyInfoGUI()
	}
	CreateInfoGui()
	{
		GuiNum := GetFreeGuiNum(10)
		Gui, %GuiNum%: font, s9, Segoe UI 
		Gui, %GuiNum%: Add, Text, x60 y0 w70 h12, %A_Space%
		Gui, %GuiNum%: Add, Text, x0 y0 w60 h12, %A_Space%
		Gui, %GuiNum%: -Caption  +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
		Gui, %GuiNum%: Color, FFFFFF
		Gui, %GuiNum%: +LastFound
		WinSet, TransColor, FFFFFF
		AttachToolWindow(this.hWnd, GuiNum, true)
		return Object("GuiNum", GuiNum, "hwnd", WinExist())
	}
	DestroyInfoGUI()
	{
		Gui % this.InfoGui.GuiNum ":Destroy"
	}
	RegisterSelectionChangedEvent()
	{
		global ExplorerWindows
		for Item in ComObjCreate("Shell.Application").Windows
		{
			if(Item.hWnd != this.hWnd)
				continue
			if(!ExplorerWindows[index].Selection.COMObject) ;New explorer window
			{
				doc:=Item.Document
				if(!doc)
					return 0
				ComObjConnect(doc, "Explorer")
				ExplorerWindows[index].Selection.COMObject := doc
				ExplorerWindows[index].Selection.History := Array(this.GetSelectedFiles(0))
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
					ExplorerWindows[index].Selection.COMObject := doc
					ExplorerWindows[index].Selection.History := Array(this.GetSelectedFiles(0)) ;Recreate array to remove selection history from previous folder
					ExplorerWindows[index].Path := Path
				}
			}
		}
	}
	GetSelectedFiles(FullName)
	{
		return ToArray(GetSelectedFiles(FullName, this.hWnd))
	}
}