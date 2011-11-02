;Generic Run interface for subevents. They can implement this interface like this:
;static _ImplementsRun := ImplementRunInterface(CSubEvent)
;It's important to use a "_" or "tmp" at the start of the name to mark this property as temporary so it won't be saved.
ImplementRunInterface(Run)
{	
	Run.WaitForFinish := false
	Run.RunAsAdmin := false
	Run.Command := "cmd.exe"
	Run.WorkingDirectory := ""
	if(Run.HasKey("__Class"))
	{
		Run.RunExecute := Func("Run_Execute")
		Run.RunDisplayString := Func("Run_DisplayString")
		Run.RunGUIShow := Func("Run_GUIShow")
		Run.RunGUISubmit := Func("Run_GUISubmit")
	}
}

Run_Execute(SubEvent, Event)
{
	if(!SubEvent.tmpPid)
	{
		command := Event.ExpandPlaceholders(SubEvent.Command)
		WorkingDirectory := Event.ExpandPlaceholders(SubEvent.WorkingDirectory)
		if(SubEvent.WaitForFinish)
		{
			SubEvent.tmpPid := Run(command, WorkingDirectory, "", !SubEvent.RunAsAdmin)
			if(SubEvent.tmpPid) ;If retrieved properly
				return -1
			MsgBox Waiting for %command% failed!
			return 0
		}
		else
			Run(command, WorkingDirectory, "", !SubEvent.RunAsAdmin)
	}
	else
	{
		pid := SubEvent.tmpPid
		Process, Exist, %pid%
		if(ErrorLevel)
			return -1
	}
	return 1
}

Run_DisplayString(SubEvent)
{
	return "Run " SubEvent.Command
}

Run_GuiShow(SubEvent, GUI, GoToLabel = "")
{
	if(GoToLabel = "")
	{
		SubEvent.tmpRunGUI := GUI
		SubEvent.AddControl(GUI, "Text", "Text", "Enclose paths with spaces in quotes and append parameters in command field.")
		SubEvent.AddControl(GUI, "Edit", "Command", "", "", "Command:","Browse", "Action_Run_Browse", "Placeholders", "Action_Run_Placeholders")
		SubEvent.AddControl(GUI, "Edit", "WorkingDirectory", "", "", "Working Dir:","Browse", "Action_Run_Browse_WD", "Placeholders", "Action_Run_Placeholders_WD")
		SubEvent.AddControl(GUI, "Checkbox", "WaitForFinish", "Wait for finish", "", "")
		SubEvent.AddControl(GUI, "Checkbox", "RunAsAdmin", "Run as admin", "", "")
	}
	else if(GoToLabel = "Browse")
		SubEvent.SelectFile(SubEvent.tmpRunGUI, "Command", "Select File", "", 1)
	else if(GoToLabel = "Placeholders")
		ShowPlaceholderMenu(SubEvent.tmpRunGUI, "Command")
	else if(GoToLabel = "Browse_WD")
		SubEvent.Browse(SubEvent.tmpRunGUI, "WorkingDirectory", "Select working directory", "", 1)
	else if(GoToLabel = "Placeholders_WD")
		ShowPlaceholderMenu(SubEvent.tmpRunGUI, "WorkingDirectory")
}
Run_GUISubmit(SubEvent, GUI)
{
	SubEvent.Remove("tmpRunGUI")
}
Action_Run_Browse:
GetCurrentSubEvent().RunGuiShow("", "Browse")
return
Action_Run_Placeholders:
GetCurrentSubEvent().RunGuiShow("", "Placeholders")
return
Action_Run_Browse_WD:
GetCurrentSubEvent().RunGuiShow("", "Browse_WD")
return
Action_Run_Placeholders_WD:
GetCurrentSubEvent().RunGuiShow("", "Placeholders_WD")
return

Run(Target, WorkingDir = "", Mode = "", NonElevated=1) 
{
	;run as current user
	if(!Vista7 || (!A_IsAdmin && NonElevated) || (A_IsAdmin && !NonElevated))
	{
		Run, %Target% , %WorkingDir%, %Mode% UseErrorLevel, v
		if(A_LastError)
			Msgbox Error launching %Target%
		Return, v
	}
	;Split command and argument
	if(InStr(Target, """")=1 && InStr(Target, """",false,3)) ;command has quotes, split it
	{
		Args := SubStr(Target,InStr(Target, """", false, 3) + 2)
		Target := SubStr(Target, 2,InStr(Target, """", false, 3) - 2)
	}
	else if(InStr(Target, " ")) ;look for spaces after the command, e.g. "C:\Program Files\bla.exe -arg"
	{
		Args := SubStr(Target, InStr(Target, " ", false) + 1)
		Target := SubStr(Target, 1, InStr(Target, " ", false) - 1)
	}
	else
		Args := "" ;Single Command
	
	;~ MsgBox target "%target%"`nargs "%args%"
	;Run under explorer process as normal user
	if(A_IsAdmin && NonElevated)
	{
		return RunAsUser(Target, args, WorkingDir)
		;~ result := DllCall("Explorer.dll\ShellExecInExplorerProcess","Str",Target, "Str", Args, "Str", WorkingDir)
		;~ if(result >= 0 )
			;~ return result
	}
	;Show UAC prompt and run elevated
	if(!A_IsAdmin && !NonElevated)
	{		
		If(RunAsAdmin(Target, args, WorkingDir)) ;UAC prompt confirmed
			return 0
	}
	;Still here, error
	Msgbox Error launching %Target%
}

/*
RunAsUser(Command, WorkingDirectory)
{
	static STARTUPINFO := "DWORD cb,LPTSTR lpReserved,LPTSTR lpDesktop,LPTSTR lpTitle,DWORD dwX,DWORD dwY,DWORD dwXSize,DWORD dwYSize,DWORD dwXCountChars,DWORD dwYCountChars,DWORD dwFillAttribute,DWORD dwFlags,WORD wShowWindow,WORD cbReserved2,LPBYTE lpReserved2,HANDLE hStdInput,HANDLE hStdOutput,HANDLE hStdError"
	static PROCESS_INFORMATION := "HANDLE hProcess, HANDLE hThread, DWORD dwProcessId, DWORD dwThreadId"
	hModule := DllCall("LoadLibrary", Str, "Advapi32.dll") 
	
	; OpenProcess - http://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx 
	; PROCESS_QUERY_INFORMATION = 0x0400 
	hProcess := DllCall(   "Kernel32.dll\OpenProcess", UInt, 0x0400, Int, 0, UInt, DllCall("Kernel32.dll\GetCurrentProcessId"), "Ptr") 
	;~ MsgBox open process: %A_LastError%, %hProcess%
	; OpenProcessToken - http://msdn.microsoft.com/en-us/library/windows/desktop/aa379295(v=vs.85).aspx 
	; TOKEN_ASSIGN_PRIMARY = 0x0001 
	; TOKEN_DUPLICATE = 0x0002 
	; TOKEN_QUERY = 0x0008 
	result := DllCall(   "Advapi32.dll\OpenProcessToken", Ptr, hProcess, UInt, 0x0001 | 0x0002 | 0x0008, PtrP, hToken) 
	;~ MsgBox OpenProcessToken: %A_LastError%, %result%
	; CreateRestrictedToken - http://msdn.microsoft.com/en-us/library/Aa446583 
	; LUA_TOKEN = 0x4 
	result := DllCall(   "Advapi32.dll\CreateRestrictedToken", Ptr, hToken, UInt, 0x4, UInt, 0, Ptr, 0, UInt, 0, Ptr, 0, UInt, 0, Ptr, 0, PtrP, hResToken) 
	;~ MsgBox CreateRestrictedToken: %A_LastError%, %result%
	
	; Assuming 32bit pointer size 
	;~ VarSetCapacity(sInfo, 68, 0) 
	;~ VarSetCapacity(pInfo, 16, 0) 
	
	sInfo := new _Struct(STARTUPINFO)
	sInfo.cb := sizeof(STARTUPINFO)
	sInfo.lpDesktop := "winsta0\default"
	pInfo := new _Struct(PROCESS_INFORMATION)
	;~ NumPut(68, sInfo, 0, "UInt") 
	;~ NumPut("winsta0\\default", sInfo, 8, "Str") 
	
	; CreateProcessAsUser - http://msdn.microsoft.com/en-us/library/ms682429 
	; NORMAL_PRIORITY_CLASS = 0x00000020 
	;~ VarSetCapacity(name, 1024)
	result := DllCall(   "Advapi32.dll\CreateProcessAsUser" , Ptr, hResToken, PtrP, 0, Str, "C:\Windows\system32\cmd.exe", Ptr, 0, Ptr, 0, Int, 0, UInt, 0x00000020, Ptr, 0, Ptr, 0, PtrP, sInfo, PtrP, pInfo)
	MsgBox % "result: " result "`nerrorLevel: " ErrorLevel "`nLast error: " A_LastError "`nCommand: " Command "`nWorking directory: " WorkingDirectory
	DllCall("CloseHandle", PTR, hProcess)
	DllCall("CloseHandle", PTR, hToken)
	DllCall("CloseHandle", PTR, sInfo.hStdInput)
	DllCall("CloseHandle", PTR, sInfo.hStdOutput)
	DllCall("CloseHandle", PTR, sInfo.hStdError)
	DllCall("CloseHandle", PTR, pInfo.hProcess)
	DllCall("CloseHandle", PTR, pInfo.hThread)
	return pInfo.dwProcessId
}
*/
RunAsUser(Target, Arguments, WorkingDirectory)
{
	static TASK_TRIGGER_REGISTRATION := 7   ; trigger on registration. 
	static TASK_ACTION_EXEC := 0  ; specifies an executable action. 
	static TASK_CREATE := 2
	static TASK_RUNLEVEL_LUA := 0
	static TASK_LOGON_INTERACTIVE_TOKEN := 3
	objService := ComObjCreate("Schedule.Service") 
	objService.Connect() 

	objFolder := objService.GetFolder("\") 
	objTaskDefinition := objService.NewTask(0) 

	principal := objTaskDefinition.Principal 
	principal.LogonType := TASK_LOGON_INTERACTIVE_TOKEN    ; Set the logon type to TASK_LOGON_PASSWORD 
	principal.RunLevel := TASK_RUNLEVEL_LUA  ; Tasks will be run with the least privileges. 

	colTasks := objTaskDefinition.Triggers
	objTrigger := colTasks.Create(TASK_TRIGGER_REGISTRATION) 
	endTime += 1, Minutes  ;end time = 1 minutes from now 
	FormatTime,endTime,%endTime%,yyyy-MM-ddTHH`:mm`:ss
	objTrigger.EndBoundary := endTime
	colActions := objTaskDefinition.Actions 
	objAction := colActions.Create(TASK_ACTION_EXEC) 
	objAction.ID := "7plus run" 
	objAction.Path := Target
	objAction.Arguments := Arguments
	objAction.WorkingDirectory := WorkingDirectory ? WorkingDirectory : A_WorkingDir
	objInfo := objTaskDefinition.RegistrationInfo
	objInfo.Author := "7plus" 
	objInfo.Description := "Runs a program as non-elevated user" 
	objSettings := objTaskDefinition.Settings 
	objSettings.Enabled := True 
	objSettings.Hidden := False 
	objSettings.DeleteExpiredTaskAfter := "PT0S"
	objSettings.StartWhenAvailable := True 
	objSettings.ExecutionTimeLimit := "PT0S"
	objSettings.DisallowStartIfOnBatteries := False
	objSettings.StopIfGoingOnBatteries := False
	objFolder.RegisterTaskDefinition("", objTaskDefinition, TASK_CREATE , "", "", TASK_LOGON_INTERACTIVE_TOKEN ) 
}
RunAsAdmin(target, args, WorkingDir)
{
	uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, target, str, args, str, WorkingDir, int, 1)
	return uacrep = 42 ;UAC dialog confirmed
}