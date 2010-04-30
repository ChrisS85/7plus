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
    {
      outputdebug focussed %A_LoopField%
      return A_LoopField
    } 
  } 
  outputdebug nothing focussed
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
		{
			outputdebug over filelist
			return true
		}
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

;Called when active explorer changes its path
ExplorerPathChanged(from, to)
{
	global vista7, HKSelectFirstFile
	;focus first file
	if(HKSelectFirstFile)
	{
		x:=GetSelectedFiles()
		if(!x && (!vista7||SubStr(to, 1 ,40)!="::{26EE0668-A00A-44D7-9371-BEB064C98683}"))
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
	length:=DllCall("GetUserDefaultLocaleName","uint",&buffer,"uint",85)
	locale:=COM_Ansi4Unicode(&buffer)
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


#if HKMouseGestures && GetKeyState("RButton") && (WinActive("ahk_group ExplorerGroup")||IsDialog()) && IsMouseOverFileList()
LButton::
  outputdebug go back
	SuppressRButtonUp:=true
	;Send !{Left}
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
	outputdebug go forward
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
;Backspace: go up instead of back    
#if Vista7 && HKProperBackspace && (IsDialog() || WinActive("ahk_group ExplorerGroup")) && !IsRenaming() && (InTree()||InFileList()) && !strEndsWith(GetCurrentFolder(),".search-ms")
Backspace::Send !{Up}
#if

;Double click upwards is buggy in filedialogs, so only explorer for now until someone comes up with non-intrusive getpath, getselectedfiles functionsunrel
#if HKDoubleClickUpwards && WinActive("ahk_group ExplorerGroup") && IsMouseOverFileList() && GetKeyState("RButton")!=1
;LButton on empty space in explorer -> go upwards
~LButton::		
	outputdebug left clicked on explorer or file dialog window	
	;SendMessage, FM_GETFILESEL [, wParam, lParam, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
	CoordMode,Mouse,Relative
	;wait until button is released again
  KeyWait, LButton
  OutputDebug, lbutton released
  ;Time for a doubleclick in windows
	WaitTime:=DllCall("GetDoubleClickTime")/1000
	OutputDebug, double click time=%Waittime%
	MouseGetPos, Click1X, Click1Y
	;This check is needed so that we don't send CTRL+C in a textfield control, which would disrupt the text entering process
	;Make sure only filelist is focussed
	if(!IsRenaming()&&InFileList())
	{
		path:=GetCurrentFolder()
		OutputDebug first click path: %path%
		files:=GetSelectedFiles()
		OutputDebug first click selected files: %files%
		;if more time than a double click time has passed, consider this a new series of double clicks
		OutputDebug("Time difference: " A_tickCount-time1)
		if(A_TickCount-time1>WaitTime*1000)
		{
			time1:=A_TickCount
			path1:=path
		}
		else
		{			
			;if less time has passed, the previous double click was cancelled for some reason and we need to check its dir too to see directory changes
			OutputDebug("Second click after first has returned for some reason, old path:" path1 "current path:" path)
			time1:=A_TickCount
			if(path!=path1)
			{
				OutputDebug("Directory changed from " path1 " to " path)
				time1:=0
				return
			}					
		}
		;this check is required so that it's possible to count any double click and not every second. If at this place a file is selected, 
		;it would swallow the second click otherwise and won't be able to count it in a double clickwait for anotherat this plac
		if (files!="")
		{ 
			OutputDebug("preexpected return becuse file was selected")
			;
			return
		}
		OutputDebug( "start waiting for second click")
		;wait for second click
		KeyWait, LButton, D T%WaitTime% 
		
		If(errorlevel=0)
		{		  
			OutputDebug("second click")
			MouseGetPos, Click2X, Click2Y
			if(abs(Click1X-Click2X)**2+abs(Click1Y-Click2Y)**2>16) ;Max 4 pixels between clicks
				return
	    
			path1:=GetCurrentFolder()
			OutputDebug("path after second click: " path1)
			if(path = path1) 
			{	
				OutputDebug("paths identical")
				if(InFileList()&&IsMouseOverFileList()) 
				{			
					OutputDebug("still correct focus")
					;check if no files selected after second click either
					files:=GetSelectedFiles()
					OutputDebug("selected files after second click:" files)
				  if (!files)
				  {
				  	OutputDebug("go upwards")
					 	if (Vista7 && !strEndsWith(GetCurrentFolder(),".search-ms"))
	            Send !{Up}
					  else
					    Send {Backspace}
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
		SplitCommand(TaskbarLaunchPath, cmd, args)
		cmd:=ExpandEnvVars(cmd)
		if(FileExist(cmd))
			run, "%cmd%" %args%
		else if(TaskbarLaunchPath)
		{
			ToolTip(1, "You need to enter a valid command in <a>Settings</a> to run when you double click on empty taskbar space!", "Invalid Command","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
			SetTimer, ToolTipClose, -10000
			TooltipShowSettings:=true
		}
	}
	/*
	else if (HKActivateBehavior && A_OSVersion="WIN_7")
	{
		Send {CTRL Down}{LButton Down}
  	while(GetKeyState("LButton", "P"))
  		Sleep 20
  	Send {LButton Up}{CTRL Up}
  }
  */
	else
	{
		Send {LButton Down}
  	while(GetKeyState("LButton", "P"))
  		Sleep 50
  	Send {LButton Up}
	}
	return
#if

IsDoubleClick()
{	
	return A_TimeSincePriorHotkey< DllCall("GetDoubleClickTime") && A_ThisHotkey=A_PriorHotkey
}

*MButton::
key:=GetKeyState("CTRL") ? "^" : ""
key.=GetKeyState("ALT") ? "!" : ""
key.=GetKeyState("SHIFT") ? "+" : ""
key.=(GetKeyState("RWIN") || GetKeyState("LWIN")) ? "#" : ""
Handled:=TaskbuttonClose()
if !Handled
	Handled:=ToggleWallpaper()
if !Handled
	Handled:=TitleBarClose()
if !Handled
	Handled:=OpenInNewFolder()
if !Handled
	Handled:=FastFolderMenu()
if !Handled
{	
	Send %key%{MButton down}
	KeyWait, MButton
	Send {MButton up}
}
return 

OpenInNewFolder()
{
	global HKOpenInNewFolder
 	if(!HKOpenInNewFolder||!WinActive("ahk_group ExplorerGroup")||!IsMouseOverFileList())
 		return false	
	selected:=GetSelectedFiles(0)
	SendEvent {LButton}
	;Sleep 100
	if(InStr(FileExist(undermouse:=GetSelectedFiles()), "D"))
		dir:=true
	if(select!=selected)
		SelectFiles(selected)
	if(!dir)
		return false
	run explorer.exe %undermouse%
	return true
}
;Middle click on desktop -> Change wallpaper
ToggleWallpaper()
{
	global
	if (HKToggleWallpaper && IsMouseOverDesktop())
		ShellContextMenu("Desktop",1)
	else 
		return false
	return true
}

#if HKCreateNewFile && (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()) && !IsRenaming() 
;F7: Create new text file  
F7::CreateNewTextFile()	
#if
CreateNewTextFile()
{
  global Vista7
	;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
	if(Vista7)
    TextTranslated:=TranslateMUI("notepad.exe",470) ;"New Textfile"
  else
  {
    newstring:=TranslateMUI("shell32.dll",8587) ;"New"
    TextTranslated:=newstring " " TranslateMUI("notepad.exe",469) ;"Textfile"
    
  }
	path:=GetCurrentFolder()
	Testpath := path "\" TextTranslated ".txt"
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=path "\" TextTranslated " (" i ").txt"
	}
	FileAppend , %A_Space%, %TestPath%	;Create file and then select it and rename it
	if(!FileExist(TestPath))
	{
		ToolTip(1, "Could not create a new textfile here. Make sure you have the correct permissions!", "Could not create new textfile!","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -5000
		return
	}
	RefreshExplorer()
	Sleep 50
	if(i=1)
		SelectFiles(TextTranslated ".txt")
	else
		SelectFiles(TextTranslated " (" i ").txt")
	Sleep 50
	Send {F2}
	return
}

;F8: Create new Folder  
#if HKCreateNewFolder && !IsRenaming() && (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog())
F8::
if(A_OSVersion="WIN_7")
  Send ^+n
else
  CreateNewFolder()
return
#if
CreateNewFolder()
{
	Global shell32muipath
  ;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
	if(A_OSVersion="WIN_VISTA")
		TextTranslated:=TranslateMUI(shell32muipath,16859) ;"New Folder"
	else
  	TextTranslated:=TranslateMUI("shell32.dll",30320) ;"New Folder"
	path:=GetCurrentFolder()
	Testpath := path "\" TextTranslated
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=path "\" TextTranslated " (" i ")"
	}
	FileCreateDir, %TestPath%	;Create file and then select it and rename it
	if(!FileExist(TestPath))
	{
		ToolTip(1, "Could not create a new textfile here. Make sure you have the correct permissions!", "Could not create new textfile!","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -5000
		return
	}
	RefreshExplorer()
	if(i=1)
		SelectFiles(TextTranslated)
	else
		SelectFiles(TextTranslated " (" i ")")
	Sleep 50
	Send {F2}
	return
}

;F3: edit selected files
#if (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()) && !IsRenaming() 
F3::EditSelectedFiles()
#if
EditSelectedFiles()
{
	global ImageExtensions,TextEditor,ImageEditor, TooltipShowSettings
	files:=GetSelectedFiles()
	if(!files)
		files:=GetFocussedFile()
	SplitByExtension(files, splitfiles, ImageExtensions)
	files:=RemoveLineFeedsAndSurroundWithDoubleQuotes(files)
	splitfiles:=RemoveLineFeedsAndSurroundWithDoubleQuotes(splitfiles)
	x:=ExpandEnvVars(TextEditor)
	y:=ExpandEnvVars(ImageEditor)
	if (files && !FileExist(x) && x && splitfiles && !FileExist(y) && y)
	{
		ToolTip(1, "You need to enter a valid path in <a>Settings</a> for text and image editors!", "Invalid Paths","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -10000
		TooltipShowSettings:=true
	}
	else if(files && !FileExist(x) && x)
	{
		ToolTip(1, "You need to enter a valid path in <a>Settings</a> for text editor!", "Invalid Path","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -10000
		TooltipShowSettings:=true
	}
	else if(splitfiles && !FileExist(y) && y)
	{
		ToolTip(1, "You need to enter a valid path in <a>Settings</a> for image editor!", "Invalid Path","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -10000
		TooltipShowSettings:=true
	}
	if ((files && FileExist(x))||(splitfiles && FileExist(y)))
	{
		if (files!="")
			run %x% %files%
		if (splitfiles!="")
			run %y% %splitfiles%
	}
	else
		SendInput {F3}
	return
}

;Alt+C:Copy filenames, CTRL+ALT+C: Copy filepaths
#if (HKCopyFilenames || HKCopyPaths) && (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()) && !IsRenaming() 
*!c::CopyFilenames()
#if
CopyFilenames()
{
	global HKCopyPaths, HKCopyFilenames,PasteFileClipboardBackup
	files := GetSelectedFiles()
	if(!files)
		files:=GetFocussedFile()
	if(files)
	{
		clip:=ReadClipboardText()
		if(!GetKeyState("Shift")) ;Shift=append to clipboard
			clip := ""
		if (GetKeyState("Control")) ; use control to save paths too
		{
			if HKCopyPaths
			{
				Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
					clip .= (clip = "" ? "" : "`r`n") A_LoopField
				PasteFileClipboardBackup:="" ;Clear clipboard backup so it won't be restored when another program gets activated, since clipboard gets changed now
				clipboard:=clip
			}
		}
		else
		{
			if HKCopyFilenames
			{
				Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
				{
					SplitPath, A_LoopField, file
					clip .= (clip = "" ? "" : "`r`n") file
				}
				PasteFileClipboardBackup:="" ;Clear clipboard backup so it won't be restored when another program gets activated, since clipboard gets changed now
				clipboard:=clip
			}
		}
	}
	else
		SendInput !{c}
	return
}

;Shift+C: Append files to clipboard
#if HKAppendClipboard && (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()) && InFileList() && !IsRenaming()
+c::	
files := GetSelectedFiles()
if(!files)
	files:=GetFocussedFile()
if(files)
	AppendToClipboard(files)
else
	Send +{c}
return
+x::	
files := GetSelectedFiles()
if(!files)
	files:=GetFocussedFile()
if(files)
	AppendToClipboard(files,1)
else
	Send +{x}
return
#if

;Scroll tree list with mouse wheel
#if ScrollUnderMouse && (IsWindowUnderCursor("CabinetWClass")||IsWindowUnderCursor("ExploreWClass")) && !IsRenaming()
WheelUp:: 
Critical 
outputdebug wheelup
MouseGetPos, MouseX, MouseY
hw_m_target := DllCall( "WindowFromPoint", "int", MouseX, "int", MouseY )
SendMessage, 0x20A, 120 << 16, ( MouseY << 16 )|MouseX,, ahk_id %hw_m_target%
return 

WheelDown:: 
Critical 
MouseGetPos, MouseX, MouseY 
hw_m_target := DllCall( "WindowFromPoint", "int", MouseX, "int", MouseY ) 
SendMessage, 0x20A, -120 << 16, ( MouseY << 16 )|MouseX,, ahk_id %hw_m_target% 
return
#if

#if HKInvertSelection && WinActive("ahk_group ExplorerGroup")
^i::InvertSelection()
#if
#x::Outputdebug(GetCurrentFolder())
;Flat View
#if HKFlattenDirectory && Vista7 && WinActive("ahk_group ExplorerGroup")
+Enter::
if(FileExist(a_scriptdir "\FlatView.search-ms"))
	FileDelete %a_scriptdir%\FlatView.search-ms 
files:=GetSelectedFiles()
/*
if(files="::{26EE0668-A00A-44D7-9371-BEB064C98683}")
{
	outputdebug god mode
	SetDirectory("::{ED7BA470-8E54-465E-825C-99712043E01C}")
}
*/
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
Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n). 
{ 
  if InStr(FileExist(A_LoopField), "D")
	{
		searchString=%searchString%<include path="%A_LoopField%"/>
	}
} 
searchString.="</scope></query></persistedQuery>"
Fileappend,%searchString%, %a_scriptdir%\FlatView.search-ms 
SetDirectory(a_scriptdir "\FlatView.search-ms")
return
#if

CreateInfoGui()
{
	global FreeSpace, SelectedFileSize
	outputdebug creategui
	gui, 1: font, s9, Segoe UI 
	Gui, 1: Add, Text, x60 y0 w60 h12 vFreeSpace, %A_Space%
	Gui, 1: Add, Text, x0 y0 w60 h12 vSelectedFileSize, %A_Space%
	Gui, 1: -Caption  +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
	Gui, 1: Color, FFFFFF
	Gui 1: +LastFound
	WinSet, TransColor, FFFFFF
}
DestroyInfoGui()
{
	Gui 1:Destroy
}
ShouldShowInfo()
{
	if !WinActive("ahk_group ExplorerGroup")
		return false
	ControlGet, visible, visible, , msctls_statusbar321, A ;Check if status bar is visible
	if(!visible)
		return false
	Gui 1: +LastFound
	WinGetPos , X, Y, Width, Height,A
	WinGetClass,class
	x1:= GetVisibleWindowAtPoint(X+Width-370,Y+Height-26,class) 
	x2:= GetVisibleWindowAtPoint(X+Width-370+131,Y+Height-26,class) 
	y1:=GetVisibleWindowAtPoint(X+Width-370+131,Y+Height-26+18,class)				;window border doesn't seem to count to window?
	y2:=GetVisibleWindowAtPoint(X+Width-370+131,Y+Height-26+18,class) 
	list:="ExplorerWClass,CabinetWClass"
	if x1 not in %list%
		return false
	if x2 not in %list%
		return false
	if y1 not in %list%
		return false
	if y2 not in %list%
		return false
	return true
}

UpdateInfos:
UpdateInfos()
return
UpdateInfos()
{
	global shell32MUIpath
	if(WinActive("ahk_group ExplorerGroup") && !IsContextMenuActive())
	{
		path:=GetCurrentFolder()
		files:=GetSelectedFiles()
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
			totalunit=GBq
		else if(totalunit=12)
			totalunit=TB
		if(free)
		{
			SetFormat float,0.2
			free+=0
			freetext:=TranslateMUI(shell32MUIpath,12336) ;Aquire a translated version of "free"outputdebug freetext %freetext%
			freetext:=SubStr(freetext,InStr(freetext," ",0,0)+1)
			GuiControl 1:Text, FreeSpace, %free%%freeunit% %freetext%
		}
		else
			GuiControl 1:Text, FreeSpace, %A_Space%
		if(count && realfiles)
		{
			SetFormat float,0.2
			totalsize+=0			
			GuiControl 1:Text, SelectedFileSize, %totalsize%%totalunit%
		}
		else
			GuiControl 1:Text, SelectedFileSize, %A_Space%
	}
	else
	{
		GuiControl 1:Text, SelectedFileSize, %A_Space%
		GuiControl 1:Text, FreeSpace, %A_Space%
	}
	UpdateInfoPosition()
	return
}

MoveExplorer:
UpdateInfoPosition()
return
UpdateInfoPosition()
{
	if(ShouldShowInfo())
	{
		WinGetPos , X, Y, Width, Height, A
		ControlGetPos , , cY, , cHeight, msctls_statusbar321, A
		InfoX:=X+Width-380
		InfoY:=Y+cY+cHeight/2-6 ;+Height-26
		if(Width>540)
			Gui, 1: Show, AutoSize NA x%InfoX% y%InfoY%
	}
	else
		Gui, 1: Hide
}


