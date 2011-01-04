Suspend, On
#SingleInstance off
#NoTrayIcon ;Added later
#InstallMouseHook
#InstallKeyBdHook
#MaxThreads 255
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
MajorVersion := 2
MinorVersion := 2
BugfixVersion := 0
ComObjError(0)
if(!A_IsUnicode)
	Msgbox Not running on Unicode build of Autohotkey_L. Please use a unicode version!
#include %A_ScriptDir%\Autoexecute.ahk ;include first to avoid issues with autoexecute ending too soon because of labels
#Include %A_ScriptDir%
#include %A_ScriptDir%\lib\Array.ahk
#include %A_ScriptDir%\lib\binreadwrite.ahk
#include %A_ScriptDir%\lib\Crypt.ahk
#include %A_ScriptDir%\lib\Cursor.ahk
#include %A_ScriptDir%\lib\Edit.ahk
#include %A_ScriptDir%\lib\FTPLib.ahk
#include %A_ScriptDir%\lib\Functions.ahk
#include %A_ScriptDir%\lib\gdip.ahk
#include %A_ScriptDir%\lib\Parse.ahk
#include %A_ScriptDir%\lib\RemoteBuf.ahk
#include %A_ScriptDir%\lib\RichObject.ahk
#include %A_ScriptDir%\lib\Taskbutton.ahk
#include %A_ScriptDir%\lib\unhtml.ahk
#include %A_ScriptDir%\lib\VA.ahk
#include %A_ScriptDir%\lib\Win.ahk
#include %A_ScriptDir%\lib\DllCalls.ahk
; #include %A_ScriptDir%\lib\xpath.ahk
#include %A_ScriptDir%\Accessor\Accessor.ahk

#include %A_ScriptDir%\Autoupdate.ahk
#include %A_ScriptDir%\EventSystem.ahk
#include %A_ScriptDir%\EditEventGUI.ahk
#include %A_ScriptDir%\EditSubEventGUI.ahk
#include %A_ScriptDir%\Placeholders.ahk
#include %A_ScriptDir%\SubEventGUIBuilder.ahk
#include %A_ScriptDir%\messagehooks.ahk
#include %A_ScriptDir%\navigate.ahk
#include %A_ScriptDir%\FolderButtonManager.ahk
#include %A_ScriptDir%\ContextMenu.ahk
#include %A_ScriptDir%\FastFolders.ahk
#include %A_ScriptDir%\WindowHandling.ahk
#include %A_ScriptDir%\explorer.ahk
#include %A_ScriptDir%\clipboard.ahk
; #include %A_ScriptDir%\FTPUpload.ahk 
#include %A_ScriptDir%\Taskbar.ahk
#include %A_ScriptDir%\Hotstrings.ahk
; #include %A_ScriptDir%\Misc.ahk
#include %A_ScriptDir%\xml.ahk
#include %A_ScriptDir%\debugging.ahk
#include %A_ScriptDir%\settings.ahk
#include %A_ScriptDir%\miscfunctions.ahk
#include %A_ScriptDir%\Registry.ahk
#include %A_ScriptDir%\SlideWindows.ahk
#include %A_ScriptDir%\JoyControl.ahk
#include %A_ScriptDir%\Tooltip.ahk
#include %A_ScriptDir%\ExplorerTabs.ahk
#include %A_ScriptDir%\CustomHotkeys.ahk
#include %A_ScriptDir%\HotkeyGUI.ahk