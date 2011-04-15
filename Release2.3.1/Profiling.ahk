ResetCurrentProfiling:
enum := Profiler.Current._newEnum()
while enum[k,v]
{
	if(k="StartTime")
		Profiler.Current[k] := A_TickCount
	else
		Profiler.Current[k] := 0
}
return
ShowProfiling:
if(ShowProfilingInfo)
	ShowProfiling()
else
	Tooltip,,,,2
return
ShowProfiling()
{
	global Profiler, hAHK
	outputdebug % Profiler.Current.StartTime
	WinGet, PID, PID, ahk_id %hAHK%
	hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", PID, "Ptr")
	DllCall("GetProcessTimes", "Ptr", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime, "Ptr")
	DllCall("CloseHandle", "Ptr", hProc)
	CPU := Round(min(max((newKrnlTime-Profiler.oldKrnlTime + newUserTime-Profiler.oldUserTime)/10000000 * 100,0),100), 2)   ; 1sec: 10**7
	Profiler.oldKrnlTime := newKrnlTime
	Profiler.oldUserTime := newUserTime
	ProfilingText := "Profiler: "
	. "`nTotal: "
	. "`n`tStart Time: " Profiler.Total.StartTime
	. "`n`tRunning Time: " (A_TickCount - Profiler.Total.StartTime) / 1000 " s"
	. "`n`tEventLoop: " (Profiler.Total.EventLoop / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`n`tShellMessage: " (Profiler.Total.ShellMessage / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`n`tHookProc: " (Profiler.Total.HookProc / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`nCurrent: "
	. "`n`tRunning Time: " (A_TickCount - Profiler.Current.StartTime) / 1000 " s"
	. "`n`tEventLoop: " (Profiler.Current.EventLoop / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	. "`n`tShellMessage: " (Profiler.Current.ShellMessage / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	. "`n`tHookProc: " (Profiler.Current.HookProc / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	. "`n`nCPU usage: " CPU "%"
	CoordMode, Tooltip, Screen
	Tooltip, %ProfilingText%, % A_ScreenWidth * 0.85, % A_ScreenHeight * 0.75, 2
	return
}

#if ProfilingEnabled
^!#P::ShowProfilingInfo := !ShowProfilingInfo
^!#R::GoSub ResetCurrentProfiling
#if
