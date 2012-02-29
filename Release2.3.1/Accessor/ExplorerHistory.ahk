Accessor_ExplorerHistory_Init(ByRef ExplorerHistory, PluginSettings)
{
	ExplorerHistory.Settings.Keyword := "EH"
	ExplorerHistory.DefaultKeyword := "EH"
	ExplorerHistory.KeywordOnly := false
	ExplorerHistory.MinChars := 2
	ExplorerHistory.OKName := "Open Folder"
	ExplorerHistory.Settings.FuzzySearch := PluginSettings.HasKey("FuzzySearch") ? PluginSettings.FuzzySearch : 0
	ExplorerHistory.Description := "Access the stored Explorer history by typing a part of a folder name."
	ExplorerHistory.HasSettings := True
}
Accessor_ExplorerHistory_ShowSettings(ExplorerHistory, PluginSettings, PluginGUI)
{
	AddControl(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
	AddControl(PluginSettings, PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:")
	AddControl(PluginSettings, PluginGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
}
Accessor_ExplorerHistory_IsInSinglePluginContext(ExplorerHistory, Filter, LastFilter)
{
	return false
}
Accessor_ExplorerHistory_GetDisplayStrings(ExplorerHistory, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	Detail1 := "Explorer History"
}
Accessor_ExplorerHistory_OnAccessorOpen(ExplorerHistory, Accessor)
{
	ExplorerHistory.Priority := ExplorerHistory.Settings.BasePriority
	if(ExplorerHistory.ExplorerOpen := InStr("ExploreWClass,CabinetWClass", WinGetClass("ahk_id " Accessor.PreviousWindow)))
	{
		GuiControl,, AccessorEdit, % ExplorerHistory.Settings.Keyword " "
		hwndEdit := Accessor.hwndEdit
		SendMessage, 0xC1, -1,,, AHK_ID %hwndEdit%  ; EM_LINEINDEX (Gets index number of line)
		CaretTo := ErrorLevel
		SendMessage, 0xB1, 0, CaretTo,, AHK_ID %hwndEdit% ;EM_SETSEL
		ExplorerHistory.Priority := 10000
	}
	else
		ExplorerHistory.Priority := ExplorerHistory.Settings.BasePriority
}
Accessor_ExplorerHistory_OnAccessorClose(ExplorerHistory, Accessor)
{
}
Accessor_ExplorerHistory_OnExit(ExplorerHistory)
{
}
Accessor_ExplorerHistory_FillAccessorList(ExplorerHistoryPlugin, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{	
	global ExplorerHistory
	FuzzyList := Array()
	for index, HistoryEntry in ExplorerHistory
		if(HistoryEntry.Path && A_Index != 1)
		{
			if(InStr(HistoryEntry.Name, Filter) || InStr(HistoryEntry.Path, Filter))
				Accessor.List.Insert(Object("Title", HistoryEntry.Name, "Path", HistoryEntry.Path, "Type", "ExplorerHistory", "Icon", 2)) ;Use generic folder icon
			else if(ExplorerHistoryPlugin.Settings.FuzzySearch && FuzzySearch(HistoryEntry.Name, Filter) < 0.4)
				FuzzyList.Insert(Object("Title", HistoryEntry.Name, "Path", HistoryEntry.Path, "Type", "ExplorerHistory", "Icon", 2)) ;Use generic folder icon
		}
	Accessor.List.extend(FuzzyList)
}
Accessor_ExplorerHistory_PerformAction(ExplorerHistory, Accessor, AccessorListEntry)
{
	PreviousWindow := Accessor.PreviousWindow
	AccessorClose()
	;~ if(InStr("CabinetWClass,ExploreWClass", WinGetClass("ahk_id " Accessor.PreviousWindow)) || IsDialog(Accessor.PreviousWindow))
		ShellNavigate(AccessorListEntry.Path, PreviousWindow)
	;~ else
		;~ Run(A_WinDir "\explorer.exe /n,/e," AccessorListEntry.Path)
}
Accessor_ExplorerHistory_ListViewEvents(ExplorerHistory, AccessorListEntry)
{
}
Accessor_ExplorerHistory_EditEvents(ExplorerHistory, AccessorListEntry, Filter, LastFilter)
{
	return true
}
Accessor_ExplorerHistory_SetupContextMenu(ExplorerHistory, AccessorListEntry)
{
	Menu, AccessorMenu, add, Open path in explorer,AccessorOK
	Menu, AccessorMenu, Default,Open path in explorer
	Menu, AccessorMenu, add, Open path in CMD,AccessorOpenCMD
	Menu, AccessorMenu, add, Copy Path (CTRL+C), AccessorCopyPath
	Menu, AccessorMenu, add, Explorer context menu, AccessorExplorerContextMenu
}