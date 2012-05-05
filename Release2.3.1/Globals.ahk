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
	Info := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", WinVer >= WIN_Vista ? 222 : 136))
	Error := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", WinVer >= WIN_Vista ? 78 : 110))
	Success := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", WinVer >= WIN_Vista ? 145 : 136))
	Internet := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", 136))
	Sound := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", WinVer >= WIN_Vista ? 169 : 110))
	SoundMute := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", WinVer >= WIN_Vista ? 220 : 169))
	Question := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", 24))
}