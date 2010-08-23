if(FileExist(A_ScriptDir "\Settings.ini"))
	ConfigPath := A_ScriptDir "\Settings.ini"
Else
	ConfigPath := A_AppData "\7plus\Settings.ini"
;Start debugger
IniRead, DebugEnabled, %ConfigPath%, General, DebugEnabled , 0
if(DebugEnabled)
	DebuggingStart()


;Update checker
IniRead, AutoUpdate, %ConfigPath%, Misc, AutoUpdate, 1
if(AutoUpdate)
	AutoUpdate()
PostUpdate()
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

CreateTabWindow()
;Get windows version
RegRead, vista7, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
vista7 := vista7 >= 6

;initialize gdi+
pToken := Gdip_Startup()

;Exit Routine
OnExit, ExitSub

;Disable COM error notifications that pop up sometimes when opening/closing explorer
COM_Init()
COM_Error(0)

;On first run, wizard is used to setup values
IniRead, FirstRun, %ConfigPath%, General, FirstRun , 1

IniRead, JoyControl, %ConfigPath%, Misc, JoyControl , 1
if(JoyControl)
	JoystickStart()

;Explorer pasting as file
IniRead, ImgName, %ConfigPath%, Explorer, Image, clip.png
IniRead, TxtName, %ConfigPath%, Explorer, Text, clip.txt
;the path where the image file is saved for copying
temp_img := A_Temp . "\" . ImgName
temp_txt := A_Temp . "\" . TxtName

CF_HDROP = 0xF ;clipboard identifier of copied file from explorer


;Register a shell hook to get messages when windows get activated, closed etc
Gui +LastFound
hAHK := WinExist()
outputdebug hahk %hahk%
DllCall( "RegisterShellHookWindow", UInt,hAHK ) 
ShellHookMsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ) 
OnMessage( ShellHookMsgNum, "ShellMessage" ) 
;Tooltip messages
OnMessage(0x202,"WM_LBUTTONUP") ;Will make ToolTip Click possible 
OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
 
;Register an event hook to catch move and dialog creation messages
HookProcAdr := RegisterCallback("HookProc", "F" ) 
API_SetWinEventHook(0x8001,0x800B,0,HookProcAdr,0,0,0) ;Make sure not to register unneccessary messages, as this causes cpu load
API_SetWinEventHook(0x0016,0x0016,0,HookProcAdr,0,0,0)
API_SetWinEventHook(0x000E,0x000E,0,HookProcAdr,0,0,0)
DetectHiddenWindows, On

/*
;FTP Upload
IniRead, FTP_Enabled, %ConfigPath%, FTP, UseFTP , 1
IniRead, FTP_Username, %ConfigPath%, FTP, Username , Username
IniRead, FTP_Password, %ConfigPath%, FTP, EncryptedPassword,%A_Space%
if(FTP_Password = A_Space) ;Legacy for 1.0 settings files which have no ftp pw encryption
{	
	IniRead, FTP_Password, %ConfigPath%, FTP, Password , %A_Space%
	if(FTP_Password != A_Space)
		FTP_Password:=Encrypt(FTP_Password)
}
IniRead, FTP_Host, %ConfigPath%, FTP, Host , Host address
IniRead, FTP_PORT, %ConfigPath%, FTP, Port , 21
IniRead, FTP_URL, %ConfigPath%, FTP, URL , URL to webspace
IniRead, FTP_Path, %ConfigPath%, FTP, Path, %A_Space%

;strip slashes
ValidateFTPVars()
*/

;Texteditor for opening files per hotkey
IniRead, TextEditor, %ConfigPath%, Explorer, TextEditor , `%windir`%\notepad.exe
IniRead, ImageEditor, %ConfigPath%, Explorer, ImageEditor , `%windir`%\system32\mspaint.exe

/*
IniRead, HKCreateNewFile, %ConfigPath%, Explorer, HKCreateNewFile, 1
IniRead, HKCreateNewFolder, %ConfigPath%, Explorer, HKCreateNewFolder, 1
IniRead, HKCopyFilenames, %ConfigPath%, Explorer, HKCopyFilenames, 1
IniRead, HKCopyPaths, %ConfigPath%, Explorer, HKCopyPaths, 1
IniRead, HKAppendClipboard, %ConfigPath%, Explorer, HKAppendClipboard, 1
*/

IniRead, HKFastFolders, %ConfigPath%, Explorer, HKFastFolders, 1
; IniRead, HKFFMenu, %ConfigPath%, Explorer, HKFFMenu, 1
IniRead, HKPlacesBar, %ConfigPath%, Explorer, HKPlacesBar, 0
IniRead, HKCleanFolderBand, %ConfigPath%, Explorer, HKCleanFolderBand, 0
IniRead, HKFolderBand, %ConfigPath%, Explorer, HKFolderBand, 0

/*
IniRead, HKProperBackspace, %ConfigPath%, Explorer, HKProperBackspace, 1
IniRead, HKDoubleClickUpwards, %ConfigPath%, Explorer, HKDoubleClickUpwards, 1
*/

;IniRead, HKImprovedWinE, %ConfigPath%, Explorer, HKImprovedWinE, 1
IniRead, HKSelectFirstFile, %ConfigPath%, Explorer, HKSelectFirstFile, 1
IniRead, HKImproveEnter, %ConfigPath%, Explorer, HKImproveEnter, 1
IniRead, HKShowSpaceAndSize, %ConfigPath%, Explorer, HKShowSpaceAndSize, 1
IniRead, HKMouseGestures, %ConfigPath%, Explorer, HKMouseGestures, 1
IniRead, HKAutoCheck, %ConfigPath%, Explorer, HKAutoCheck, 1
IniRead, ScrollUnderMouse, %ConfigPath%, Explorer, ScrollUnderMouse, 1
IniRead, HKInvertSelection, %ConfigPath%, Explorer, HKInvertSelection, 1
IniRead, HKOpenInNewFolder, %ConfigPath%, Explorer, HKOpenInNewFolder, 1
IniRead, HKFlattenDirectory, %ConfigPath%, Explorer, HKFlattenDirectory, 1
IniRead, RecallExplorerPath, %ConfigPath%, Explorer, RecallExplorerPath, 1
IniRead, AlignExplorer, %ConfigPath%, Explorer, AlignExplorer, 1

IniRead, HKMiddleClose, %ConfigPath%, Windows, HKMiddleClose, 1
/*
IniRead, HKKillWindows, %ConfigPath%, Windows, HKKillWindows, 1
IniRead, HKTitleClose, %ConfigPath%, Windows, HKTitleClose, 1
IniRead, HKToggleAlwaysOnTop, %ConfigPath%, Windows, HKToggleAlwaysOnTop, 1
IniRead, HKFlashWindow, %ConfigPath%, Windows, HKFlashWindow, 1
IniRead, HKToggleWindows, %ConfigPath%, Windows, HKToggleWindows, 1
*/
IniRead, HKActivateBehavior, %ConfigPath%, Windows, HKActivateBehavior, 1
IniRead, AeroFlipTime, %ConfigPath%, Windows, AeroFlipTime, 0.2
IniRead, HKAltDrag, %ConfigPath%, Windows, HKAltDrag, 1
/*
IniRead, HKAltMinMax, %ConfigPath%, Windows, HKAltMinMax, 1
IniRead, HKTrayMin, %ConfigPath%, Windows, HKTrayMin, 1
*/
IniRead, DoubleClickDesktop, %ConfigPath%, Windows, DoubleClickDesktop, %A_Windir%\explorer.exe
IniRead, HKToggleWallpaper, %ConfigPath%, Windows, HKToggleWallpaper, 1

IniRead, HKHoverStart, %ConfigPath%, Windows, HKHoverStart, 1
;program to launch on double click on taskbar
IniRead, TaskbarLaunchPath, %ConfigPath%, Windows, TaskbarLaunchPath , %A_Windir%\system32\taskmgr.exe
stringreplace, TaskbarLaunchPath, TaskbarLaunchPath, `%A_ProgramFiles`%, %A_ProgramFiles% 
;Slide windows
IniRead, HKSlideWindows, %ConfigPath%, Windows, HKSlideWindows , 1
IniRead, SlideWinHide, %ConfigPath%, Windows, SlideWinHide , 1
SlideWindows_Startup()
IniRead, SlideWindowsBorder, %ConfigPath%, Windows, SlideWindowsBorder , 30
/*
IniRead, HKImproveConsole, %ConfigPath%, Misc, HKImproveConsole, 1
IniRead, HKPhotoViewer, %ConfigPath%, Misc, HKPhotoViewer, 1
*/
IniRead, ImageExtensions, %ConfigPath%, Misc, ImageExtensions, jpg,png,bmp,gif,tga,tif,ico,jpeg
;IniRead, ClipboardManager, %ConfigPath%, Misc, ClipboardManager, 1
IniRead, WordDelete, %ConfigPath%, Misc, WordDelete, 1

;Fullscreen exclusion list
IniRead, FullscreenExclude, %ConfigPath%, Misc, FullscreenExclude,VLC DirectX,OpWindow,CabinetWClass
IniRead, FullscreenInclude, %ConfigPath%, Misc, FullscreenInclude,Project64
IniRead, ImageQuality, %ConfigPath%, Misc, ImageQuality,100
IniRead, ImageExtension, %ConfigPath%, Misc, ImageExtension,png
IniRead, PreviousExplorerPath, %ConfigPath%, Misc, PreviousExplorerPath,C:
IniRead, ExplorerPath, %ConfigPath%, Misc, ExplorerPath,C:

if((AeroFlipTime>=0&&Vista7)||HKSlideWindows)
{
	SetTimer, hovercheck, 10
}
;Clipboard manager list (is some sort of fixed size stack which removes oldest entry on add/insert/push)
Stack := Object("len", "Array_Length", "indexOf", "Array_indexOf", "join", "Array_Join" 
      , "append", "Array_Append", "insert", "Array_Insert", "delete", "Array_Delete" 
      , "sort", "Array_sort", "reverse", "Array_Reverse", "unique", "Array_Unique" 
      , "extend", "Array_Extend", "copy", "Array_Copy", "pop", "Array_Pop", "swap", "Array_Swap", "Move", "Array_Move" , "push", "Stack_Push") 

ClipboardList := Object("base", Stack) 
Loop 10
{
	IniRead, x, %ConfigPath%, Misc, Clipboard%A_Index%
	Transform, x, Deref, %x%
	if(x!="Error")
		ClipboardList.Append(x)
}
IniRead, FF0, %ConfigPath%, FastFolders, Folder0, ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
IniRead, FFTitle0, %ConfigPath%, FastFolders, FolderTitle0, Computer
IniRead, FF1, %ConfigPath%, FastFolders, Folder1, C:\
IniRead, FFTitle1, %ConfigPath%, FastFolders, FolderTitle1, C:\
;FastFolders
Loop 8
{
    z:=A_Index+1
    IniRead, FF%z%, %ConfigPath%, FastFolders, Folder%z%, %A_Space%
    IniRead, FFTitle%z%, %ConfigPath%, FastFolders, FolderTitle%z%, %A_Space%
}

if(A_OSVersion="WIN_7")
	CreateInfoGui()

IniRead, UseTabs, %ConfigPath%, Tabs, UseTabs, 1
IniRead, NewTabPosition, %ConfigPath%, Tabs, NewTabPosition, 1
IniRead, TabStartupPath, %ConfigPath%, Tabs, TabStartupPath, %A_SPACE%
IniRead, ActivateTab, %ConfigPath%, Tabs, ActivateTab, 1
IniRead, TabWindowClose, %ConfigPath%, Tabs, TabWindowClose, 1
IniRead, OnTabClose, %ConfigPath%, Tabs, OnTabClose, 1
IniRead, MiddleOpenFolder, %ConfigPath%, Tabs, MiddleOpenFolder, 1
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
	
GoSub TrayminOpen

/*ReadHotkeys()
SetTimer, ToggleHotkeys, 50
*/
;Show tray icon when loading is complete
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Settings, SettingsHandler  ; Creates a new menu item.

result:=DllCall("uxtheme.dll\IsThemeActive") ; On non-themed environments, standard icon is used
if(A_IsCompiled)
{
	if(result)
		Menu, tray, Icon, %A_ScriptFullPath%, 2,1
	else
		Menu, tray, Icon, %A_ScriptFullPath%, 1,1
}	
else
{
	if(result)
		Menu, tray, Icon, %A_ScriptDir%\7+-w2.ico,,1
	else
		Menu, tray, Icon, %A_ScriptDir%\7+-w.ico,,1
}
menu, tray, Default, Settings
IniRead, HideTrayIcon, %ConfigPath%, Misc, HideTrayIcon, 0
if(!HidetrayIcon)
	menu, tray, Icon

;possibly start wizard
if (Firstrun=1)
	SetTimer, wizardry, -500


	
SetTimer, TriggerTimer, 1000
; SetTimer, AssignHotkeys, -10000

; Hotkey, If, !IsFullScreen()
; Hotkey, MButton, MButton, On
; Hotkey, If
;put it at the end because this will be the main loop of the program
EventSystem_Startup()
Return

ExitSub:
OnExit()
ExitApp

OnExit(Reload=0)
{
	static ShouldReload
	if(ShouldReload) ;If set, code below has already been executed by a previous call to this function
		return
	EventSystem_End()
	Gdip_Shutdown(pToken)
	WriteIni()
	SlideWindows_Exit()
	TabContainerList.CloseAllInactiveTabs()
	GoSub TrayminClose	
	if(Reload)
	{
		ShouldReload := 1
		reload
	}
}
;Some first run intro
wizardry:
ShowWizard()
return

ShowWizard()
{
	global ConfigPath
	MsgBox, 4,,Welcome to the ultimate windows tweaking experience!`nBefore we begin, would you like to see a list of features?	
	IfMsgBox Yes
		run http://code.google.com/p/7plus/wiki/Features
	MsgBox, 4,,At the beginning, you should configure the settings and activate/deactivate the features to your liking. You can access the settings menu later through the tray icon or by pressing WIN+H. Do you want to open the settings window now?
	IfMsgBox Yes
		ShowSettings()
	Tooltip(1, "That's it for now. Have fun!", "Everything Done!","O1 L1 P99 C1 XTrayIcon YTrayIcon I1")
	SetTimer, ToolTipClose, -5000	
	FirstRun:=0
	IniWrite, 0, %ConfigPath%, General, FirstRun
	return
}
AutoUpdate()
{	
	global MajorVersion,MinorVersion,BugfixVersion
	if(IsConnected())
	{
		random, rand
		URLDownloadToFile, http://7plus.googlecode.com/files/NewVersion.ini?x=%rand%, %A_ScriptDir%\Version.ini
		if(!Errorlevel)
		{
			IniRead, tmpMajorVersion, %A_ScriptDir%\Version.ini, Version,MajorVersion
			IniRead, tmpMinorVersion, %A_ScriptDir%\Version.ini, Version,MinorVersion
			IniRead, tmpBugfixVersion, %A_ScriptDir%\Version.ini, Version,BugfixVersion
			Update := (CompareVersion(tmpMajorVersion, MajorVersion, tmpMinorVersion, MinorVersion, tmpBugfixVersion, BugfixVersion) = 1)
			if(Update)
			{
				IniRead, UpdateMessage, %A_ScriptDir%\Version.ini, Version,UpdateMessage
				MsgBox,4,,%UpdateMessage%
				IfMsgBox Yes
				{
					Progress zh0 fs18,Downloading Update, please wait.
					Sleep 10
					if(A_IsCompiled)
						IniRead, Link, %A_ScriptDir%\Version.ini, Version,Link
					else
						IniRead, Link, %A_ScriptDir%\Version.ini, Version,LinkSource
					URLDownloadToFile, %link%?x=%rand%,%A_ScriptDir%\Updater.exe
					if(!Errorlevel)
					{
						Run %A_ScriptDir%\Updater.exe
						ExitApp
					}
					else
					{
						MsgBox Error while updating. Make sure http://7plus.googlecode.com is reachable.
						Progress, Off
					}
				}
			}
		}
		else
			MsgBox Could not download version info. Make sure http://7plus.googlecode.com is reachable.
	}
}
PostUpdate()
{
	global MajorVersion,MinorVersion,BugfixVersion
	if(FileExist(A_ScriptDir "\Updater.exe"))
	{
		IniRead, MajorVersion, %A_ScriptDir%\Version.ini,Version,MajorVersion
		IniRead, MinorVersion, %A_ScriptDir%\Version.ini,Version,MinorVersion
		IniRead, BugfixVersion, %A_ScriptDir%\Version.ini,Version,BugfixVersion
		if(MajorVersion=MajorVersion && MinorVersion = MinorVersion && BugfixVersion = BugfixVersion)
		{
			if(FileExist(A_ScriptDir "\Changelog.txt"))
			{
				MsgBox,4,, Update successful. View Changelog?
				IfMsgBox Yes
					run %A_ScriptDir%\Changelog.txt
			}
		}		
		FileDelete %A_ScriptDir%\Updater.exe
	}
	FileDelete %A_ScriptDir%\Version.ini
}
WriteIni()
{
	global
	local temp,x,y,z
	if(!FileExist(ConfigPath))
	{
		SplitPath, ConfigPath,, path
		FileCreateDir %path%
	}
	IniWrite, %DebugEnabled%, %ConfigPath%, General, DebugEnabled
	/*
	IniWrite, %FTP_Enabled%, %ConfigPath%, FTP, UseFTP
	IniWrite, %FTP_Username%, %ConfigPath%, FTP, Username
	IniWrite, %FTP_Password%, %ConfigPath%, FTP, EncryptedPassword
	IniWrite, %FTP_Host%, %ConfigPath%, FTP, Host
	IniWrite, %FTP_PORT%, %ConfigPath%, FTP, Port
	IniWrite, %FTP_URL%, %ConfigPath%, FTP, URL
	IniWrite, %FTP_Path%, %ConfigPath%, FTP, Path
	*/
	IniWrite, %ImgName%, %ConfigPath%, Explorer, Image
	IniWrite, %TxtName%, %ConfigPath%, Explorer, Text
	IniWrite, %TextEditor%, %ConfigPath%, Explorer, TextEditor
	IniWrite, %ImageEditor%, %ConfigPath%, Explorer, ImageEditor
	/*
	IniWrite, %HKCreateNewFile%, %ConfigPath%, Explorer, HKCreateNewFile
	IniWrite, %HKCreateNewFolder%, %ConfigPath%, Explorer, HKCreateNewFolder
	IniWrite, %HKCopyFilenames%, %ConfigPath%, Explorer, HKCopyFilenames
	IniWrite, %HKCopyPaths%, %ConfigPath%, Explorer, HKCopyPaths
	IniWrite, %HKAppendClipboard%, %ConfigPath%, Explorer, HKAppendClipboard
	*/
	IniWrite, %HKFastFolders%, %ConfigPath%, Explorer, HKFastFolders
	; IniWrite, %HKFFMenu%, %ConfigPath%, Explorer, HKFFMenu
	IniWrite, %HKPlacesBar%, %ConfigPath%, Explorer, HKPlacesBar
	IniWrite, %HKCleanFolderBand%, %ConfigPath%, Explorer, HKCleanFolderBand
	IniWrite, %HKFolderBand%, %ConfigPath%, Explorer, HKFolderBand	
	
	; IniWrite, %HKProperBackspace%, %ConfigPath%, Explorer, HKProperBackspace
	IniWrite, %HKSelectFirstFile%, %ConfigPath%, Explorer, HKSelectFirstFile
	IniWrite, %HKImproveEnter%, %ConfigPath%, Explorer, HKImproveEnter
	; IniWrite, %HKDoubleClickUpwards%, %ConfigPath%, Explorer, HKDoubleClickUpwards
	IniWrite, %HKShowSpaceAndSize%, %ConfigPath%, Explorer, HKShowSpaceAndSize
	IniWrite, %HKMouseGestures%, %ConfigPath%, Explorer, HKMouseGestures
	IniWrite, %HKAutoCheck%, %ConfigPath%, Explorer, HKAutoCheck
	IniWrite, %ScrollUnderMouse%, %ConfigPath%, Explorer, ScrollUnderMouse
	IniWrite, %HKInvertSelection%, %ConfigPath%, Explorer, HKInvertSelection
	IniWrite, %HKOpenInNewFolder%, %ConfigPath%, Explorer, HKOpenInNewFolder
	IniWrite, %HKFlattenDirectory%, %ConfigPath%, Explorer, HKFlattenDirectory
	IniWrite, %RecallExplorerPath%, %ConfigPath%, Explorer, RecallExplorerPath
	IniWrite, %AlignExplorer%, %ConfigPath%, Explorer, AlignExplorer
	
	IniWrite, %UseTabs%, %ConfigPath%, Tabs, UseTabs
	IniWrite, %NewTabPosition%, %ConfigPath%, Tabs, NewTabPosition
	IniWrite, %TabStartupPath%, %ConfigPath%, Tabs, TabStartupPath
	IniWrite, %ActivateTab%, %ConfigPath%, Tabs, ActivateTab
	IniWrite, %TabWindowClose%, %ConfigPath%, Tabs, TabWindowClose
	IniWrite, %OnTabClose%, %ConfigPath%, Tabs, OnTabClose
	IniWrite, %MiddleOpenFolder%, %ConfigPath%, Tabs, MiddleOpenFolder
	
	; IniWrite, %HKToggleAlwaysOnTop%, %ConfigPath%, Windows, HKToggleAlwaysOnTop
	IniWrite, %HKActivateBehavior%, %ConfigPath%, Windows, HKActivateBehavior
	; IniWrite, %HKKillWindows%, %ConfigPath%, Windows, HKKillWindows
	IniWrite, %HKToggleWallpaper%, %ConfigPath%, Windows, HKToggleWallpaper
	IniWrite, %TaskbarLaunchPath%, %ConfigPath%, Windows, TaskbarLaunchPath
	; IniWrite, %HKTitleClose%, %ConfigPath%, Windows, HKTitleClose
	IniWrite, %HKMiddleClose%, %ConfigPath%, Windows, HKMiddleClose
	IniWrite, %AeroFlipTime%, %ConfigPath%, Windows, AeroFlipTime
	IniWrite, %HKSlideWindows%, %ConfigPath%, Windows, HKSlideWindows
	IniWrite, %SlideWinHide%, %ConfigPath%, Windows, SlideWinHide
	IniWrite, %SlideWindowsBorder%, %ConfigPath%, Windows, SlideWindowsBorder
	; IniWrite, %HKFlashWindow%, %ConfigPath%, Windows, HKFlashWindow
	; IniWrite, %HKToggleWindows%, %ConfigPath%, Windows, HKToggleWindows
	IniWrite, %HKAltDrag%, %ConfigPath%, Windows, HKAltDrag
	; IniWrite, %HKAltMinMax%, %ConfigPath%, Windows, HKAltMinMax
	; IniWrite, %HKTrayMin%, %ConfigPath%, Windows, HKTrayMin
	IniWrite, %DoubleClickDesktop%, %ConfigPath%, Windows, DoubleClickDesktop
	
	; IniWrite, %HKImproveConsole%, %ConfigPath%, Misc, HKImproveConsole
	; IniWrite, %HKPhotoViewer%, %ConfigPath%, Misc, HKPhotoViewer
	IniWrite, %ImageExtensions%, %ConfigPath%, Misc, ImageExtensions
	IniWrite, %JoyControl%, %ConfigPath%, Misc, JoyControl
	IniWrite, %FullscreenExclude%, %ConfigPath%, Misc, FullscreenExclude
	IniWrite, %FullscreenInclude%, %ConfigPath%, Misc, FullscreenInclude
	; IniWrite, %ClipboardManager%, %ConfigPath%, Misc, ClipboardManager
	IniWrite, %WordDelete%, %ConfigPath%, Misc, WordDelete
	IniWrite, %HideTrayIcon%, %ConfigPath%, Misc, HideTrayIcon
	IniWrite, %ImageQuality%, %ConfigPath%, Misc, ImageQuality
	IniWrite, %ImageExtension%, %ConfigPath%, Misc, ImageExtension
	IniWrite, %AutoUpdate%, %ConfigPath%, Misc, AutoUpdate
	IniWrite, %ExplorerPath%, %ConfigPath%, Misc, ExplorerPath
	IniWrite, %PreviousExplorerPath%, %ConfigPath%, Misc, PreviousExplorerPath
	
	;FastFolders
	Loop 10
	{
	    x:=A_Index-1
	    y:=FF%x%
	    z:=FFTitle%x%
	    IniWrite, %y%, %ConfigPath%, FastFolders, Folder%x%
	    IniWrite, %z%, %ConfigPath%, FastFolders, FolderTitle%x%
	}
	
	Loop 10
	{
		x:=ClipboardList[A_Index]
		x := RegExReplace(RegExReplace(RegExReplace(x, "``", "````"), "\r?\n", "``r``n"), "%", "``%")
		IniWrite, %x%, %ConfigPath%, Misc, Clipboard%A_Index%
	}
	; SaveHotkeys()
}
