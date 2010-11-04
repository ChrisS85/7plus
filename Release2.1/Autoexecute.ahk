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

;This value is used when there are no write permissions in 7plus folder (mostly %ProgramFiles% in Vista/7), so that the config file can be copied to %AppData%\7plus and used from there in the future.
;As the old file would still exist then, we need to write this value to the new file and check for its existance to decide which config file needs to be used.
IniRead, NoAdminSettingsTransfered, %A_AppData%\7plus\Settings.ini, Misc, NoAdminSettingsTransfered, 0
;Try to use config file from script dir in portable mode or when it wasn't neccessary to copy it to appdata yet
if((IsPortable || FileExist(A_ScriptDir "\Settings.ini")) && !NoAdminSettingsTransfered)
	ConfigPath := A_ScriptDir "\Settings.ini"
Else
{
	ConfigPath := A_AppData "\7plus\Settings.ini"
	if(!FileExist(A_AppData "\7plus"))
		FileCreateDir, %A_AppData%\7plus
}
;Start debugger
IniRead, DebugEnabled, %ConfigPath%, General, DebugEnabled , 0
if(DebugEnabled)
	DebuggingStart()

IniRead, RunAsAdmin, %ConfigPath%, Misc, RunAsAdmin , Always/Ask
;Remove 'Always run as admin' compatibility flag from registry in portable or non-admin mode
if(RunAsAdmin = "Never" && !IsPortable)
{
	if(A_IsCompiled)
		RegRead, temp, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptFullPath%
	else
		RegRead, temp, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%
	if(temp)
	{
		if(A_IsCompiled)
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptFullPath%
		else
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%
	}
}
;Set 'Always run as admin' compatibility flag from registry in non-portable and admin mode
if(RunAsAdmin = "Always/Ask" && !IsPortable)
{
	if(A_IsCompiled)
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptFullPath%, RUNASADMIN
	else
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%, RUNASADMIN
}

;If program is run without admin privileges, try to run it again as admin, and exit this instance when the user confirms it
if(!A_IsAdmin && RunAsAdmin = "Always/Ask")
{
	If(A_IsCompiled)
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "/r", str, A_WorkingDir, int, 1)
	else
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, "/r """ A_ScriptFullPath """", str, A_WorkingDir, int, 1)
	If(uacrep = 42) ;UAC Prompt confirmed, application may run as admin
		ExitApp
}

;If the current config path is set to the program directory but there is no write access, %AppData%\7plus needs to be used.
;If this is the first time (i.e. NoAdminSettingsTransfered = 0), all config files need to be copied to the new config path
if((ConfigPath = A_ScriptDir "\Settings.ini" && !WriteAccess(A_ScriptDir "\Accessor.xml")) || ConfigPath = A_AppData "\7plus\Settings.ini")
{
	if(IsPortable)
		MsgBox No file access to settings files in program directory. 7plus will not be able to store its settings. Please move 7plus to a folder with write permissions, run it as administrator, or grant write permissions to this directory.
	else
	{
		ConfigPath := A_AppData "\7plus\Settings.ini"
		if(!FileExist(A_AppData "\7plus"))
			FileCreateDir, %A_AppData%\7plus
		if(NoAdminSettingsTransfered != MajorVersion "." MinorVersion "." BugfixVersion)
		{
			if(!WriteAccess(A_ScriptDir "\Accessor.xml"))
				MsgBox No File access to settings files in program directory. 7plus will use %A_AppData%\7plus as settings directory.
			FileCopy, %A_ScriptDir%\Events.xml, %A_AppData%\7plus\Events.xml, 1
			FileCopy, %A_ScriptDir%\Settings.ini, %A_AppData%\7plus\Settings.ini, 1
			FileCopy, %A_ScriptDir%\ProgramCache.xml, %A_AppData%\7plus\ProgramCache.xml, 1
			FileCopy, %A_ScriptDir%\Notes.xml, %A_AppData%\7plus\Notes.xml, 1
			FileCopy, %A_ScriptDir%\History.xml, %A_AppData%\7plus\History.xml, 1
			FileCopy, %A_ScriptDir%\Clipboard.xml, %A_AppData%\7plus\Clipboard.xml, 1
			FileCopy, %A_ScriptDir%\Accessor.xml, %A_AppData%\7plus\Accessor.xml, 1
			FileCopy, %A_ScriptDir%\FTPProfiles.xml, %A_AppData%\7plus\FTPProfiles.xml, 1
			FileDelete, %A_ScriptDir%\Events.xml
			FileDelete, %A_ScriptDir%\Settings.ini
			FileDelete, %A_ScriptDir%\ProgramCache.xml
			FileDelete, %A_ScriptDir%\Notes.xml
			FileDelete, %A_ScriptDir%\History.xml
			FileDelete, %A_ScriptDir%\Clipboard.xml,
			FileDelete, %A_ScriptDir%\Accessor.xml
			FileDelete, %A_ScriptDir%\FTPProfiles.xml
			NoAdminSettingsTransfered := MajorVersion "." MinorVersion "." BugfixVersion
		}
	}
}

;Update checker
IniRead, AutoUpdate, %ConfigPath%, Misc, AutoUpdate, 1
if(A_IsAdmin) ;For some reason this does not work for normal user
{
	if(AutoUpdate)
		AutoUpdate()
	PostUpdate()
}


SplitPath, ConfigPath,,path
;Possibly replace an old Events.xml with the current one. The current version is stored in LastReplacedEventsFile so that this is not done repeatedly if the new file couldn't be deleted.
;In addition, a backup of the old file is created.
IniRead, LastReplacedEventsFile, %ConfigPath%, Misc, LastReplacedEventsFile, 0
if(FileExist(A_ScriptDir "\Events " MajorVersion "." MinorVersion "." BugfixVersion ".xml") && LastReplacedEventsFile != MajorVersion "." MinorVersion "." BugfixVersion && WriteAccess(path "\Accessor.xml"))
{
	if(FileExist(path "\Events.xml"))
	{
		FileCopy, %path%\Events.xml, %path%\Events Backup.xml
		FileDelete, %path%\Events.xml
		Msgbox A Backup of your previous Events.xml file was created in %path%\Events Backup.xml.
	}
	FileCopy, %A_ScriptDir%\Events %MajorVersion%.%MinorVersion%.%BugfixVersion%.xml, %path%\Events.xml
	FileDelete, %A_ScriptDir%\Events %MajorVersion%.%MinorVersion%.%BugfixVersion%.xml
	LastReplacedEventsFile := MajorVersion "." MinorVersion "." BugfixVersion
}
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
FileAppend, %hAHK%, %A_Temp%\7plus\hwnd.txt
outputdebug hahk %hahk%
DllCall( "RegisterShellHookWindow", "Ptr",hAHK ) 
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
; IniRead, TextEditor, %ConfigPath%, Explorer, TextEditor , `%windir`%\notepad.exe
; IniRead, ImageEditor, %ConfigPath%, Explorer, ImageEditor , `%windir`%\system32\mspaint.exe

/*
IniRead, HKCreateNewFile, %ConfigPath%, Explorer, HKCreateNewFile, 1
IniRead, HKCreateNewFolder, %ConfigPath%, Explorer, HKCreateNewFolder, 1
IniRead, HKCopyFilenames, %ConfigPath%, Explorer, HKCopyFilenames, 1
IniRead, HKCopyPaths, %ConfigPath%, Explorer, HKCopyPaths, 1
IniRead, HKAppendClipboard, %ConfigPath%, Explorer, HKAppendClipboard, 1
*/

; IniRead, HKFastFolders, %ConfigPath%, Explorer, HKFastFolders, 1
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
; IniRead, DoubleClickDesktop, %ConfigPath%, Windows, DoubleClickDesktop, %A_Windir%\explorer.exe
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
ClipboardList := Array()
ClipboardList.push := "Stack_Push"
ClipboardList := Object("Base", ClipboardList)
SplitPath, ConfigPath,,path
path .= "\Clipboard.xml"
if(FileExist(path))
{
	FileRead, xml, %path%
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
		IniRead, x, %ConfigPath%, FastFolders, Folder%z%, ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
		IniRead, y, %ConfigPath%, FastFolders, FolderTitle%z%, Computer
	}
	else if(z=1)
	{
		IniRead, x, %ConfigPath%, FastFolders, Folder%z%, C:\
		IniRead, y, %ConfigPath%, FastFolders, FolderTitle%z%, C:\
	}
    IniRead, x, %ConfigPath%, FastFolders, Folder%z%, %A_Space%
    IniRead, y, %ConfigPath%, FastFolders, FolderTitle%z%, %A_Space%
	FastFolders.append(Object("Path", x, "Title", y))
}


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
	
if(A_OSVersion="WIN_7")
	CreateInfoGui()

Action_Upload_ReadFTPProfiles()

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



	
SetTimer, TriggerTimer, 1000
; SetTimer, AssignHotkeys, -10000

;Init event system
EventSystem_Startup()

;possibly start wizard
if (Firstrun=1)
	GoSub, wizardry
FirstRun:=0

;Event loop
EventScheduler()
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
	WriteClipboard()
	Action_Upload_WriteFTPProfiles()
	SlideWindows_Exit()
	TabContainerList.CloseAllInactiveTabs()
	GoSub TrayminClose	
	if(Reload)
	{
		ShouldReload := 1
		reload
	}
	FileRemoveDir, %A_Temp%\7plus, 1
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
	return
}
AutoUpdate()
{	
	global MajorVersion,MinorVersion,BugfixVersion
	if(!A_IsAdmin) ;For some reason this does not work for normal user
		return
	if(IsConnected())
	{
		random, rand
		;Disable keyboard hook to increase responsiveness
		Suspend, On
		URLDownloadToFile, http://7plus.googlecode.com/files/NewVersion.ini?x=%rand%, %A_ScriptDir%\Version.ini
		Suspend, Off
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
	global MajorVersion,MinorVersion,BugfixVersion, ConfigPath, IsPortable
	if(FileExist(A_ScriptDir "\Updater.exe"))
	{
		IniRead, tmpMajorVersion, %A_ScriptDir%\Version.ini,Version,MajorVersion
		IniRead, tmpMinorVersion, %A_ScriptDir%\Version.ini,Version,MinorVersion
		IniRead, tmpBugfixVersion, %A_ScriptDir%\Version.ini,Version,BugfixVersion
		if(tmpMajorVersion=MajorVersion && tmpMinorVersion = MinorVersion && tmpBugfixVersion = BugfixVersion)
		{
			;If the new version is 2.1.0, some registry values need to be modified according to the new version.
			if(MajorVersion "." MinorVersion "." BugfixVersion = "2.1.0")
			{
				RemoveAllButtons()
				RefreshFastFolders()
			}
			;2.0.0 -> 2.1.0 compatibility, update autorun executable
			if(!IsPortable)
			{
				RegRead, Autorun, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus
				if(InStr(Autorun, "UACAutorun"))
					if(A_IsCompiled)
						RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\7plus.exe"
					else
						RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\7plus.ahk"
			}
			;Possibly delete remaining files from 2.0.0 which are obsolete now
			List := "UACAutorun.exe,ChangeLocation.exe,Events\cmd.xml,Events\CopyFilenames.xml,Events\CreateNewFile,Folder.xml,Events\DoubleClickDesktop.xml,Events\DoubleClickTaskbar.xml,Events\DoubleClickUpwards.xml,Events\Mouse Volume.xml,Events\Open in Editor.xml,Events\Other things.xml,Events\Upload.xml,Events\AppendToClipboard.xml,Events\BackspaceUpwards.xml"
			Loop, Parse, List,`,
				if(FileExist(A_ScriptDir "/" A_LoopField) && WriteAccess(A_ScriptDir "/" A_LoopField))
					FileDelete %A_ScriptDir%/%A_LoopField%
			
			if(FileExist(A_ScriptDir "\Changelog.txt"))
			{
				MsgBox,4,, Update successful. View Changelog?
				IfMsgBox Yes
					run %A_ScriptDir%\Changelog.txt
				MsgBox Make sure to try out the new Accessor tool (Default: ALT + Space) !
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
	FileDelete, %ConfigPath%
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
	; IniWrite, %TextEditor%, %ConfigPath%, Explorer, TextEditor
	; IniWrite, %ImageEditor%, %ConfigPath%, Explorer, ImageEditor
	/*
	IniWrite, %HKCreateNewFile%, %ConfigPath%, Explorer, HKCreateNewFile
	IniWrite, %HKCreateNewFolder%, %ConfigPath%, Explorer, HKCreateNewFolder
	IniWrite, %HKCopyFilenames%, %ConfigPath%, Explorer, HKCopyFilenames
	IniWrite, %HKCopyPaths%, %ConfigPath%, Explorer, HKCopyPaths
	IniWrite, %HKAppendClipboard%, %ConfigPath%, Explorer, HKAppendClipboard
	*/
	; IniWrite, %HKFastFolders%, %ConfigPath%, Explorer, HKFastFolders
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
	; IniWrite, %TaskbarLaunchPath%, %ConfigPath%, Windows, TaskbarLaunchPath
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
	; IniWrite, %DoubleClickDesktop%, %ConfigPath%, Windows, DoubleClickDesktop
	
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
	IniWrite, %RunAsAdmin%, %ConfigPath%, Misc, RunAsAdmin
	IniWrite, %ExplorerPath%, %ConfigPath%, Misc, ExplorerPath
	IniWrite, %PreviousExplorerPath%, %ConfigPath%, Misc, PreviousExplorerPath
	if(NoAdminSettingsTransfered)
		IniWrite, %NoAdminSettingsTransfered%, %ConfigPath%, Misc, NoAdminSettingsTransfered
	if(LastReplacedEventsFile)
		IniWrite, %LastReplacedEventsFile%, %ConfigPath%, Misc, LastReplacedEventsFile	
	IniWrite, 0, %ConfigPath%, General, FirstRun
	;FastFolders
	Loop 10
	{
	    x:=A_Index-1
	    y:=FastFolders[A_Index].Path
	    z:=FastFolders[A_Index].Title
	    IniWrite, %y%, %ConfigPath%, FastFolders, Folder%x%
	    IniWrite, %z%, %ConfigPath%, FastFolders, FolderTitle%x%
	}
}
WriteClipboard()
{
	global ConfigPath, ClipboardList
	SplitPath, ConfigPath,,path
	FileDelete, %path%\Clipboard.xml
	XMLObject := Object("List",Array())
	Loop % min(ClipboardList.len(), 10)
		XMLObject.List.append(ClipboardList[A_Index])
	XML_Save(XMLObject,path "\Clipboard.xml")
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