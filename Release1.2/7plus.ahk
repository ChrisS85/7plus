#Persistent 
#NoTrayIcon ;Added later
#InstallMouseHook
#InstallKeyBdHook
#IfTimeout 150ms ;Might soften up mouse hook timeout problem
#MaxHotkeysPerInterval 1000 ;Required for mouse wheel
SetBatchLines -1
SetMouseDelay, -1 ; no pause after mouse clicks 
SetKeyDelay, -1 ; no pause after keys sent 
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Screen
SetWinDelay, -1
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases. 
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability. 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;SetFormat, Integer, D
CurrentVersion:=1.2
#Include %A_ScriptDir%
#include %A_ScriptDir%\lib\binreadwrite.ahk
#include %A_ScriptDir%\lib\gdip.ahk
#include %A_ScriptDir%\lib\Functions.ahk
#include %A_ScriptDir%\lib\com.ahk
#include %A_ScriptDir%\lib\FTPLib.ahk
#include %A_ScriptDir%\lib\Array.ahk
#include %A_ScriptDir%\lib\RemoteBuf.ahk
#include %A_ScriptDir%\lib\Taskbutton.ahk
#include %A_ScriptDir%\lib\Cursor.ahk
#include %A_ScriptDir%\lib\Win.ahk
#include %A_ScriptDir%\lib\Crypt.ahk
#include %A_ScriptDir%\Autoexecute.ahk
#include %A_ScriptDir%\messagehooks.ahk
#include %A_ScriptDir%\navigate.ahk
#include %A_ScriptDir%\FolderButtonManager.ahk
#include %A_ScriptDir%\ContextMenu.ahk
#include %A_ScriptDir%\FastFolders.ahk
#include %A_ScriptDir%\WindowHandling.ahk
#include %A_ScriptDir%\explorer.ahk
#include %A_ScriptDir%\clipboard.ahk
#include %A_ScriptDir%\FTPUpload.ahk 
#include %A_ScriptDir%\Taskbar.ahk
#include %A_ScriptDir%\Misc.ahk
#include %A_ScriptDir%\debugging.ahk
#include %A_ScriptDir%\wizard.ahk
#include %A_ScriptDir%\settings.ahk
#include %A_ScriptDir%\miscfunctions.ahk
#include %A_ScriptDir%\Registry.ahk
#include %A_ScriptDir%\SlideWindows.ahk
#include %A_ScriptDir%\JoyControl.ahk
#include %A_ScriptDir%\Tooltip.ahk
#include %A_ScriptDir%\WinTrayMin.ahk
#include %A_ScriptDir%\ExplorerTabs.ahk
#include %A_ScriptDir%\CustomHotkeys.ahk
#include %A_ScriptDir%\HotkeyGUI.ahk
#include %A_ScriptDir%\lib\Dock.ahk
#if !IsFullscreen("A",true,false)
#h::
	DetectHiddenWindows, Off
	if(WinExist("7plus Settings"))
		WinActivate 7plus Settings
	else
		GoSub Settingshandler
	return
#if
#y::Reload