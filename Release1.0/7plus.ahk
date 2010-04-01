#Persistent 
#NoTrayIcon ;Added later
#InstallMouseHook
#IfTimeout 150ms ;Might soften up mouse hook timeout problem
#MaxHotkeysPerInterval 1000 ;Required for mouse wheel
SetBatchLines -1
SetMouseDelay, -1 ; no pause after mouse clicks 
SetKeyDelay, -1 ; no pause after keys sent 
CoordMode, Mouse, Screen
#include %a_scriptdir%\lib\binreadwrite.ahk
#include %a_scriptdir%\lib\gdip.ahk
#include %a_scriptdir%\lib\Functions.ahk
#include %a_scriptdir%\lib\com.ahk
#include %a_scriptdir%\lib\FTPLib.ahk
#include %a_scriptdir%\lib\Array.ahk
#include %a_scriptdir%\lib\SetCursor.ahk
#include %a_scriptdir%\lib\RemoteBuf.ahk
#include %a_scriptdir%\lib\win.ahk
#include %a_scriptdir%\lib\Taskbutton.ahk

#include %a_scriptdir%\Autoexecute.ahk
#include %a_scriptdir%\messagehooks.ahk
#include %a_scriptdir%\navigate.ahk
#include %a_scriptdir%\FolderButtonManager.ahk
#include %a_scriptdir%\ContextMenu.ahk
#include %a_scriptdir%\FastFolders.ahk
#include %a_scriptdir%\WindowTweaks.ahk
#include %a_scriptdir%\explorer.ahk
#include %a_scriptdir%\clipboard.ahk
#include %a_scriptdir%\FTPUpload.ahk 
#include %a_scriptdir%\Taskbar.ahk
#include %a_scriptdir%\CustomHotkeys.ahk
#include %a_scriptdir%\debugging.ahk
#include %a_scriptdir%\wizard.ahk
#include %a_scriptdir%\settings.ahk
#include %a_scriptdir%\miscfunctions.ahk
#include %a_scriptdir%\Registry.ahk
#include %a_scriptdir%\SlideWindows.ahk
#include %a_scriptdir%\JoyControl.ahk
#include %a_scriptdir%\Tooltip.ahk
#if !IsFullscreen("A",true,false)
#h::
	if(WinExist("7plus Settings"))
		WinActivate 7plus Settings
	else
		GoSub Settingshandler
	return
#if
