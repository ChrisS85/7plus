/*
This file contains some global variables that are used throughout the application.
Variables which could possibly cause naming conflicts with local variables aren't made super-global.
*/

global WinVer := GetWindowsVersion()
global WIN_XP := 5.1
global WIN_XP64 := 5.2
global WIN_VISTA := 6.0
global WIN_7 := 6.1
global WIN_8 := 6.2

;~ global Vista7 := IsVista7()
;~ global shell32MUIpath := "" ;Defined in Autoexecute.ahk
global XMLMajorVersion := ""
;~ global MajorVersion := ""
global XMLMinorVersion := ""
;~ global MinorVersion := ""
global XMLBugfixVersion := ""
global NotifyIcons := new CNotifyIcons()
;~ global BugfixVersion := ""
global BlinkingWindows := Array()
GetWindowsVersion()
{
	Version := DllCall("GetVersion", "uint") & 0xFFFF
	return (Version & 0xFF) "." (Version >> 8)
}
Class CNotifyIcons
{
	Info := WinVer >= WIN_Vista ? 222 : 136
	Error := WinVer >= WIN_Vista ? 78 : 110
	Success := WinVer >= WIN_Vista ? 145 : 136
	Internet := 136
	Sound := WinVer >= WIN_Vista ? 169 : 110
	SoundMute := WinVer >= WIN_Vista ? 220 : 169
	Question := 24
}