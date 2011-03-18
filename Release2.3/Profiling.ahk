ResetCurrentProfiling:
enum := Profiler.Current._newEnum()
while enum[k,v]
{
	if(k="StartTime")
		v := A_TickCount
	else
		v := 0
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
	global Profiler
	ProfilingText := "Profiler: "
	. "`nTotal: "
	. "`n`tStart Time: " Profiler.Total.StartTime
	. "`n`tRunning Time: " (A_TickCount - Profiler.Total.StartTime)
	. "`n`tEventLoop: " (Profiler.Total.EventLoop / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`n`tShellMessage: " (Profiler.Total.ShellMessage / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`n`tHookProc: " (Profiler.Total.HookProc / (A_TickCount - Profiler.Total.StartTime) * 100) "%"
	. "`nCurrent: "
	. "`n`tRunning Time: " (A_TickCount - Profiler.Current.StartTime)
	. "`n`tEventLoop: " (Profiler.Current.EventLoop / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	. "`n`tShellMessage: " (Profiler.Current.ShellMessage / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	. "`n`tHookProc: " (Profiler.Current.HookProc / (A_TickCount - Profiler.Current.StartTime) * 100) "%"
	CoordMode, Tooltip, Screen
	Tooltip, %ProfilingText%, % A_ScreenWidth * 0.85, % A_ScreenHeight * 0.75, 2
	return
}

#if ProfilingEnabled
^!#P::ShowProfilingInfo := !ShowProfilingInfo
