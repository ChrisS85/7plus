;Generic Window Filter interface for subevents. They can implement this interface like this:
;static _ImplementsWindowFilter := ImplementWindowFilterInterface(CSubEvent)
;It's important to use a "_" or "tmp" at the start of the name to mark this property as temporary so it won't be saved.
ImplementWindowFilterInterface(WindowFilter)
{
	WindowFilter.WindowMatchType := "Specific Window"
	WindowFilter.WindowFilterClass := ""
	WindowFilter.WindowFilterExecutable := ""
	WindowFilter.WindowFilterTitle := ""
	if(WindowFilter.HasKey("__Class"))
	{
		WindowFilter.WindowFilterGet := Func("WindowFilter_Get")
		WindowFilter.WindowFilterMatches := Func("WindowFilter_Matches")
		WindowFilter.WindowFilterDisplayString := Func("WindowFilter_DisplayString")
		WindowFilter.WindowFilterGUIShow := Func("WindowFilter_GUIShow")
		WindowFilter.WindowFilterGUISubmit := Func("WindowFilter_GUISubmit")
	}
}
;Get a matching window handle from a WindowFilter object
WindowFilter_Get(WindowFilter)
{
	DetectHiddenWindows, On
	if(WindowFilter.WindowMatchType = "Any Window")
		return WinExist("A") ;Just return active window, shouldn't matter
	if(WindowFilter.WindowMatchType = "Specific Window")
	{
		WindowFilterResult := true
		if(WindowFilter.WindowFilterExecutable)
		{
			WindowFilterExecutableResult := false
			d = `n  ; string separator
			s := 4096  ; size of buffers and arrays (4 KB)

			Process, Exist  ; sets ErrorLevel to the PID of this running script
			; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
			h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
			; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
			DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "UIntP", t)
			VarSetCapacity(ti, 16, 0)  ; structure of privileges
			NumPut(1, ti, 0)  ; one entry in the privileges array...
			; Retrieves the locally unique identifier of the debug privilege:
			DllCall("Advapi32.dll\LookupPrivilegeValue", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
			NumPut(luid, ti, 4, "int64")
			NumPut(2, ti, 12)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
			; Update the privileges of this process with the new access token:
			DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
			DllCall("CloseHandle", "Ptr", h)  ; close this process handle to save memory

			hModule := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")  ; increase performance by preloading the libaray
			s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
			c := 0  ; counter for process idendifiers
			DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
			Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
			{
				id := NumGet(a, A_Index * 4)
				; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
				h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
				VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
				e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "UInt", 0, "Str", n, "UInt", s)
				DllCall("CloseHandle", "Ptr", h)  ; close process handle to save memory
				if (n && e)  ; if image is not null add to list:
				{
					if(n = WindowFilter.WindowFilterExecutable && hwnd:=WinExist("ahk_pid " id))
					{
						WindowFilterExecutableResult := hwnd
						break
					}
				}
			}
			DllCall("FreeLibrary", "Ptr", hModule)  ; unload the library to free memory
			WindowFilterResult := WindowFilterExecutableResult
		}
		if(WindowFilter.WindowFilterClass)
		{
			WindowFilterClassResult := WinExist("ahk_class " WindowFilter.WindowFilterClass)
			if(WindowFilterResult > 0 && WindowFilterResult != WindowFilterClassResult) ;Different windows, or one didn't match
				WindowFilterResult := 0
		}
		if(WindowFilter.WindowFilterTitle)
		{
			WindowFilterTitleResult := WinExist(WindowFilter.WindowFilterTitle)
			if(WindowFilterResult > 0 && WindowFilterResult != WindowFilterTitleResult) ;Different windows, or one didn't match
				WindowFilterResult := 0
		}
		return WindowFilterResult
	}
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
	global WindowList
	if(!TriggerFilter || WindowFilter.type = TriggerFilter.type)
	{
		if(TargetWindow = "A")
			TargetWindow := WinExist("A")		
		if(TargetWindow = "UnderMouse")
			MouseGetPos,,,TargetWindow
		class := WinGetClass("ahk_id " TargetWindow)
		if(!class)
			class := WindowList[TargetWindow].class
		title := WinGetTitle("ahk_id " TargetWindow)
		if(!title)
			title := WindowList[TargetWindow].title
		if(WindowFilter.WindowMatchType = "Any Window")
			return true
		if(WindowFilter.WindowMatchType = "Specific Window")
		{
			return ((!WindowFilter.WindowFilterExecutable || GetProcessName(TargetWindow) = WindowFilter.WindowFilterExecutable)
					&&(!WindowFilter.WindowFilterClass || class = WindowFilter.WindowFilterClass)
					&&(!WindowFilter.WindowFilterTitle || InStr(title,WindowFilter.WindowFilterTitle) = 1))
		}
		else if(WindowFilter.WindowMatchType = "Active")
		{
			if(!TargetWindow || WinActive("ahk_id " TargetWindow))
				return true
		}
		else if(WindowFilter.WindowMatchType = "UnderMouse")
		{
			MouseGetPos, , , UnderMouse
			if(!TargetWindow || UnderMouse = TargetWindow)
				return true
		}
	}
	return false
}

WindowFilter_DisplayString(WindowFilter)
{
	string := WindowFilter.WindowMatchType
	if(WindowFilter.WindowMatchType = "Specific Window")
	{
		if(WindowFilter.WindowFilterExecutable)
			string .= " Executable " WindowFilter.WindowFilterExecutable 
		if(WindowFilter.WindowFilterClass)
			string .= " Class " WindowFilter.WindowFilterClass 
		if(WindowFilter.WindowFilterTitle)
			string .= " Title " WindowFilter.WindowFilterTitle 
	}
	return string
}

WindowFilter_GuiShow(WindowFilter, WindowFilterGUI,GoToLabel="")
{
	outputdebug gui show
	if(GoToLabel = "")
	{
		WindowFilter.tmpWindowFilterGUI := WindowFilterGUI
		WindowFilter.tmpPreviousSelection := ""
		outputdebug % Exploreobj(WindowFilter)
		WindowFilter.AddControl(WindowFilterGUI, "DropDownList", "WindowMatchType", "Specific Window|Any Window|Active|UnderMouse", "WindowFilter_SelectionChange", "Match Type:")
		x := WindowFilterGUI.x
		y := WindowFilterGUI.y
		w := 200
		WindowFilter_GuiShow(WindowFilter, "","WindowFilter_SelectionChange")
	}
	else if(GoToLabel = "WindowFilter_SelectionChange")
	{
		DropDown_WindowMatchType := WindowFilter.tmpWindowFilterGUI.DropDown_WindowMatchType
		ControlGetText, WindowMatchType, , ahk_id %DropDown_WindowMatchType%
		if(WindowMatchType = "Specific Window")
		{
			if(WindowMatchType != WindowFilter.tmpPreviousSelection) ;Create specific controls and store values
			{
				WindowFilter.AddControl(WindowFilter.tmpWindowFilterGUI, "Edit", "WindowFilterClass", "", "", "By class:", "Select Class", "WindowFilter_SelectClass")
				WindowFilter.AddControl(WindowFilter.tmpWindowFilterGUI, "Edit", "WindowFilterExecutable", "", "", "By executable:", "Select executable", "WindowFilter_SelectExecutable")
				WindowFilter.AddControl(WindowFilter.tmpWindowFilterGUI, "Edit", "WindowFilterTitle", "", "", "By title:", "Select Title", "WindowFilter_SelectTitle")
			}
		}
		else
		{
			if(WindowFilter.tmpPreviousSelection = "Specific Window") ;Destroy specific controls and store values
			{
				Desc_WindowFilterClass := WindowFilter.tmpWindowFilterGUI.Remove("Desc_WindowFilterClass")
				Edit_WindowFilterClass := WindowFilter.tmpWindowFilterGUI.Remove("Edit_WindowFilterClass")
				Button1_WindowFilterClass := WindowFilter.tmpWindowFilterGUI.Remove("Button1_WindowFilterClass")
								
				ControlGetText, WindowFilterClass, , ahk_id %Edit_WindowFilterClass%
				WindowFilter.WindowFilterClass := WindowFilterClass
				
				WinKill, ahk_id %Desc_WindowFilterClass%
				WinKill, ahk_id %Edit_WindowFilterClass%
				WinKill, ahk_id %Button1_WindowFilterClass%
				
				Desc_WindowFilterExecutable := WindowFilter.tmpWindowFilterGUI.Remove("Desc_WindowFilterExecutable")
				Edit_WindowFilterExecutable := WindowFilter.tmpWindowFilterGUI.Remove("Edit_WindowFilterExecutable")
				Button1_WindowFilterExecutable := WindowFilter.tmpWindowFilterGUI.Remove("Button1_WindowFilterExecutable")
								
				ControlGetText, WindowFilterExecutable, , ahk_id %Edit_WindowFilterExecutable%
				WindowFilter.WindowFilterExecutable := WindowFilterExecutable
				
				WinKill, ahk_id %Desc_WindowFilterExecutable%
				WinKill, ahk_id %Edit_WindowFilterExecutable%
				WinKill, ahk_id %Button1_WindowFilterExecutable%
				
				Desc_WindowFilterTitle := WindowFilter.tmpWindowFilterGUI.Remove("Desc_WindowFilterTitle")
				Edit_WindowFilterTitle := WindowFilter.tmpWindowFilterGUI.Remove("Edit_WindowFilterTitle")
				Button1_WindowFilterTitle := WindowFilter.tmpWindowFilterGUI.Remove("Button1_WindowFilterTitle")
								
				ControlGetText, WindowFilterTitle, , ahk_id %Edit_WindowFilterTitle%
				WindowFilter.WindowFilterTitle := WindowFilterTitle
				
				WinKill, ahk_id %Desc_WindowFilterTitle%
				WinKill, ahk_id %Edit_WindowFilterTitle%
				WinKill, ahk_id %Button1_WindowFilterTitle%
				
				WindowFilter.tmpWindowFilterGUI.y := WindowFilter.tmpWindowFilterGUI.y - 90
			}
		}
		WindowFilter.tmpPreviousSelection := WindowMatchType
	}
	else if(GoToLabel = "WindowFilter_SelectClass")
	{
		Window := GUI_WindowFinder(WindowFilter.tmpWindowFilterGUI.GUINum)
		Edit_WindowFilterClass := WindowFilter.tmpWindowFilterGUI.Edit_WindowFilterClass
		Class := Window.Class
		if(Class)
			ControlSetText,, %Class%, ahk_id %Edit_WindowFilterClass%
	}
	else if(GoToLabel = "WindowFilter_SelectExecutable")
	{
		Window := GUI_WindowFinder(WindowFilter.tmpWindowFilterGUI.GUINum)
		Edit_WindowFilterExecutable := WindowFilter.tmpWindowFilterGUI.Edit_WindowFilterExecutable
		Executable := Window.Executable
		if(Executable)
			ControlSetText,, %Executable%, ahk_id %Edit_WindowFilterExecutable%
	}
	else if(GoToLabel = "WindowFilter_SelectTitle")
	{
		Window := GUI_WindowFinder(WindowFilter.tmpWindowFilterGUI.GUINum)
		Edit_WindowFilterTitle := WindowFilter.tmpWindowFilterGUI.Edit_WindowFilterTitle
		title := Window.title
		if(Title)
			ControlSetText,, %title%, ahk_id %Edit_WindowFilterTitle%
	}
}
WindowFilter_SelectionChange:
GetCurrentSubEvent().WindowFilterGUIShow("","WindowFilter_SelectionChange")
return
WindowFilter_SelectClass:
GetCurrentSubEvent().WindowFilterGUIShow("","WindowFilter_SelectClass")
return
WindowFilter_SelectExecutable:
GetCurrentSubEvent().WindowFilterGUIShow("","WindowFilter_SelectExecutable")
return
WindowFilter_SelectTitle:
GetCurrentSubEvent().WindowFilterGUIShow("","WindowFilter_SelectTitle")
return

;Window filter uses own GUISubmit function, so it can be executed without storing its ancestor's values
;This is effectively the same as the regular GUISubmit function but only for the WindowFilter values
WindowFilter_GuiSubmit(WindowFilter, WindowFilterGUI)
{
	Desc_WindowMatchType := WindowFilterGUI.Desc_WindowMatchType
	DropDown_WindowMatchType := WindowFilterGUI.DropDown_WindowMatchType
	outputdebug % "gui submit " DropDown_WindowMatchType WinExist("Ahk_id " DropDown_WindowMatchType)
					
	ControlGetText, WindowMatchType, , ahk_id %DropDown_WindowMatchType%
	WindowFilter.WindowMatchType := WindowMatchType
	outputdebug % "matchtype: " windowmatchtype
	WinKill, ahk_id %Desc_WindowMatchType%
	WinKill, ahk_id %DropDown_WindowMatchType%
	
	Desc_WindowFilterClass := WindowFilterGUI.Desc_WindowFilterClass
	Edit_WindowFilterClass := WindowFilterGUI.Edit_WindowFilterClass
	Button1_WindowFilterClass := WindowFilterGUI.Button1_WindowFilterClass
	
	ControlGetText, WindowFilterClass, , ahk_id %Edit_WindowFilterClass%
	WindowFilter.WindowFilterClass := WindowFilterClass
	
	WinKill, ahk_id %Desc_WindowFilterClass%
	WinKill, ahk_id %Edit_WindowFilterClass%
	WinKill, ahk_id %Button1_WindowFilterClass%
	
	Desc_WindowFilterExecutable := WindowFilterGUI.Desc_WindowFilterExecutable
	Edit_WindowFilterExecutable := WindowFilterGUI.Edit_WindowFilterExecutable
	Button1_WindowFilterExecutable := WindowFilterGUI.Button1_WindowFilterExecutable
					
	ControlGetText, WindowFilterExecutable, , ahk_id %Edit_WindowFilterExecutable%
	WindowFilter.WindowFilterExecutable := WindowFilterExecutable
	
	WinKill, ahk_id %Desc_WindowFilterExecutable%
	WinKill, ahk_id %Edit_WindowFilterExecutable%
	WinKill, ahk_id %Button1_WindowFilterExecutable%
	
	Desc_WindowFilterTitle := WindowFilterGUI.Desc_WindowFilterTitle
	Edit_WindowFilterTitle := WindowFilterGUI.Edit_WindowFilterTitle
	Button1_WindowFilterTitle	:= WindowFilterGUI.Button1_WindowFilterTitle
					
	ControlGetText, WindowFilterTitle, , ahk_id %Edit_WindowFilterTitle%
	WindowFilter.WindowFilterTitle := WindowFilterTitle
	
	WinKill, ahk_id %Desc_WindowFilterTitle%
	WinKill, ahk_id %Edit_WindowFilterTitle%
	WinKill, ahk_id %Button1_WindowFilterTitle%
	
	WindowFilterGUI.y := WindowFilterGUI.y - 60
	WindowFilterGUI.Remove("tmpWindowFilterGUI")
	WindowFilterGUI.Remove("tmpPreviousSelection")
	WindowFilterGUI.Remove("Desc_WindowMatchType")
	WindowFilterGUI.Remove("DropDown_WindowMatchType")
	WindowFilterGUI.Remove("Desc_WindowFilterClass")
	WindowFilterGUI.Remove("Edit_WindowFilterClass")
	WindowFilterGUI.Remove("Button1_WindowFilterClass")
	WindowFilterGUI.Remove("Desc_WindowFilterExecutable")
	WindowFilterGUI.Remove("Edit_WindowFilterExecutable")
	WindowFilterGUI.Remove("Button1_WindowFilterExecutable")
	WindowFilterGUI.Remove("Desc_WindowFilterTitle")
	WindowFilterGUI.Remove("Edit_WindowFilterTitle")
	WindowFilterGUI.Remove("Button1_WindowFilterTitle")
}
