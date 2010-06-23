;Generic Window Filter
WindowFilter_ReadXML(WindowFilterObject, WindowFilterFileHandle)
{
	WindowFilterObject.WindowMatchType := xpath(WindowFilterFileHandle, "/WindowMatchType/Text()")
	WindowFilterObject.Filter := xpath(WindowFilterFileHandle, "/Filter/Text()")
}

WindowFilter_WriteXML(WindowFilterObject, ByRef WindowFilterFileHandle, Path)
{
	xpath(WindowFilterFileHandle, Path "WindowMatchType[+1]/Text()", WindowFilterObject.WindowMatchType)
	xpath(WindowFilterFileHandle, Path "Filter[+1]/Text()", WindowFilterObject.Filter)
}
;Get a matching window handle from a WindowFilter object
WindowFilter_Get(WindowFilter)
{
	if(WindowFilter.WindowMatchType = "Program")
	{
		d = `n  ; string separator
		s := 4096  ; size of buffers and arrays (4 KB)

		Process, Exist  ; sets ErrorLevel to the PID of this running script
		; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
		h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
		; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
		DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
		VarSetCapacity(ti, 16, 0)  ; structure of privileges
		NumPut(1, ti, 0)  ; one entry in the privileges array...
		; Retrieves the locally unique identifier of the debug privilege:
		DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
		NumPut(luid, ti, 4, "int64")
		NumPut(2, ti, 12)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
		; Update the privileges of this process with the new access token:
		DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
		DllCall("CloseHandle", "UInt", h)  ; close this process handle to save memory

		hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the libaray
		s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
		c := 0  ; counter for process idendifiers
		DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
		Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
		{
			id := NumGet(a, A_Index * 4)
			; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
			h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
			VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
			e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "UInt", s)
			DllCall("CloseHandle", "UInt", h)  ; close process handle to save memory
			if (n && e)  ; if image is not null add to list:
			{
				if(n = WindowFilter.Filter && hwnd:=WinExist("ahk_pid " id))
					return hwnd
			}
		}
		DllCall("FreeLibrary", "UInt", hModule)  ; unload the library to free memory
		return 0
	}
	else if(WindowFilter.WindowMatchType = "class")
		return WinExist("ahk_class " WindowFilter.Filter)
	else if(WindowFilter.WindowMatchType = "title")
		return WinExist(Window.Filter)
	else if(WindowFilter.WindowMatchType = "Active")
		return WinExist("A")
	else if(WindowFilter.WindowMatchType = "UnderMouse")
	{
		MouseGetPos,,,UnderMouse
		return UnderMouse
	}
	return 0
}
;Generic Window Filter match function. Filter is optional, it is used to check if the trigger is correct if used on a trigger window filter
WindowFilter_Matches(WindowFilter, TargetWindow, TriggerFilter = "")
{
	if(!TriggerFilter || WindowFilter.type = TriggerFilter.type)
	{
		if(TargetWindow = "A")
			TargetWindow := WinExist("A")
		else if(TargetWindow = "UnderMouse")
			MouseGetPos,,,TargetWindow
		if(WindowFilter.WindowMatchType = "Program")
		{
			if(GetProcessName(TargetWindow) = WindowFilter.Filter)
				return true
		}
		else if(WindowFilter.WindowMatchType = "Class")
		{
			if(WinGetClass("ahk_id " TargetWindow) = WindowFilter.Filter)
				return true
		}
		else if(WindowFilter.WindowMatchType = "Title")
		{
			if(strStartsWith(WinGetTitle("ahk_id " TargetWindow),WindowFilter.Filter))
				return true			
		}
		else if(WindowFilter.WindowMatchType = "Active")
		{
			if(WinActive("ahk_id " TargetWindow))
				return true
		}
		else if(WindowFilter.WindowMatchType = "UnderMouse")
		{			
			MouseGetPos,,,UnderMouse
			if(UnderMouse = TargetWindow)
				return true
		}
	}
	return false
}

WindowFilter_DisplayString(WindowFilter)
{
	return WindowFilter.WindowMatchType " " WindowFilter.Filter
}