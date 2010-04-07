;Need to add conditions if windows can be minimized/maximized/restored and respect direction
#if HKMMinMax && !MouseMinMaxRunning && GetKeyState("MButton","P")
WheelDown::MouseMin()
#if
#if HKMMinMax && !MouseMinMaxRunning && GetKeyState("MButton","P")
WheelUp::MouseMax()
#if
#if HKAltMinMax && !MouseMinMaxRunning && GetKeyState("MButton","P")
WheelDown::MouseMin()
#if
#if HKAltMinMax && !MouseMinMaxRunning && GetKeyState("MButton","P")
WheelUp::MouseMax()
#if
MouseMin()
{	
	global MouseMinMaxRunning
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	MouseMinMaxRunning:=true
	while(GetKeyState("MButton","P"))
		Sleep 20
	if(WinState = 0)
		PostMessage, 0x112, 0xF020,,, ahk_id %MouseWin% ;Winminimize, but apparently more reliable
	else
		WinRestore ahk_id %MouseWin%
	MouseMinMaxRunning:=false
}

MouseMax()
{
	global MouseMinMaxRunning
	MouseMinMaxRunning:=true
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	while(GetKeyState("MButton","P"))
		Sleep 20
	if(WinState = 0)
		WinMaximize ahk_id %MouseWin%
	MouseMinMaxRunning:=false
}
