;Call this to use debug view
DebuggingStart()
{	
	if(FileExist(A_ScriptDir "\DebugView\Dbgview.exe"))
	{
		CoordMode, Mouse, Relative 
		;Debug view
		a_scriptPID := DllCall("GetCurrentProcessId")	; get script's PID
		if(WinExist("ahk_class dbgviewClass")) ; kill it if the debug viewer is running from an older instance
		{
			winactivate, ahk_class dbgviewClass
			Winwaitactive, ahk_class dbgviewClass
			winclose, ahk_class dbgviewClass
			WinWaitNotActive ahk_class dbgviewClass
		}
		run, %A_ScriptDir%\DebugView\Dbgview.exe /f,, UseErrorLevel
		winwait, ahk_class dbgviewClass
		winactivate, ahk_class dbgviewClass
		Winwaitactive, ahk_class dbgviewClass
		sendinput, !E{down}{down}{down}{down}{down}{Enter}
		winwait, DebugView Filter
		winactivate, DebugView Filter
		Winwaitactive, DebugView Filter 
		MouseGetPos, x,y
		mouseclick, left, 125, 85,,0
		MouseMove, x,y,0
		send, [%a_scriptPID%*{Enter}
		send, !M{Down}{Enter}
		Coordmode, Mouse, Screen
	}
	else
		MsgBox DebugView not found! Please make sure that it's located in %A_ScriptDir%\DebugView\Dbgview.exe, or disable debugging in the Settings.ini file.
}

;output debug command->function wrapper
OutputDebug(text)
{
	global DebugEnabled
	if(DebugEnabled)
		OutputDebug %text%
}

;Translates last win32 error to identifier by using errorcodes.err list in script dir
GetLastError()
{ 
	Err_code:=DllCall("GetLastError") 
	Loop, Read, %A_Scriptdir%\errorcodes.err 
	{ 
		FileReadLine, OutputVar, %A_Scriptdir%\errorcodes.err, %A_Index% 
		if (OutputVar = Err_code) 
		{ 
		  error_line_number:=A_Index+1    
		  FileReadLine, Error_msg, %A_Scriptdir%\errorcodes.err, %error_line_number% 
		  Return Err_code ": " Error_msg 
		  Break 
		} 
	} 
}
