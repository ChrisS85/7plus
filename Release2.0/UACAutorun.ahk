#NoTrayIcon
if(A_IsCompiled)
	Run, "%A_ScriptDir%\7plus.exe"
else
	DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptDir "\7plus.ahk""", str, A_WorkingDir, int, 1)
ExitApp