if(FileExist(A_ScriptDir "\Settings.ini"))
	IniPath := A_ScriptDir "\Settings.ini"
Else
	IniPath := A_AppData "\7plus\Settings.ini"
;Start debugger
IniRead, DebugEnabled, %IniPath%, General, DebugEnabled , 0
if(DebugEnabled)
	DebuggingStart()


;Update checker
IniRead, AutoUpdate, %IniPath%, Misc, AutoUpdate, 1
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
COM_Error(0)

;On first run, wizard is used to setup values
IniRead, FirstRun, %IniPath%, General, FirstRun , 1

IniRead, JoyControl, %IniPath%, Misc, JoyControl , 1
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
outputdebug hahk %hahk%
DllCall( "RegisterShellHookWindow", UInt,hAHK ) 
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ) 
OnMessage( MsgNum, "ShellMessage" ) 
;Tooltip messages
OnMessage(0x202,"WM_LBUTTONUP") ;Will make ToolTip Click possible 
OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
 
;Register an event hook to catch move and dialog creation messages
HookProcAdr := RegisterCallback("HookProc", "F" ) 
API_SetWinEventHook(0x8001,0x800B,0,HookProcAdr,0,0,0) ;Make sure not to register unneccessary messages, as this causes cpu load
DetectHiddenWindows, On

;FTP Upload script
IniRead, FTP_Enabled, %IniPath%, FTP, UseFTP , 1
IniRead, FTP_Username, %IniPath%, FTP, Username , Username
IniRead, FTP_Password, %IniPath%, FTP, EncryptedPassword,%A_Space%
if(FTP_Password = A_Space) ;Legacy for 1.0 settings files which have no ftp pw encryption
{	
	IniRead, FTP_Password, %IniPath%, FTP, Password , %A_Space%
	if(FTP_Password != A_Space)
		FTP_Password:=Encrypt(FTP_Password)
}
IniRead, FTP_Host, %IniPath%, FTP, Host , Host address
IniRead, FTP_PORT, %IniPath%, FTP, Port , 21
IniRead, FTP_URL, %IniPath%, FTP, URL , URL to webspace
IniRead, FTP_Path, %IniPath%, FTP, Path, %A_Space%

;strip slashes
ValidateFTPVars()

;Texteditor for opening files per hotkey
IniRead, TextEditor, %IniPath%, Explorer, TextEditor , `%windir`%\notepad.exe
IniRead, ImageEditor, %IniPath%, Explorer, ImageEditor , `%windir`%\system32\mspaint.exe

IniRead, HKCreateNewFile, %IniPath%, Explorer, HKCreateNewFile, 1
IniRead, HKCreateNewFolder, %IniPath%, Explorer, HKCreateNewFolder, 1
IniRead, HKCopyFilenames, %IniPath%, Explorer, HKCopyFilenames, 1
IniRead, HKCopyPaths, %IniPath%, Explorer, HKCopyPaths, 1
IniRead, HKAppendClipboard, %IniPath%, Explorer, HKAppendClipboard, 1

IniRead, HKFastFolders, %IniPath%, Explorer, HKFastFolders, 1
IniRead, HKFFMenu, %IniPath%, Explorer, HKFFMenu, 1
IniRead, HKPlacesBar, %IniPath%, Explorer, HKPlacesBar, 0
IniRead, HKCleanFolderBand, %IniPath%, Explorer, HKCleanFolderBand, 0
IniRead, HKFolderBand, %IniPath%, Explorer, HKFolderBand, 0

IniRead, HKProperBackspace, %IniPath%, Explorer, HKProperBackspace, 1
;IniRead, HKImprovedWinE, %IniPath%, Explorer, HKImprovedWinE, 1
IniRead, HKSelectFirstFile, %IniPath%, Explorer, HKSelectFirstFile, 1
IniRead, HKImproveEnter, %IniPath%, Explorer, HKImproveEnter, 1
IniRead, HKDoubleClickUpwards, %IniPath%, Explorer, HKDoubleClickUpwards, 1
IniRead, HKShowSpaceAndSize, %IniPath%, Explorer, HKShowSpaceAndSize, 1
IniRead, HKMouseGestures, %IniPath%, Explorer, HKMouseGestures, 1
IniRead, HKAutoCheck, %IniPath%, Explorer, HKAutoCheck, 1
IniRead, ScrollUnderMouse, %IniPath%, Explorer, ScrollUnderMouse, 1
IniRead, HKInvertSelection, %IniPath%, Explorer, HKInvertSelection, 1
IniRead, HKOpenInNewFolder, %IniPath%, Explorer, HKOpenInNewFolder, 1
IniRead, HKFlattenDirectory, %IniPath%, Explorer, HKFlattenDirectory, 1
IniRead, RecallExplorerPath, %IniPath%, Explorer, RecallExplorerPath, 1
IniRead, AlignExplorer, %IniPath%, Explorer, AlignExplorer, 1

IniRead, HKKillWindows, %IniPath%, Windows, HKKillWindows, 1
IniRead, HKToggleWallpaper, %IniPath%, Windows, HKToggleWallpaper, 1
IniRead, HKMiddleClose, %IniPath%, Windows, HKMiddleClose, 1
IniRead, HKTitleClose, %IniPath%, Windows, HKTitleClose, 1
IniRead, HKToggleAlwaysOnTop, %IniPath%, Windows, HKToggleAlwaysOnTop, 1
IniRead, HKActivateBehavior, %IniPath%, Windows, HKActivateBehavior, 1
IniRead, AeroFlipTime, %IniPath%, Windows, AeroFlipTime, 0.2
IniRead, HKFlashWindow, %IniPath%, Windows, HKFlashWindow, 1
IniRead, HKToggleWindows, %IniPath%, Windows, HKToggleWindows, 1
IniRead, HKAltDrag, %IniPath%, Windows, HKAltDrag, 1
IniRead, HKAltMinMax, %IniPath%, Windows, HKAltMinMax, 1
IniRead, HKTrayMin, %IniPath%, Windows, HKTrayMin, 1
IniRead, DoubleClickDesktop, %IniPath%, Windows, DoubleClickDesktop, %A_Windir%\explorer.exe

IniRead, HKHoverStart, %IniPath%, Windows, HKHoverStart, 1
;program to launch on double click on taskbar
IniRead, TaskbarLaunchPath, %IniPath%, Windows, TaskbarLaunchPath , %A_Windir%\system32\taskmgr.exe
stringreplace, TaskbarLaunchPath, TaskbarLaunchPath, `%A_ProgramFiles`%, %A_ProgramFiles% 
;Slide windows
IniRead, HKSlideWindows, %IniPath%, Windows, HKSlideWindows , 1
IniRead, SlideWinHide, %IniPath%, Windows, SlideWinHide , 1
SlideWindows_Startup()
IniRead, SlideWindowsBorder, %IniPath%, Windows, SlideWindowsBorder , 30
IniRead, HKImproveConsole, %IniPath%, Misc, HKImproveConsole, 1
IniRead, HKPhotoViewer, %IniPath%, Misc, HKPhotoViewer, 1
IniRead, ImageExtensions, %IniPath%, Misc, ImageExtensions, jpg,png,bmp,gif,tga,tif,ico,jpeg
IniRead, ClipboardManager, %IniPath%, Misc, ClipboardManager, 1
IniRead, WordDelete, %IniPath%, Misc, WordDelete, 1

;Fullscreen exclusion list
IniRead, FullscreenExclude, %IniPath%, Misc, FullscreenExclude,VLC DirectX,OpWindow,CabinetWClass
IniRead, FullscreenInclude, %IniPath%, Misc, FullscreenInclude,Project64
IniRead, ImageQuality, %IniPath%, Misc, ImageQuality,100
IniRead, ImageExtension, %IniPath%, Misc, ImageExtension,png

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
	IniRead, x, %IniPath%, Misc, Clipboard%A_Index%
	Transform, x, Deref, %x%
	if(x!="Error")
		ClipboardList.Append(x)
}
IniRead, FF0, %IniPath%, FastFolders, Folder0, ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
IniRead, FFTitle0, %IniPath%, FastFolders, FolderTitle0, Computer
IniRead, FF1, %IniPath%, FastFolders, Folder1, C:\
IniRead, FFTitle1, %IniPath%, FastFolders, FolderTitle1, C:\
;FastFolders
Loop 8
{
    z:=A_Index+1
    IniRead, FF%z%, %IniPath%, FastFolders, Folder%z%, %A_Space%
    IniRead, FFTitle%z%, %IniPath%, FastFolders, FolderTitle%z%, %A_Space%
}

if(A_OSVersion="WIN_7")
	CreateInfoGui()

IniRead, UseTabs, %IniPath%, Tabs, UseTabs, 1
IniRead, NewTabPosition, %IniPath%, Tabs, NewTabPosition, 1
IniRead, TabStartupPath, %IniPath%, Tabs, TabStartupPath, %A_SPACE%
IniRead, ActivateTab, %IniPath%, Tabs, ActivateTab, 1
IniRead, TabWindowClose, %IniPath%, Tabs, TabWindowClose, 1
IniRead, OnTabClose, %IniPath%, Tabs, OnTabClose, 1
IniRead, MiddleOpenFolder, %IniPath%, Tabs, MiddleOpenFolder, 1
TabContainerList := TabContainerList()
TabContainerList.Font := "Segoe UI"
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

ReadHotkeys()
SetTimer, ToggleHotkeys, 50

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
IniRead, HideTrayIcon, %IniPath%, Misc, HideTrayIcon, 0
if(!HidetrayIcon)
	menu, tray, Icon

;possibly start wizard
if (Firstrun=1)
	SetTimer, wizardry, -500
Return

ExitSub:
Gdip_Shutdown(pToken)
WriteIni()
SlideWindows_Exit()
TabContainerList.CloseAllInactiveTabs()
GoSub TrayminClose
ExitApp

;Some first run intro
wizardry:
ShowWizard()
return

ShowWizard()
{
	global IniPath
	MsgBox, 4,,Welcome to the ultimate windows tweaking experience!`nBefore we begin, would you like to see a list of features?	
	IfMsgBox Yes
		run http://code.google.com/p/7plus/wiki/Features
	MsgBox, 4,,At the beginning, you should configure the settings and activate/deactivate the features to your liking. You can access the settings menu later through the tray icon or by pressing WIN+H. Do you want to open the settings window now?
	IfMsgBox Yes
		ShowSettings()
	Tooltip(1, "That's it for now. Have fun!", "Everything Done!","O1 L1 P99 C1 XTrayIcon YTrayIcon I1")
	SetTimer, ToolTipClose, -5000	
	FirstRun:=0
	IniWrite, 0, %IniPath%, General, FirstRun
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
			if(tmpMajorVersion > MajorVersion)
				Update := true
			else if(tmpMajorVersion = MajorVersion && tmpMinorVersion > MinorVersion)
				Update := true
			else if(tmpMajorVersion = MajorVersion && tmpMinorVersion = MinorVersion && tmpBugfixVersion > BugfixVersion)
				Update := true
			else
				Update := false
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
	if(!FileExist(IniPath))
	{
		SplitPath, IniPath,, path
		FileCreateDir %path%
	}
	IniWrite, %DebugEnabled%, %IniPath%, General, DebugEnabled
	
	IniWrite, %FTP_Enabled%, %IniPath%, FTP, UseFTP
	IniWrite, %FTP_Username%, %IniPath%, FTP, Username
	IniWrite, %FTP_Password%, %IniPath%, FTP, EncryptedPassword
	IniWrite, %FTP_Host%, %IniPath%, FTP, Host
	IniWrite, %FTP_PORT%, %IniPath%, FTP, Port
	IniWrite, %FTP_URL%, %IniPath%, FTP, URL
	IniWrite, %FTP_Path%, %IniPath%, FTP, Path
	
	IniWrite, %ImgName%, %IniPath%, Explorer, Image
	IniWrite, %TxtName%, %IniPath%, Explorer, Text
	IniWrite, %TextEditor%, %IniPath%, Explorer, TextEditor
	IniWrite, %ImageEditor%, %IniPath%, Explorer, ImageEditor
	IniWrite, %HKCreateNewFile%, %IniPath%, Explorer, HKCreateNewFile
	IniWrite, %HKCreateNewFolder%, %IniPath%, Explorer, HKCreateNewFolder
	IniWrite, %HKCopyFilenames%, %IniPath%, Explorer, HKCopyFilenames
	IniWrite, %HKCopyPaths%, %IniPath%, Explorer, HKCopyPaths
	IniWrite, %HKAppendClipboard%, %IniPath%, Explorer, HKAppendClipboard
	
	IniWrite, %HKFastFolders%, %IniPath%, Explorer, HKFastFolders
	IniWrite, %HKFFMenu%, %IniPath%, Explorer, HKFFMenu
	IniWrite, %HKPlacesBar%, %IniPath%, Explorer, HKPlacesBar
	IniWrite, %HKCleanFolderBand%, %IniPath%, Explorer, HKCleanFolderBand
	IniWrite, %HKFolderBand%, %IniPath%, Explorer, HKFolderBand	
	
	IniWrite, %HKProperBackspace%, %IniPath%, Explorer, HKProperBackspace
	IniWrite, %HKSelectFirstFile%, %IniPath%, Explorer, HKSelectFirstFile
	IniWrite, %HKImproveEnter%, %IniPath%, Explorer, HKImproveEnter
	IniWrite, %HKDoubleClickUpwards%, %IniPath%, Explorer, HKDoubleClickUpwards
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
	
	IniWrite, %HKToggleAlwaysOnTop%, %IniPath%, Windows, HKToggleAlwaysOnTop
	IniWrite, %HKActivateBehavior%, %IniPath%, Windows, HKActivateBehavior
	IniWrite, %HKKillWindows%, %IniPath%, Windows, HKKillWindows
	IniWrite, %HKToggleWallpaper%, %IniPath%, Windows, HKToggleWallpaper
	IniWrite, %TaskbarLaunchPath%, %IniPath%, Windows, TaskbarLaunchPath
	IniWrite, %HKTitleClose%, %IniPath%, Windows, HKTitleClose
	IniWrite, %HKMiddleClose%, %IniPath%, Windows, HKMiddleClose
	IniWrite, %AeroFlipTime%, %IniPath%, Windows, AeroFlipTime
	IniWrite, %HKSlideWindows%, %IniPath%, Windows, HKSlideWindows
	IniWrite, %SlideWinHide%, %IniPath%, Windows, SlideWinHide
	IniWrite, %SlideWindowsBorder%, %IniPath%, Windows, SlideWindowsBorder
	IniWrite, %HKFlashWindow%, %IniPath%, Windows, HKFlashWindow
	IniWrite, %HKToggleWindows%, %IniPath%, Windows, HKToggleWindows
	IniWrite, %HKAltDrag%, %IniPath%, Windows, HKAltDrag
	IniWrite, %HKAltMinMax%, %IniPath%, Windows, HKAltMinMax
	IniWrite, %HKTrayMin%, %IniPath%, Windows, HKTrayMin
	IniWrite, %DoubleClickDesktop%, %IniPath%, Windows, DoubleClickDesktop
	
	IniWrite, %HKImproveConsole%, %IniPath%, Misc, HKImproveConsole
	IniWrite, %HKPhotoViewer%, %IniPath%, Misc, HKPhotoViewer
	IniWrite, %ImageExtensions%, %IniPath%, Misc, ImageExtensions
	IniWrite, %JoyControl%, %IniPath%, Misc, JoyControl
	IniWrite, %FullscreenExclude%, %IniPath%, Misc, FullscreenExclude
	IniWrite, %FullscreenInclude%, %IniPath%, Misc, FullscreenInclude
	IniWrite, %ClipboardManager%, %IniPath%, Misc, ClipboardManager
	IniWrite, %WordDelete%, %IniPath%, Misc, WordDelete
	IniWrite, %HideTrayIcon%, %IniPath%, Misc, HideTrayIcon
	IniWrite, %ImageQuality%, %IniPath%, Misc, ImageQuality
	IniWrite, %ImageExtension%, %IniPath%, Misc, ImageExtension
	IniWrite, %AutoUpdate%, %IniPath%, Misc, AutoUpdate
	;FastFolders
	Loop 10
	{
	    x:=A_Index-1
	    y:=FF%x%
	    z:=FFTitle%x%
	    IniWrite, %y%, %IniPath%, FastFolders, Folder%x%
	    IniWrite, %z%, %IniPath%, FastFolders, FolderTitle%x%
	}
	
	Loop 10
	{
		x:=ClipboardList[A_Index]
		x := RegExReplace(RegExReplace(RegExReplace(x, "``", "````"), "\r?\n", "``r``n"), "%", "``%")
		IniWrite, %x%, %IniPath%, Misc, Clipboard%A_Index%
	}
	SaveHotkeys()
}
