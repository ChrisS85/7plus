/*
This file contains some global variables that are used throughout the application.
Variables which could possibly cause naming conflicts with local variables aren't made super-global.
*/

global Vista7 := IsVista7()
global shell32MUIpath := ""
global XMLMajorVersion := ""
;~ global MajorVersion := ""
global XMLMinorVersion := ""
;~ global MinorVersion := ""
global XMLBugfixVersion := ""
global NotifyIcons := new CNotifyIcons()
;~ global BugfixVersion := ""
;~ global Events := {}
global BlinkingWindows := Array()
IsVista7()
{
	;Get windows version
	RegRead, WinVersion, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
	return WinVersion >= 6
}
Class CNotifyIcons
{
	Info := Vista7 ? 222 : 136
	Error := Vista7 ? 78 : 110
	Success := Vista7 ? 145 : 136
	Internet := 136
	Sound := Vista7 ? 169 : 110
	SoundMute := 220
	Question := 24
}