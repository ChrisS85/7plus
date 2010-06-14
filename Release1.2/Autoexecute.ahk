;Start debugger
IniRead, DebugEnabled, %A_ScriptDir%\Settings.ini, General, DebugEnabled , 0
if(DebugEnabled)
	DebuggingStart()

;Settings version (required for added ftp password encryption)
IniRead, SettingsVersion, %A_ScriptDir%\Settings.ini, General, SettingsVersion, 1.0
;Update checker
IniRead, AutoUpdate, %A_ScriptDir%\Settings.ini, Misc, AutoUpdate, 1
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
IniRead, FirstRun, %A_ScriptDir%\Settings.ini, General, FirstRun , 1

IniRead, JoyControl, %A_ScriptDir%\Settings.ini, Misc, JoyControl , 1
if(JoyControl)
	JoystickStart()

;Explorer pasting as file
IniRead, ImgName, %A_ScriptDir%\Settings.ini, Explorer, Image, clip.png
IniRead, TxtName, %A_ScriptDir%\Settings.ini, Explorer, Text, clip.txt
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
IniRead, FTP_Enabled, %A_ScriptDir%\Settings.ini, FTP, UseFTP , 1
IniRead, FTP_Username, %A_ScriptDir%\Settings.ini, FTP, Username , Username
IniRead, FTP_Password, %A_ScriptDir%\Settings.ini, FTP, Password , Password
if(SettingsVersion="1.0") ;Legacy for 1.0 settings files which have no ftp pw encryption
	FTP_Password:=Encrypt(FTP_Password)
IniRead, FTP_Host, %A_ScriptDir%\Settings.ini, FTP, Host , Host address
IniRead, FTP_PORT, %A_ScriptDir%\Settings.ini, FTP, Port , 21
IniRead, FTP_URL, %A_ScriptDir%\Settings.ini, FTP, URL , URL to webspace
IniRead, FTP_Path, %A_ScriptDir%\Settings.ini, FTP, Path, %A_Space%

;strip slashes
ValidateFTPVars()

;Texteditor for opening files per hotkey
IniRead, TextEditor, %A_ScriptDir%\Settings.ini, Explorer, TextEditor , `%windir`%\notepad.exe
IniRead, ImageEditor, %A_ScriptDir%\Settings.ini, Explorer, ImageEditor , `%windir`%\system32\mspaint.exe

IniRead, HKCreateNewFile, %A_ScriptDir%\Settings.ini, Explorer, HKCreateNewFile, 1
IniRead, HKCreateNewFolder, %A_ScriptDir%\Settings.ini, Explorer, HKCreateNewFolder, 1
IniRead, HKCopyFilenames, %A_ScriptDir%\Settings.ini, Explorer, HKCopyFilenames, 1
IniRead, HKCopyPaths, %A_ScriptDir%\Settings.ini, Explorer, HKCopyPaths, 1
IniRead, HKAppendClipboard, %A_ScriptDir%\Settings.ini, Explorer, HKAppendClipboard, 1

IniRead, HKFastFolders, %A_ScriptDir%\Settings.ini, Explorer, HKFastFolders, 1
IniRead, HKFFMenu, %A_ScriptDir%\Settings.ini, Explorer, HKFFMenu, 1
IniRead, HKPlacesBar, %A_ScriptDir%\Settings.ini, Explorer, HKPlacesBar, 0
IniRead, HKCleanFolderBand, %A_ScriptDir%\Settings.ini, Explorer, HKCleanFolderBand, 0
IniRead, HKFolderBand, %A_ScriptDir%\Settings.ini, Explorer, HKFolderBand, 0

IniRead, HKProperBackspace, %A_ScriptDir%\Settings.ini, Explorer, HKProperBackspace, 1
;IniRead, HKImprovedWinE, %A_ScriptDir%\Settings.ini, Explorer, HKImprovedWinE, 1
IniRead, HKSelectFirstFile, %A_ScriptDir%\Settings.ini, Explorer, HKSelectFirstFile, 1
IniRead, HKImproveEnter, %A_ScriptDir%\Settings.ini, Explorer, HKImproveEnter, 1
IniRead, HKDoubleClickUpwards, %A_ScriptDir%\Settings.ini, Explorer, HKDoubleClickUpwards, 1
IniRead, HKShowSpaceAndSize, %A_ScriptDir%\Settings.ini, Explorer, HKShowSpaceAndSize, 1
IniRead, HKMouseGestures, %A_ScriptDir%\Settings.ini, Explorer, HKMouseGestures, 1
IniRead, HKAutoCheck, %A_ScriptDir%\Settings.ini, Explorer, HKAutoCheck, 1
IniRead, ScrollUnderMouse, %A_ScriptDir%\Settings.ini, Explorer, ScrollUnderMouse, 1
IniRead, HKInvertSelection, %A_ScriptDir%\Settings.ini, Explorer, HKInvertSelection, 1
IniRead, HKOpenInNewFolder, %A_ScriptDir%\Settings.ini, Explorer, HKOpenInNewFolder, 1
IniRead, HKFlattenDirectory, %A_ScriptDir%\Settings.ini, Explorer, HKFlattenDirectory, 1
IniRead, RecallExplorerPath, %A_ScriptDir%\Settings.ini, Explorer, RecallExplorerPath, 1
IniRead, AlignExplorer, %A_ScriptDir%\Settings.ini, Explorer, AlignExplorer, 1

IniRead, HKKillWindows, %A_ScriptDir%\Settings.ini, Windows, HKKillWindows, 1
IniRead, HKToggleWallpaper, %A_ScriptDir%\Settings.ini, Windows, HKToggleWallpaper, 1
IniRead, HKMiddleClose, %A_ScriptDir%\Settings.ini, Windows, HKMiddleClose, 1
IniRead, HKTitleClose, %A_ScriptDir%\Settings.ini, Windows, HKTitleClose, 1
IniRead, HKToggleAlwaysOnTop, %A_ScriptDir%\Settings.ini, Windows, HKToggleAlwaysOnTop, 1
IniRead, HKActivateBehavior, %A_ScriptDir%\Settings.ini, Windows, HKActivateBehavior, 1
IniRead, AeroFlipTime, %A_ScriptDir%\Settings.ini, Windows, AeroFlipTime, 0.2
IniRead, HKFlashWindow, %A_ScriptDir%\Settings.ini, Windows, HKFlashWindow, 1
IniRead, HKToggleWindows, %A_ScriptDir%\Settings.ini, Windows, HKToggleWindows, 1
IniRead, HKAltDrag, %A_ScriptDir%\Settings.ini, Windows, HKAltDrag, 1
IniRead, HKAltMinMax, %A_ScriptDir%\Settings.ini, Windows, HKAltMinMax, 1
IniRead, HKTrayMin, %A_ScriptDir%\Settings.ini, Windows, HKTrayMin, 1
IniRead, DoubleClickDesktop, %A_ScriptDir%\Settings.ini, Windows, DoubleClickDesktop, %A_Windir%\explorer.exe

IniRead, HKHoverStart, %A_ScriptDir%\Settings.ini, Windows, HKHoverStart, 1
;program to launch on double click on taskbar
IniRead, TaskbarLaunchPath, %A_ScriptDir%\Settings.ini, Windows, TaskbarLaunchPath , %A_Windir%\system32\taskmgr.exe
stringreplace, TaskbarLaunchPath, TaskbarLaunchPath, `%A_ProgramFiles`%, %A_ProgramFiles% 
;Slide windows
IniRead, HKSlideWindows, %A_ScriptDir%\Settings.ini, Windows, HKSlideWindows , 1
IniRead, SlideWinHide, %A_ScriptDir%\Settings.ini, Windows, SlideWinHide , 1
SlideWindows_Startup()
IniRead, SlideWindowsBorder, %A_ScriptDir%\Settings.ini, Windows, SlideWindowsBorder , 30
IniRead, HKImproveConsole, %A_ScriptDir%\Settings.ini, Misc, HKImproveConsole, 1
IniRead, HKPhotoViewer, %A_ScriptDir%\Settings.ini, Misc, HKPhotoViewer, 1
IniRead, ImageExtensions, %A_ScriptDir%\Settings.ini, Misc, ImageExtensions, jpg,png,bmp,gif,tga,tif,ico,jpeg
IniRead, ClipboardManager, %A_ScriptDir%\Settings.ini, Misc, ClipboardManager, 1
IniRead, WordDelete, %A_ScriptDir%\Settings.ini, Misc, WordDelete, 1

;Fullscreen exclusion list
IniRead, FullscreenExclude, %A_ScriptDir%\Settings.ini, Misc, FullscreenExclude,VLC DirectX,OpWindow,CabinetWClass
IniRead, FullscreenInclude, %A_ScriptDir%\Settings.ini, Misc, FullscreenInclude,Project64
IniRead, ImageQuality, %A_ScriptDir%\Settings.ini, Misc, ImageQuality,100
IniRead, ImageExtension, %A_ScriptDir%\Settings.ini, Misc, ImageExtension,png

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
	IniRead, x, %A_ScriptDir%\Settings.ini, Misc, Clipboard%A_Index%
	Transform, x, Deref, %x%
	if(x!="Error")
		ClipboardList.Append(x)
}
IniRead, FF0, %A_ScriptDir%\Settings.ini, FastFolders, Folder0, ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
IniRead, FFTitle0, %A_ScriptDir%\Settings.ini, FastFolders, FolderTitle0, Computer
IniRead, FF1, %A_ScriptDir%\Settings.ini, FastFolders, Folder1, C:\
IniRead, FFTitle1, %A_ScriptDir%\Settings.ini, FastFolders, FolderTitle1, C:\
;FastFolders
Loop 8
{
    z:=A_Index+1
    IniRead, FF%z%, %A_ScriptDir%\Settings.ini, FastFolders, Folder%z%, %A_Space%
    IniRead, FFTitle%z%, %A_ScriptDir%\Settings.ini, FastFolders, FolderTitle%z%, %A_Space%
}

if(A_OSVersion="WIN_7")
	CreateInfoGui()

IniRead, UseTabs, %A_ScriptDir%\Settings.ini, Tabs, UseTabs, 1
IniRead, NewTabPosition, %A_ScriptDir%\Settings.ini, Tabs, NewTabPosition, 1
IniRead, TabStartupPath, %A_ScriptDir%\Settings.ini, Tabs, TabStartupPath, %A_SPACE%
IniRead, ActivateTab, %A_ScriptDir%\Settings.ini, Tabs, ActivateTab, 1
IniRead, TabWindowClose, %A_ScriptDir%\Settings.ini, Tabs, TabWindowClose, 1
IniRead, OnTabClose, %A_ScriptDir%\Settings.ini, Tabs, OnTabClose, 1
IniRead, MiddleOpenFolder, %A_ScriptDir%\Settings.ini, Tabs, MiddleOpenFolder, 1
TabContainerList := TabContainerList()

if(Vista7)
	AcquireExplorerConfirmationDialogStrings()
	
GoSub TrayminOpen

ReadHotkeys()
SetTimer, ToggleHotkeys, 50

CreateTabWindow()
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
IniRead, HideTrayIcon, %A_ScriptDir%\Settings.ini, Misc, HideTrayIcon, 0
if(!HidetrayIcon)
	menu, tray, Icon

;possibly start wizard
if (Firstrun=1)
	GoSub wizardry
if (Firstrun=1)
{
	Tooltip(1, "That's it for now. Have fun!", "Everything Done!","O1 L1 P99 C1 XTrayIcon YTrayIcon I1")
	SetTimer, ToolTipClose, -5000	
	FirstRun:=0
	IniWrite, 0, %A_ScriptDir%\Settings.ini, General, FirstRun
}
Return

ExitSub:
Gdip_Shutdown(pToken)
WriteIni()
SlideWindows_Exit()
TabContainerList.CloseAllInactiveTabs()
GoSub TrayminClose
ExitApp

AutoUpdate()
{	
	global CurrentVersion
	if(IsConnected())
	{
		random, rand
		URLDownloadToFile, http://7plus.googlecode.com/files/Version.ini?x=%rand%, %A_ScriptDir%\Version.ini
		if(!Errorlevel)
		{
			IniRead, Version, %A_ScriptDir%\Version.ini, Version,Version
			if(Version>CurrentVersion)
			{
				MsgBox,4,,A new update is available. Download now?
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
	global CurrentVersion
	if(FileExist(A_ScriptDir "\Updater.exe"))
	{
		IniRead, Version, %A_ScriptDir%\Version.ini,Version,Version
		if(CurrentVersion=Version)
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
	local temp
	IniWrite, %DebugEnabled%, %A_ScriptDir%\Settings.ini, General, DebugEnabled
	IniWrite, %CurrentVersion%, %A_ScriptDir%\Settings.ini, General, SettingsVersion
	
	IniWrite, %FTP_Enabled%, %A_ScriptDir%\Settings.ini, FTP, UseFTP
	IniWrite, %FTP_Username%, %A_ScriptDir%\Settings.ini, FTP, Username
	IniWrite, %FTP_Password%, %A_ScriptDir%\Settings.ini, FTP, Password
	IniWrite, %FTP_Host%, %A_ScriptDir%\Settings.ini, FTP, Host
	IniWrite, %FTP_PORT%, %A_ScriptDir%\Settings.ini, FTP, Port
	IniWrite, %FTP_URL%, %A_ScriptDir%\Settings.ini, FTP, URL
	IniWrite, %FTP_Path%, %A_ScriptDir%\Settings.ini, FTP, Path
	
	IniWrite, %ImgName%, %A_ScriptDir%\Settings.ini, Explorer, Image
	IniWrite, %TxtName%, %A_ScriptDir%\Settings.ini, Explorer, Text
	IniWrite, %TextEditor%, %A_ScriptDir%\Settings.ini, Explorer, TextEditor
	IniWrite, %ImageEditor%, %A_ScriptDir%\Settings.ini, Explorer, ImageEditor
	IniWrite, %HKCreateNewFile%, %A_ScriptDir%\Settings.ini, Explorer, HKCreateNewFile
	IniWrite, %HKCreateNewFolder%, %A_ScriptDir%\Settings.ini, Explorer, HKCreateNewFolder
	IniWrite, %HKCopyFilenames%, %A_ScriptDir%\Settings.ini, Explorer, HKCopyFilenames
	IniWrite, %HKCopyPaths%, %A_ScriptDir%\Settings.ini, Explorer, HKCopyPaths
	IniWrite, %HKAppendClipboard%, %A_ScriptDir%\Settings.ini, Explorer, HKAppendClipboard
	
	IniWrite, %HKFastFolders%, %A_ScriptDir%\Settings.ini, Explorer, HKFastFolders
	IniWrite, %HKFFMenu%, %A_ScriptDir%\Settings.ini, Explorer, HKFFMenu
	IniWrite, %HKPlacesBar%, %A_ScriptDir%\Settings.ini, Explorer, HKPlacesBar
	IniWrite, %HKCleanFolderBand%, %A_ScriptDir%\Settings.ini, Explorer, HKCleanFolderBand
	IniWrite, %HKFolderBand%, %A_ScriptDir%\Settings.ini, Explorer, HKFolderBand	
	
	IniWrite, %HKProperBackspace%, %A_ScriptDir%\Settings.ini, Explorer, HKProperBackspace
	IniWrite, %HKSelectFirstFile%, %A_ScriptDir%\Settings.ini, Explorer, HKSelectFirstFile
	IniWrite, %HKImproveEnter%, %A_ScriptDir%\Settings.ini, Explorer, HKImproveEnter
	IniWrite, %HKDoubleClickUpwards%, %A_ScriptDir%\Settings.ini, Explorer, HKDoubleClickUpwards
	IniWrite, %HKShowSpaceAndSize%, %A_ScriptDir%\Settings.ini, Explorer, HKShowSpaceAndSize
	IniWrite, %HKMouseGestures%, %A_ScriptDir%\Settings.ini, Explorer, HKMouseGestures
	IniWrite, %HKAutoCheck%, %A_ScriptDir%\Settings.ini, Explorer, HKAutoCheck
	IniWrite, %ScrollUnderMouse%, %A_ScriptDir%\Settings.ini, Explorer, ScrollUnderMouse
	IniWrite, %HKInvertSelection%, %A_ScriptDir%\Settings.ini, Explorer, HKInvertSelection
	IniWrite, %HKOpenInNewFolder%, %A_ScriptDir%\Settings.ini, Explorer, HKOpenInNewFolder
	IniWrite, %HKFlattenDirectory%, %A_ScriptDir%\Settings.ini, Explorer, HKFlattenDirectory
	IniWrite, %RecallExplorerPath%, %A_ScriptDir%\Settings.ini, Explorer, RecallExplorerPath
	IniWrite, %AlignExplorer%, %A_ScriptDir%\Settings.ini, Explorer, AlignExplorer
	
	IniWrite, %UseTabs%, %A_ScriptDir%\Settings.ini, Tabs, UseTabs
	IniWrite, %NewTabPosition%, %A_ScriptDir%\Settings.ini, Tabs, NewTabPosition
	IniWrite, %TabStartupPath%, %A_ScriptDir%\Settings.ini, Tabs, TabStartupPath
	IniWrite, %ActivateTab%, %A_ScriptDir%\Settings.ini, Tabs, ActivateTab
	IniWrite, %TabWindowClose%, %A_ScriptDir%\Settings.ini, Tabs, TabWindowClose
	IniWrite, %OnTabClose%, %A_ScriptDir%\Settings.ini, Tabs, OnTabClose
	IniWrite, %MiddleOpenFolder%, %A_ScriptDir%\Settings.ini, Tabs, MiddleOpenFolder
	
	IniWrite, %HKToggleAlwaysOnTop%, %A_ScriptDir%\Settings.ini, Windows, HKToggleAlwaysOnTop
	IniWrite, %HKActivateBehavior%, %A_ScriptDir%\Settings.ini, Windows, HKActivateBehavior
	IniWrite, %HKKillWindows%, %A_ScriptDir%\Settings.ini, Windows, HKKillWindows
	IniWrite, %HKToggleWallpaper%, %A_ScriptDir%\Settings.ini, Windows, HKToggleWallpaper
	IniWrite, %TaskbarLaunchPath%, %A_ScriptDir%\Settings.ini, Windows, TaskbarLaunchPath
	IniWrite, %HKTitleClose%, %A_ScriptDir%\Settings.ini, Windows, HKTitleClose
	IniWrite, %HKMiddleClose%, %A_ScriptDir%\Settings.ini, Windows, HKMiddleClose
	IniWrite, %AeroFlipTime%, %A_ScriptDir%\Settings.ini, Windows, AeroFlipTime
	IniWrite, %HKSlideWindows%, %A_ScriptDir%\Settings.ini, Windows, HKSlideWindows
	IniWrite, %SlideWinHide%, %A_ScriptDir%\Settings.ini, Windows, SlideWinHide
	IniWrite, %SlideWindowsBorder%, %A_ScriptDir%\Settings.ini, Windows, SlideWindowsBorder
	IniWrite, %HKFlashWindow%, %A_ScriptDir%\Settings.ini, Windows, HKFlashWindow
	IniWrite, %HKToggleWindows%, %A_ScriptDir%\Settings.ini, Windows, HKToggleWindows
	IniWrite, %HKAltDrag%, %A_ScriptDir%\Settings.ini, Windows, HKAltDrag
	IniWrite, %HKAltMinMax%, %A_ScriptDir%\Settings.ini, Windows, HKAltMinMax
	IniWrite, %HKTrayMin%, %A_ScriptDir%\Settings.ini, Windows, HKTrayMin
	IniWrite, %DoubleClickDesktop%, %A_ScriptDir%\Settings.ini, Windows, DoubleClickDesktop
	
	IniWrite, %HKImproveConsole%, %A_ScriptDir%\Settings.ini, Misc, HKImproveConsole
	IniWrite, %HKPhotoViewer%, %A_ScriptDir%\Settings.ini, Misc, HKPhotoViewer
	IniWrite, %ImageExtensions%, %A_ScriptDir%\Settings.ini, Misc, ImageExtensions
	IniWrite, %JoyControl%, %A_ScriptDir%\Settings.ini, Misc, JoyControl
	IniWrite, %FullscreenExclude%, %A_ScriptDir%\Settings.ini, Misc, FullscreenExclude
	IniWrite, %FullscreenInclude%, %A_ScriptDir%\Settings.ini, Misc, FullscreenInclude
	IniWrite, %ClipboardManager%, %A_ScriptDir%\Settings.ini, Misc, ClipboardManager
	IniWrite, %WordDelete%, %A_ScriptDir%\Settings.ini, Misc, WordDelete
	IniWrite, %HideTrayIcon%, %A_ScriptDir%\Settings.ini, Misc, HideTrayIcon
	IniWrite, %ImageQuality%, %A_ScriptDir%\Settings.ini, Misc, ImageQuality
	IniWrite, %ImageExtension%, %A_ScriptDir%\Settings.ini, Misc, ImageExtension
	IniWrite, %AutoUpdate%, %A_ScriptDir%\Settings.ini, Misc, AutoUpdate
	;FastFolders
	Loop 10
	{
	    x:=A_Index-1
	    y:=FF%x%
	    z:=FFTitle%x%
	    IniWrite, %y%, %A_ScriptDir%\Settings.ini, FastFolders, Folder%x%
	    IniWrite, %z%, %A_ScriptDir%\Settings.ini, FastFolders, FolderTitle%x%
	}
	
	Loop 10
	{
		x:=ClipboardList[A_Index]
		x := RegExReplace(RegExReplace(RegExReplace(x, "``", "````"), "\r?\n", "``r``n"), "%", "``%")
		IniWrite, %x%, %A_ScriptDir%\Settings.ini, Misc, Clipboard%A_Index%
	}
	SaveHotkeys()
}
