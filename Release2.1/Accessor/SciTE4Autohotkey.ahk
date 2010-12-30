Accessor_SciTE4AutoHotkey_Init(ByRef SciTE4AutoHotkey, Settings)
{	
	path := GetSciTE4AutoHotkeyPath()
	if(path)
		SciTE4AutoHotkey.Icon := ExtractIcon(path, 1, 64)
	SciTE4AutoHotkey.Settings.Keyword := "sc"
	SciTE4AutoHotkey.DefaultKeyword := "sc"
	SciTE4AutoHotkey.KeywordOnly := false
	SciTE4AutoHotkey.MinChars := 0 ;This is actually 2, but not when SciTE4AutoHotkey is active
	SciTE4AutoHotkey.MRUList := Array()
	SciTE4AutoHotkey.OKName := "Open Tab"
	SciTE4AutoHotkey.Settings.FuzzySearch := Settings.FuzzySearch
	SciTE4AutoHotkey.Description := "Activate a specific SciTE4AutoHotkey tab by typing a part of its name. This plugin restores the text `nwhich was previously entered when the current tab was last active. `nThis way you can quicly switch between the most used tabs."
	SciTE4AutoHotkey.HasSettings := True
}
Accessor_SciTE4AutoHotkey_ShowSettings(SciTE4AutoHotkey, PluginSettings, PluginGUI)
{
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
}
Accessor_SciTE4AutoHotkey_IsInSinglePluginContext(SciTE4AutoHotkey, Filter, LastFilter)
{
}
Accessor_SciTE4AutoHotkey_GetDisplayStrings(SciTE4AutoHotkey, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
}
Accessor_SciTE4AutoHotkey_OnAccessorOpen(SciTE4AutoHotkey, Accessor)
{
	global AccessorEdit, AccessorListView
	SciTE4AutoHotkey.List1 := GetListOfOpenSciTE4AutoHotkeyTabs()
	SciTE4AutoHotkey.Priority := SciTE4AutoHotkey.Settings.BasePriority
	if(!SciTE4AutoHotkey.Icon)
	{
		path := GetSciTE4AutoHotkeyPath()
		SciTE4AutoHotkey.Icon := ExtractIcon(path, 1, 64)
	}
	;if SciTEWindow is open and there is an entry with the last usd command for the current tab, put it in edit box
	if(WinExist("ahk_class SciTEWindow") = Accessor.PreviousWindow)
	{
		SciTE4AutoHotkey.Priority := 10000
		if(index := SciTE4AutoHotkey.MRUList.indexOfSubItem("Path", Path := GetSciTE4AutoHotkeyActiveTab()))
		{
			GUINum := Accessor.GUINum
			if(!GUINum)
				return
			Gui, %GUINum%: Default
			SciTE4AutoHotkey.Waiting := true
			GuiControl,, AccessorEdit, % SciTE4AutoHotkey.MRUList[index].Command
			hwndEdit := Accessor.hwndEdit
			SendMessage, 0xC1, -1,,, AHK_ID %hwndEdit%  ; EM_LINEINDEX (Gets index number of line)
			CaretTo := ErrorLevel
			SendMessage, 0xB1, 0, CaretTo,, AHK_ID %hwndEdit% ;EM_SETSEL
			
			while(SciTE4AutoHotkey.Waiting || !Accessor.ListViewReady)
				Sleep 10
			Gui, ListView, AccessorListView
			Entry := SciTE4AutoHotkey.MRUList[index].Entry
			Loop % LV_GetCount()
			{
				LV_GetText(Path,A_Index,4)
				LV_GetText(Type,A_Index,5)
				if(Path = Entry && Type = "SciTE")
				{
					LV_Modify(A_Index, "Select")
					break
				}
			}
		}
	}
}
Accessor_SciTE4AutoHotkey_OnAccessorClose(SciTE4AutoHotkey, Accessor)
{
}
Accessor_SciTE4AutoHotkey_OnExit(SciTE4AutoHotkey)
{
	DestroyIcon(SciTE4AutoHotkey.Icon)
}
Accessor_SciTE4AutoHotkey_FillAccessorList(SciTE4AutoHotkey, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	if(SciTE4AutoHotkey.Waiting)
	{
		SciTE4AutoHotkey.Waiting := false
	}
	if(!WinActive("ahk_class SciTEWindow") && strLen(Filter) < 2 && !KeywordSet)
		return
	if(!SciTE4AutoHotkey.List1.len())
		return
	ImageList_ReplaceIcon(Accessor.ImageListID, -1, SciTE4AutoHotkey.Icon)
	IconCount++
	if(!Filter && KeywordSet)
	{
		Loop % SciTE4AutoHotkey.List1.len()
		{
			Path := SciTE4AutoHotkey.List1[A_Index]
			SplitPath, Path, Name
			Accessor.List.append(Object("Title",Name,"Path",Path, "Type","SciTE", "Detail1", "SciTE4AutoHotkey", "Icon", IconCount))
		}
		return
	}
	InStrList := Array()
	FuzzyList := Array()
	Loop % SciTE4AutoHotkey.List1.len()
	{
		Path := SciTE4AutoHotkey.List1[A_Index]
		SplitPath, Path, Name
		pos := InStr(Name, Filter)
		if(pos = 1)
			Accessor.List.append(Object("Title",Name,"Path",Path, "Type","SciTE", "Detail1", "NP++", "Icon", IconCount))
		else if(pos > 1)
			InStrList.append(Object("Title",Name,"Path",Path, "Type","SciTE", "Detail1", "SciTE4AutoHotkey", "Icon", IconCount))
		else if(SciTE4AutoHotkey.Settings.FuzzySearch && FuzzySearch(Name,Filter) < 0.3)
			FuzzyList.append(Object("Title",Name,"Path",Path, "Type","SciTE", "Detail1", "SciTE4AutoHotkey", "Icon", IconCount))
	}
	Accessor.List.Extend(InStrList)
	Accessor.List.Extend(FuzzyList)
	return
}
Accessor_SciTE4AutoHotkey_PerformAction(SciTE4AutoHotkey, Accessor, AccessorListEntry)
{
	global AccessorEdit
	if(WinExist("ahk_class SciTEWindow") = Accessor.PreviousWindow)
	{
		GUINum := Accessor.GUINum
		if(GUINum)
		{
			Gui, %GUINum%: Default
			GuiControlGet, Filter, , AccessorEdit
			if(!(index := SciTE4AutoHotkey.MRUList.indexOfSubItem("Path", ActiveTab := GetSciTE4AutoHotkeyActiveTab())))
				SciTE4AutoHotkey.MRUList.append(Object("Path", ActiveTab, "Command", Filter, "Entry", AccessorListEntry.Path))
			else
			{
				SciTE4AutoHotkey.MRUList[index].Command := Filter
				SciTE4AutoHotkey.MRUList[index].Entry := AccessorListEntry.Path
			}
		}
	}
	else
		ActivateSciTE4AutoHotkeyTab(SciTE4AutoHotkey.List1.indexOf(AccessorListEntry.Path))
	return
}
Accessor_SciTE4AutoHotkey_ListViewEvents(SciTE4AutoHotkey, AccessorListEntry)
{
}
Accessor_SciTE4AutoHotkey_EditEvents(SciTE4AutoHotkey, AccessorListEntry, Filter, LastFilter)
{
	return false
}
Accessor_SciTE4AutoHotkey_OnKeyDown(SciTE4AutoHotkey, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global Accessor
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		AccessorCopyField("Path")
		return true
	}
	return 0
}
Accessor_SciTE4AutoHotkey_SetupContextMenu(SciTE4AutoHotkey, AccessorListEntry)
{
	Menu, AccessorMenu, add, Open Tab,AccessorOK
	Menu, AccessorMenu, Default,Open Tab
	Menu, AccessorMenu, add, Open File,SciTE4AutoHotkeyOpenFile
	Menu, AccessorMenu, add, Open file path in explorer,AccessorOpenExplorer
	Menu, AccessorMenu, add, Open file path in CMD,AccessorOpenCMD
	Menu, AccessorMenu, add, Copy file path (CTRL+C),AccessorCopyPath
	Menu, AccessorMenu, add, Explorer context menu, AccessorExplorerContextMenu
}
SciTE4AutoHotkeyOpenFile:
SciTE4AutoHotkeyOpenFile()
return

SciTE4AutoHotkeyOpenFile()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	Run(Accessor.List[id].Path)
}
ActivateSciTE4AutoHotkeyTab(Index)
{
	hwnd := WinExist("ahk_class SciTEWindow")
	if(!hwnd)
		return
	scite := ComObjActive("SciTE4AHK.Application")
	scite.SwitchToTab(Index - 1) ; the index is zero-based
}
GetListOfOpenSciTE4AutoHotkeyTabs()
{
	hwnd := WinExist("ahk_class SciTEWindow")
	if(!hwnd) ;SciTEWindow not running, empty list
		return Array()
	list := Array()
	scite := ComObjActive("SciTE4AHK.Application")
	tabs := scite.Tabs.Array 
	; tabs is a SafeArray containing the file names 
	Loop, % tabs.MaxIndex() + 1 
	   list.append(tabs[A_Index-1])
	return list
}
GetSciTE4AutoHotkeyPath()
{
	hwnd := WinExist("ahk_class SciTEWindow")
	if(!hwnd)
		return ""
	WinGet, pid, PID, ahk_id %hwnd%
	Path := GetModuleFileNameEx(pid)
	return Path
}
;May only be used while Accessor window is visible
GetSciTE4AutoHotkeyActiveTab()
{
	global AccessorPlugins
	SciTE4AutoHotkey := AccessorPlugins.SubItem("Type", "SciTE4AutoHotkey")
	hwnd := WinExist("ahk_class SciTEWindow")
	if(!hwnd)
		return ""		
	scite := ComObjActive("SciTE4AHK.Application")
	return scite.CurrentFile
}