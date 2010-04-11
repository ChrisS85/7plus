#Persistent 
#NoTrayIcon ;Added later
#InstallMouseHook
#IfTimeout 150ms ;Might soften up mouse hook timeout problem
#MaxHotkeysPerInterval 1000 ;Required for mouse wheel
SetBatchLines -1
SetMouseDelay, -1 ; no pause after mouse clicks 
SetKeyDelay, -1 ; no pause after keys sent 
CoordMode, Mouse, Screen
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases. 
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability. 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CurrentVersion:=1.1
#Include %A_ScriptDir%
#include lib\binreadwrite.ahk
#include lib\gdip.ahk
#include lib\Functions.ahk
#include lib\com.ahk
#include lib\FTPLib.ahk
#include lib\Array.ahk
#include lib\RemoteBuf.ahk
#include lib\Taskbutton.ahk
#include lib\Cursor.ahk
#include Autoexecute.ahk
#include messagehooks.ahk
#include navigate.ahk
#include FolderButtonManager.ahk
#include ContextMenu.ahk
#include FastFolders.ahk
#include WindowTweaks.ahk
#include explorer.ahk
#include clipboard.ahk
#include FTPUpload.ahk 
#include Taskbar.ahk
#include CustomHotkeys.ahk
#include debugging.ahk
#include wizard.ahk
#include settings.ahk
#include miscfunctions.ahk
#include Registry.ahk
#include SlideWindows.ahk
#include JoyControl.ahk
#include Tooltip.ahk
#include Newstuff.ahk
#if !IsFullscreen("A",true,false)
#h::
	if(WinExist("7plus Settings"))
		WinActivate 7plus Settings
	else
		GoSub Settingshandler
	return
#if
#y::Reload
