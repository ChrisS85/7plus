Accessor_WindowSwitcher_Init(ByRef WindowSwitcher, PluginSettings)
{
	WindowSwitcher.Settings.Keyword := "switch"
	WindowSwitcher.DefaultKeyword := "switch"
	WindowSwitcher.KeywordOnly := false
	WindowSwitcher.MinChars := 0
	WindowSwitcher.OKName := "Activate"
	WindowSwitcher.Settings.FuzzySearch := PluginSettings.HasKey("FuzzySearch") ? PluginSettings.FuzzySearch : 0
	WindowSwitcher.Settings.IgnoreFileExtensions := PluginSettings.HasKey("IgnoreFileExtensions") ? PluginSettings.IgnoreFileExtensions : 1
	WindowSwitcher.Description := "Activate windows by typing a part of their title or their executable filename. `nThis also shows CPU usage, shows/sets Always on Top state and `nallows to close and kill processes."
	WindowSwitcher.HasSettings := True
}
Accessor_WindowSwitcher_ShowSettings(WindowSwitcher, PluginSettings, PluginGUI)
{
	AddControl(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
	AddControl(PluginSettings, PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:")
	AddControl(PluginSettings, PluginGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
	AddControl(PluginSettings, PluginGUI, "Checkbox", "IgnoreFileExtensions", "Ignore .exe extension in program paths", "", "")	
}
Accessor_WindowSwitcher_GetDisplayStrings(WindowSwitcher, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	Path := AccessorListEntry.ExeName
	Detail1 := "CPU: " AccessorListEntry.CPU "%"
	Detail2 := AccessorListEntry.OnTop
}
Accessor_WindowSwitcher_IsInSinglePluginContext(WindowSwitcher, Filter, LastFilter)
{
	return false
}
Accessor_WindowSwitcher_OnAccessorOpen(WindowSwitcher, Accessor)
{
	WindowSwitcher.List := GetWindowInfo()
	SetTimer, UpdateTimes, 1000	
	WindowSwitcher.Priority := WindowSwitcher.Settings.BasePriority
}
Accessor_WindowSwitcher_OnAccessorClose(WindowSwitcher, Accessor)
{
	;This is apparently not desired for icons obtained by WM_GETICON or GetClassLong since they are shared? See http://msdn.microsoft.com/en-us/library/windows/desktop/ms648063(v=vs.85).aspx
	;~ if(IsObject(WindowSwitcher.List))
		;~ for index, ListEntry in WindowSwitcher.List
			;~ if(ListEntry.Icon != Accessor.GenericIcons.Application)
				;~ DestroyIcon(ListEntry.Icon)
	SetTimer, UpdateTimes, Off
}
Accessor_WindowSwitcher_FillAccessorList(WindowSwitcher, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	strippedFilter := WindowSwitcher.Settings.IgnoreFileExtensions ? strTrimRight(Filter, ".exe") : Filter
	FuzzyList := Array()
	Loop % WindowSwitcher.List.MaxIndex()
	{
		x := 0
		window := WindowSwitcher.List[A_Index]
		ExeName := WindowSwitcher.Settings.IgnoreFileExtensions ? strTrimRight(window.ExeName,".exe") : window.ExeName
		if(x := (Filter = "" || InStr(window.Title,Filter) || InStr(ExeName,strippedFilter)) || (WindowSwitcher.Settings.FuzzySearch && FuzzySearch(ExeName,strippedFilter) < 0.4))
		{
			if((IconIndex := ImageList_ReplaceIcon(Accessor.ImageListID, -1, window.Icon)) != -1)
				IconCount++
			else
				IconIndex := 0
			if(x)
				Accessor.List.Insert(Object("Icon", IconIndex + 1, "Title", window.Title, "Path", window.Path, "ExeName", window.ExeName, "CPU", window.CPU, "OnTop", window.OnTop, "Type", "WindowSwitcher", "PID", window.PID, "hwnd", window.hwnd))			
			else
				FuzzyList.Insert(Object("Icon", IconIndex + 1, "Title", window.Title, "Path", window.Path, "ExeName", window.ExeName, "CPU", window.CPU, "OnTop", window.OnTop, "Type", "WindowSwitcher", "PID", window.PID, "hwnd", window.hwnd))			
		}
	}
	Accessor.List.extend(FuzzyList)
}
Accessor_WindowSwitcher_PerformAction(WindowSwitcher, Accessor, AccessorListEntry)
{
	WinActivate % "ahk_id " AccessorListEntry.hwnd
}
Accessor_WindowSwitcher_ListViewEvents(WindowSwitcher, AccessorListEntry)
{
}
Accessor_WindowSwitcher_EditEvents(WindowSwitcher, AccessorListEntry, Filter, LastFilter)
{
	return true
}
Accessor_WindowSwitcher_SetupContextMenu(WindowSwitcher, AccessorListEntry)
{
	Menu, AccessorMenu, add, Activate window,AccessorOK
	Menu, AccessorMenu, Default,Activate window			
	Menu, AccessorMenu, add, End process,WindowSwitcherEndProcess
	Menu, AccessorMenu, add, Close window,WindowSwitcherCloseWindow
	Menu, AccessorMenu, add, Open executable path in explorer,AccessorOpenExplorer
	Menu, AccessorMenu, add, Open executable path in CMD,AccessorOpenCMD
	Menu, AccessorMenu, add, Copy executable path (CTRL+C), AccessorCopyPath
	
	hwnd := window.hwnd
	WinGet, es, ExStyle, ahk_id %hwnd%
	Menu, AccessorMenu, add, Always on top,WindowSwitcherAlwaysOnTop
	if(es & 0x8 > 0)
		Menu, AccessorMenu, Check, Always on top
}
Accessor_WindowSwitcher_OnExit(WindowSwitcher)
{
}
WindowSwitcherEndProcess:
WindowSwitcherEndProcess()
return
WindowSwitcherCloseWindow:
WindowSwitcherCloseWindow()
return
WindowSwitcherAlwaysOnTop:
WindowSwitcherAlwaysOnTop()
return
WindowSwitcherEndProcess()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	hwnd := Accessor.List[id].hwnd
	WinKill ahk_id %hwnd%
	AccessorClose()
}
WindowSwitcherCloseWindow()
{
	global Accessor, AccessorListView,AccessorPlugins
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	hwnd := Accessor.List[id].hwnd
	PostMessage, 0x112, 0xF060,,, ahk_id %hwnd%
	AccessorClose()
}
WindowSwitcherAlwaysOnTop()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	hwnd := Accessor.List[id].hwnd
	WinSet, AlwaysOnTop, Toggle, ahk_id %hwnd%
	if(Accessor.List[id].OnTop)
		Accessor.List[id].OnTop := ""
	else
		Accessor.List[id].OnTop := "OnTop"
	LV_Modify(selected, "Col6", Accessor.List[id].OnTop)
}

UpdateTimes:
UpdateCPUTimes()
return

UpdateCPUTimes()
{
	global AccessorListView, Accessor, AccessorPlugins
	GUINum := Accessor.GUINum
	if(!GuiNum)
		return
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	Loop % LV_GetCount()
	{
		LV_GetText(index,A_Index,2)
		if(Accessor.List[index].Type = "WindowSwitcher")
		{
			Accessor.List[index].oldKrnlTime := Accessor.List[index].newKrnlTime
			Accessor.List[index].oldUserTime := Accessor.List[index].newUserTime

			hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", Accessor.List[index].PID, "Ptr")
			DllCall("GetProcessTimes", "Ptr", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime, "Ptr")
			DllCall("CloseHandle", "Ptr", hProc)
			Accessor.List[index].newKrnlTime := newKrnlTime
			Accessor.List[index].newUserTime := newUserTime
			Accessor.List[index].CPU := Round(min(max((Accessor.List[index].newKrnlTime-Accessor.List[index].oldKrnlTime + Accessor.List[index].newUserTime-Accessor.List[index].oldUserTime)/10000000 * 100,0),100), 2)   ; 1sec: 10**7
			WindowSwitcher := AccessorPlugins[AccessorPlugins.FindKeyWithValue("Type", "WindowSwitcher")]
			outputdebug % WindowSwitcher.List[WindowSwitcher.List.FindKeyWithValue("hwnd", Accessor.List[index].hwnd)].CPU
			WindowSwitcher.List[WindowSwitcher.List.FindKeyWithValue("hwnd", Accessor.List[index].hwnd)].CPU := Accessor.List[index].CPU
			; Accessor.List[index].CPU := GetProcessTimes(Accessor.List[index].PID)
			LV_Modify(A_Index,"Col5","CPU: " Accessor.List[index].CPU "%")
		}
	}
	if(usage := Round(GetSystemTimes(),2))
	SB_SetText(" CPU Usage: " usage "%",1,2)
	return
}