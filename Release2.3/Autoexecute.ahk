;Groups for explorer classes
GroupAdd, ExplorerGroup, ahk_class ExploreWClass
GroupAdd, ExplorerGroup, ahk_class CabinetWClass
GroupAdd, DesktopGroup, ahk_class WorkerW
GroupAdd, DesktopGroup, ahk_class Progman ;Progman for older windows versions <Vista
GroupAdd, TaskbarGroup, ahk_class Shell_TrayWnd
GroupAdd, TaskbarGroup, ahk_class BaseBar
GroupAdd, TaskbarGroup, ahk_class DV2ControlHost
GroupAdd, TaskbarDesktopGroup, ahk_group DesktopGroup
GroupAdd, TaskbarDesktopGroup, ahk_group TaskbarGroup

CommunicateWithRunningInstance()
FileCreateDir %A_Temp%\7plus

;Try to use config file from script dir in portable mode or when it wasn't neccessary to copy it to appdata yet
if(IsPortable)
	ConfigPath := A_ScriptDir 
Else
{
	ConfigPath := A_AppData "\7plus"
	if(!FileExist(ConfigPath))
		FileCreateDir, %ConfigPath%
}
IniPath := ConfigPath "\Settings.ini"
IniRead, RunAsAdmin, %IniPath%, Misc, RunAsAdmin , Always/Ask
;If program is run without admin privileges, try to run it again as admin, and exit this instance when the user confirms it
if(!A_IsAdmin && RunAsAdmin = "Always/Ask")
{
	Loop %0%
		params .= " " (InStr(%A_Index%, " ") ? """" %A_Index% """" : %A_Index%)
	If(A_IsCompiled)
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "/r" params, str, A_WorkingDir, int, 1)
	else
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, "/r """ A_ScriptFullPath """" params, str, A_WorkingDir, int, 1)
	If(uacrep = 42) ;UAC Prompt confirmed, application may run as admin
		ExitApp
	else
		MsgBox 7plus is running in non-admin mode. Some features will not be working.
}
;Start debugger
IniRead, DebugEnabled, %IniPath%, General, DebugEnabled , 0
IniRead, ProfilingEnabled, %IniPath%, General, ProfilingEnabled , 0
if(DebugEnabled)
	DebuggingStart()
outputdebug 7plus Starting...
if(ProfilingEnabled)
{
	Profiler := Object("Total", Object("StartTime", A_TickCount, "EventLoop", 0, "ShellMessage", 0, "HookProc", 0), "Current", Object("StartTime", A_TickCount, "EventLoop", 0, "ShellMessage", 0, "HookProc", 0))
	; SetTimer, ResetCurrentProfiling, 10000
	SetTimer, ShowProfiling, 1000
}
;If the current config path is set to the program directory but there is no write access, %AppData%\7plus needs to be used.
;If this is the first time (i.e. NoAdminSettingsTransfered = 0), all config files need to be copied to the new config path
if((IsPortable && !WriteAccess(A_ScriptDir "\Accessor.xml")) || ConfigPath = A_AppData "\7plus")
{
	if(IsPortable)
		MsgBox No file access to settings files in program directory. 7plus will not be able to store its settings. Please move 7plus to a folder with write permissions, run it as administrator, or grant write permissions to this directory.
	else
	{
		ConfigPath := A_AppData "\7plus"
		if(!FileExist(ConfigPath))
			FileCreateDir, %ConfigPath%
	}
}

IniRead, PatchVersion, %IniPath%, General, PatchVersion, 0

if(!FileExist(ConfigPath "\Events.xml") && FileExist(A_ScriptDir "\Events\All Events.xml")) ;Fresh install, copy default events file into config directory
{
	FileCopy, %A_ScriptDir%\Events\All Events.xml, %ConfigPath%\Events.xml
	ApplyUpdateFixes()
}
;Get windows version
RegRead, vista7, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
vista7 := vista7 >= 6

;initialize gdi+
outputdebug starting gdip
pToken := Gdip_Startup()

;Exit Routine
OnExit, ExitSub

;Menu entries need to be shown before events are loaded
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Settings, SettingsHandler  ; Creates a new menu item.
menu, tray, Default, Settings

;Init event system
outputdebug starting event system
EventSystem_Startup()

;Update checker
IniRead, AutoUpdate, %IniPath%, Misc, AutoUpdate, 1
if(AutoUpdate)
{
	outputdebug AutoUpdate
	AutoUpdate()
	AutoUpdate_CheckPatches()
}
outputdebug PostUpdate
PostUpdate()


CreateTabWindow()

;On first run, wizard is used to setup values
IniRead, FirstRun, %IniPath%, General, FirstRun , 1

IniRead, JoyControl, %IniPath%, Misc, JoyControl , 0
if(JoyControl)
	JoystickStart()

;Explorer pasting as file
IniRead, ImgName, %IniPath%, Explorer, Image, clip.png
IniRead, TxtName, %IniPath%, Explorer, Text, clip.txt
;the path where the image file is saved for copying
temp_img := A_Temp . "\" . ImgName
temp_txt := A_Temp . "\" . TxtName

CF_HDROP = 0xF ;clipboard identifier of copied file from explorer


;Register a shell hook to get messages when windows get activated, closed etc
Gui +LastFound
hAHK := WinExist()
FileDelete, %A_Temp%\7plus\hwnd.txt
FileAppend, %hAHK%, %A_Temp%\7plus\hwnd.txt
outputdebug 7plus window handle: %hahk%
DllCall( "RegisterShellHookWindow", "Ptr",hAHK ) 
ShellHookMsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ) 
OnMessage( ShellHookMsgNum, "ShellMessage" ) 
;Tooltip messages
; OnMessage(0x202,"WM_LBUTTONUP") ;Will make ToolTip Click possible 
; OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
 
;Register an event hook to catch move and dialog creation messages
HookProcAdr := RegisterCallback("HookProc", "F" ) 
API_SetWinEventHook(0x8001,0x800B,0,HookProcAdr,0,0,0) ;Make sure not to register unneccessary messages, as this causes cpu load
API_SetWinEventHook(0x0016,0x0016,0,HookProcAdr,0,0,0) ;EVENT_SYSTEM_MINIMIZESTART
; API_SetWinEventHook(0x000E,0x000E,0,HookProcAdr,0,0,0)
API_SetWinEventHook(0x000A,0x000B,0,HookProcAdr,0,0,0) ;EVENT_SYSTEM_MOVESIZESTART
DetectHiddenWindows, On

IniRead, HKPlacesBar, %IniPath%, Explorer, HKPlacesBar, 0
IniRead, HKCleanFolderBand, %IniPath%, Explorer, HKCleanFolderBand, 0
IniRead, HKFolderBand, %IniPath%, Explorer, HKFolderBand, 0


IniRead, HKSelectFirstFile, %IniPath%, Explorer, HKSelectFirstFile, 1
IniRead, HKImproveEnter, %IniPath%, Explorer, HKImproveEnter, 1
IniRead, HKShowSpaceAndSize, %IniPath%, Explorer, HKShowSpaceAndSize, 1
IniRead, HKMouseGestures, %IniPath%, Explorer, HKMouseGestures, 1
IniRead, HKAutoCheck, %IniPath%, Explorer, HKAutoCheck, 1
IniRead, ScrollUnderMouse, %IniPath%, Explorer, ScrollUnderMouse, 1
IniRead, HKInvertSelection, %IniPath%, Explorer, HKInvertSelection, 1
IniRead, HKOpenInNewFolder, %IniPath%, Explorer, HKOpenInNewFolder, 1
IniRead, HKFlattenDirectory, %IniPath%, Explorer, HKFlattenDirectory, 1
IniRead, RecallExplorerPath, %IniPath%, Explorer, RecallExplorerPath, 1
IniRead, AlignExplorer, %IniPath%, Explorer, AlignExplorer, 1

IniRead, HKMiddleClose, %IniPath%, Windows, HKMiddleClose, 1
IniRead, HKActivateBehavior, %IniPath%, Windows, HKActivateBehavior, 1
IniRead, AeroFlipTime, %IniPath%, Windows, AeroFlipTime, 0.2
IniRead, HKAltDrag, %IniPath%, Windows, HKAltDrag, 1
IniRead, HKToggleWallpaper, %IniPath%, Windows, HKToggleWallpaper, 1

IniRead, HKHoverStart, %IniPath%, Windows, HKHoverStart, 1
;program to launch on double click on taskbar
IniRead, TaskbarLaunchPath, %IniPath%, Windows, TaskbarLaunchPath, %A_Windir%\system32\taskmgr.exe
stringreplace, TaskbarLaunchPath, TaskbarLaunchPath, `%A_ProgramFiles`%, %A_ProgramFiles% 
;Slide windows
IniRead, HKSlideWindows, %IniPath%, Windows, HKSlideWindows, 1
IniRead, SlideWinHide, %IniPath%, Windows, SlideWinHide, 1
SlideWindows_Startup()
IniRead, SlideWindowsBorder, %IniPath%, Windows, SlideWindowsBorder, 30
IniRead, ShowResizeTooltip, %IniPath%, Windows, ShowResizeTooltip, 1

IniRead, ImageExtensions, %IniPath%, Misc, ImageExtensions, jpg,png,bmp,gif,tga,tif,ico,jpeg
IniRead, WordDelete, %IniPath%, Misc, WordDelete, 1

;Fullscreen exclusion list
IniRead, FullscreenExclude, %IniPath%, Misc, FullscreenExclude,VLC DirectX,OpWindow,CabinetWClass
IniRead, FullscreenInclude, %IniPath%, Misc, FullscreenInclude,Project64
IniRead, ImageQuality, %IniPath%, Misc, ImageQuality,100
if(!(ImageQuality > 0 && ImageQuality <= 100))
	ImageQuality := 95
IniRead, ImageExtension, %IniPath%, Misc, ImageExtension,png
IniRead, PreviousExplorerPath, %IniPath%, Misc, PreviousExplorerPath,C:
IniRead, ExplorerPath, %IniPath%, Misc, ExplorerPath,C:

if((AeroFlipTime>=0&&Vista7)||HKSlideWindows)
{
	SetTimer, hovercheck, 10
}
;Clipboard manager list (is some sort of fixed size stack which removes oldest entry on add/insert/push)
ClipboardList := Array()
ClipboardList.push := "Stack_Push"
ClipboardList := Object("Base", ClipboardList)
if(FileExist(ConfigPath "\Clipboard.xml"))
{
	FileRead, xml, %ConfigPath%\Clipboard.xml
	XMLObject := XML_Read(xml)
	;Convert empty and single arrays to real array
	if(!XMLObject.List.len())
		XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		

	Loop % min(XMLObject.List.len(), 10)
		ClipboardList.append(XMLObject.List[A_Index])
}
FastFolders := Array()
Loop 10
{
	z := A_Index - 1
	if(z = 0)
	{
		IniRead, x, %IniPath%, FastFolders, Folder%z%, ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
		IniRead, y, %IniPath%, FastFolders, FolderTitle%z%, Computer
	}
	else if(z=1)
	{
		IniRead, x, %IniPath%, FastFolders, Folder%z%, C:\
		IniRead, y, %IniPath%, FastFolders, FolderTitle%z%, C:\
	}
    IniRead, x, %IniPath%, FastFolders, Folder%z%, %A_Space%
    IniRead, y, %IniPath%, FastFolders, FolderTitle%z%, %A_Space%
	FastFolders.append(Object("Path", x, "Title", y))
}

RegisteredSelectionChangedWindows := Array()

IniRead, UseTabs, %IniPath%, Tabs, UseTabs, 1
IniRead, NewTabPosition, %IniPath%, Tabs, NewTabPosition, 1
IniRead, TabStartupPath, %IniPath%, Tabs, TabStartupPath, %A_SPACE%
IniRead, ActivateTab, %IniPath%, Tabs, ActivateTab, 1
IniRead, TabWindowClose, %IniPath%, Tabs, TabWindowClose, 1
IniRead, OnTabClose, %IniPath%, Tabs, OnTabClose, 1
IniRead, MiddleOpenFolder, %IniPath%, Tabs, MiddleOpenFolder, 1
TabContainerList := TabContainerList()
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

if(Vista7)
	AcquireExplorerConfirmationDialogStrings()

if(A_OSVersion="WIN_7")
	CreateInfoGui()

LoadHotstrings()

result:=DllCall("uxtheme.dll\IsThemeActive") ; On non-themed environments, standard icon is used
; if(A_IsCompiled)
; {
	; if(result)
		; Menu, tray, Icon, %A_ScriptFullPath%, 8,1
	; else
		; Menu, tray, Icon, %A_ScriptFullPath%, 8,1
; }	
; else
; {
	if(result)
		Menu, tray, Icon, %A_ScriptDir%\7+-w2.ico,,1
	else
		Menu, tray, Icon, %A_ScriptDir%\7+-w.ico,,1
; }
IniRead, HideTrayIcon, %IniPath%, Misc, HideTrayIcon, 0

;Show tray icon when loading is complete
if(!HidetrayIcon)
	menu, tray, Icon
	
SetTimer, TriggerTimer, 1000
; SetTimer, AssignHotkeys, -10000


;possibly start wizard
if (Firstrun=1)
	GoSub, wizardry
FirstRun:=0

;Set this so that config files aren't saved with empty values when there was a problem with the startup procedure
ProgramStartupFinished := true

Suspend, Off

outputdebug 7plus startup procedure finished, entering event loop.

;Event loop
EventScheduler()
Return

ExitSub:
OnExit()
ExitApp

OnExit(Reload=0)
{
	global
	static ShouldReload
	if(ShouldReload) ;If set, code below has already been executed by a previous call to this function
		return
	if(ProgramStartupFinished)
	{
		EventSystem_End()
		Gdip_Shutdown(pToken)
		WriteIni()
		WriteClipboard()
		Action_Upload_WriteFTPProfiles()
		SlideWindows_Exit()
		TabContainerList.CloseAllInactiveTabs()
		SaveHotstrings()
	}
	if(Reload)
	{
		ShouldReload := 1
		Loop %0%
			params .= " " (InStr(%A_Index%, " ") ? """" %A_Index% """" : %A_Index%)
		
		If(A_IsCompiled)
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "/r" params, str, A_WorkingDir, int, 1)
		else
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, "/r """ A_ScriptFullPath """" params, str, A_WorkingDir, int, 1)
	}
	FileRemoveDir, %A_Temp%\7plus, 1
}
;Some first run intro
wizardry:
ShowWizard()
return

ShowWizard()
{
	GoSub RegisterShellExtension
	MsgBox, 4,,Welcome to 7plus!`nBefore we begin, would you like to see a list of features?	
	IfMsgBox Yes
		run http://code.google.com/p/7plus/wiki/Features,,UseErrorlevel
	Notify("Open Settings?", "At the beginning you should take some minutes and check out the settings.`nDouble click on the tray icon or click here to open the settings window.", "10", "GC=555555 TC=White MC=White AC=SettingsHandler",24)
	
	; Tooltip(1, "That's it for now. Have fun!", "Everything Done!","O1 L1 P99 C1 XTrayIcon YTrayIcon I1")
	; SetTimer, ToolTipClose, -5000	
	return
}

WriteIni()
{
	global
	local temp,x,y,z
	if(!FileExist(ConfigPath))
		FileCreateDir %ConfigPath%
	FileDelete, %IniPath%
	
	IniWrite, %DebugEnabled%, %IniPath%, General, DebugEnabled
	IniWrite, %DebugEnabled%, %IniPath%, General, ProfilingEnabled
	IniWrite, %ImgName%, %IniPath%, Explorer, Image
	IniWrite, %TxtName%, %IniPath%, Explorer, Text
	IniWrite, %HKPlacesBar%, %IniPath%, Explorer, HKPlacesBar
	IniWrite, %HKCleanFolderBand%, %IniPath%, Explorer, HKCleanFolderBand
	IniWrite, %HKFolderBand%, %IniPath%, Explorer, HKFolderBand	
	
	IniWrite, %HKSelectFirstFile%, %IniPath%, Explorer, HKSelectFirstFile
	IniWrite, %HKImproveEnter%, %IniPath%, Explorer, HKImproveEnter
	IniWrite, %HKShowSpaceAndSize%, %IniPath%, Explorer, HKShowSpaceAndSize
	IniWrite, %HKMouseGestures%, %IniPath%, Explorer, HKMouseGestures
	IniWrite, %HKAutoCheck%, %IniPath%, Explorer, HKAutoCheck
	IniWrite, %ScrollUnderMouse%, %IniPath%, Explorer, ScrollUnderMouse
	IniWrite, %HKInvertSelection%, %IniPath%, Explorer, HKInvertSelection
	IniWrite, %HKOpenInNewFolder%, %IniPath%, Explorer, HKOpenInNewFolder
	IniWrite, %HKFlattenDirectory%, %IniPath%, Explorer, HKFlattenDirectory
	IniWrite, %RecallExplorerPath%, %IniPath%, Explorer, RecallExplorerPath
	IniWrite, %AlignExplorer%, %IniPath%, Explorer, AlignExplorer
	
	IniWrite, %UseTabs%, %IniPath%, Tabs, UseTabs
	IniWrite, %NewTabPosition%, %IniPath%, Tabs, NewTabPosition
	IniWrite, %TabStartupPath%, %IniPath%, Tabs, TabStartupPath
	IniWrite, %ActivateTab%, %IniPath%, Tabs, ActivateTab
	IniWrite, %TabWindowClose%, %IniPath%, Tabs, TabWindowClose
	IniWrite, %OnTabClose%, %IniPath%, Tabs, OnTabClose
	IniWrite, %MiddleOpenFolder%, %IniPath%, Tabs, MiddleOpenFolder
	
	IniWrite, %HKActivateBehavior%, %IniPath%, Windows, HKActivateBehavior
	IniWrite, %HKToggleWallpaper%, %IniPath%, Windows, HKToggleWallpaper
	IniWrite, %HKMiddleClose%, %IniPath%, Windows, HKMiddleClose
	IniWrite, %AeroFlipTime%, %IniPath%, Windows, AeroFlipTime
	IniWrite, %HKSlideWindows%, %IniPath%, Windows, HKSlideWindows
	IniWrite, %SlideWinHide%, %IniPath%, Windows, SlideWinHide
	IniWrite, %SlideWindowsBorder%, %IniPath%, Windows, SlideWindowsBorder
	IniWrite, %HKAltDrag%, %IniPath%, Windows, HKAltDrag
	IniWrite, %ShowResizeTooltip%, %IniPath%, Windows, ShowResizeTooltip
	IniWrite, %ImageExtensions%, %IniPath%, Misc, ImageExtensions
	IniWrite, %JoyControl%, %IniPath%, Misc, JoyControl
	IniWrite, %FullscreenExclude%, %IniPath%, Misc, FullscreenExclude
	IniWrite, %FullscreenInclude%, %IniPath%, Misc, FullscreenInclude
	IniWrite, %WordDelete%, %IniPath%, Misc, WordDelete
	IniWrite, %HideTrayIcon%, %IniPath%, Misc, HideTrayIcon
	IniWrite, %ImageQuality%, %IniPath%, Misc, ImageQuality
	IniWrite, %ImageExtension%, %IniPath%, Misc, ImageExtension
	IniWrite, %AutoUpdate%, %IniPath%, Misc, AutoUpdate
	IniWrite, %RunAsAdmin%, %IniPath%, Misc, RunAsAdmin
	IniWrite, %ExplorerPath%, %IniPath%, Misc, ExplorerPath
	IniWrite, %PreviousExplorerPath%, %IniPath%, Misc, PreviousExplorerPath
	if(NoAdminSettingsTransfered)
		IniWrite, %NoAdminSettingsTransfered%, %IniPath%, Misc, NoAdminSettingsTransfered
	if(LastReplacedEventsFile)
		IniWrite, %LastReplacedEventsFile%, %IniPath%, Misc, LastReplacedEventsFile	
	IniWrite, 0, %IniPath%, General, FirstRun
	;FastFolders
	Loop 10
	{
	    x:=A_Index-1
	    y:=FastFolders[A_Index].Path
	    z:=FastFolders[A_Index].Title
	    IniWrite, %y%, %IniPath%, FastFolders, Folder%x%
	    IniWrite, %z%, %IniPath%, FastFolders, FolderTitle%x%
	}
}
WriteClipboard()
{
	global ConfigPath, ClipboardList
	FileDelete, %ConfigPath%\Clipboard.xml
	XMLObject := Object("List",Array())
	Loop % min(ClipboardList.len(), 10)
		XMLObject.List.append(ClipboardList[A_Index])
	XML_Save(XMLObject,ConfigPath "\Clipboard.xml")
}
CommunicateWithRunningInstance()
{
	global
	local Count, x, y
	DetectHiddenWindows, On	
	FileRead, hwnd, %A_Temp%\7plus\hwnd.txt
	Loop %0%
	{
		SplitPath, 1,x,y
		if(strStartsWith(%A_Index%,"-id"))
		{
			if(WinExist("ahk_id " hwnd))
			{
				Parameter := SubStr(%A_Index%, 5) ;-ID:Value
				SendMessage, 55555, %Parameter%, 0, ,ahk_id %hwnd%
				ExitApp
			}
		}
		else if(strStartsWith(%A_Index%,"-ContextID"))
		{
			if(WinExist("ahk_id " hwnd))
			{
				Parameter := SubStr(%A_Index%, 12) ;-ContextID:Value
				SendMessage, 55555, %Parameter%, 1, ,ahk_id %hwnd%
				ExitApp
			}
		}
		else if(%A_Index% = "-Portable")
			IsPortable := true
		else if(y)
		{
			x = %1%
			SetDirectory(x)
			ExitApp
		}
	}
	if(WinExist("ahk_id " hwnd))
		ExitApp
	DetectHiddenWindows, Off
}