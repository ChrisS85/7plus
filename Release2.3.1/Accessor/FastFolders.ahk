Accessor_FastFolders_Init(ByRef FastFolders, PluginSettings)
{
	FastFolders.Settings.Keyword := "FastFolders"
	FastFolders.DefaultKeyword := "FastFolders"
	FastFolders.KeywordOnly := false
	FastFolders.MinChars := 1
	FastFolders.OKName := "Open Folder"
	FastFolders.Settings.FuzzySearch := PluginSettings.HasKey("FuzzySearch") ? PluginSettings.FuzzySearch : 1
	FastFolders.Description := "Access the stored FastFolders by typing a part of a folder name."
	FastFolders.HasSettings := True
}
Accessor_FastFolders_ShowSettings(FastFolders, PluginSettings, PluginGUI)
{
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
}
Accessor_FastFolders_IsInSinglePluginContext(FastFolders, Filter, LastFilter)
{
	return false
}
Accessor_FastFolders_GetDisplayStrings(FastFolders, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	Detail1 := "FastFolder"
}
Accessor_FastFolders_OnAccessorOpen(FastFolders, Accessor)
{
	FastFolders.Priority := FastFolders.Settings.BasePriority
}
Accessor_FastFolders_OnAccessorClose(FastFolders, Accessor)
{
}
Accessor_FastFolders_OnExit(FastFolders)
{
}
Accessor_FastFolders_FillAccessorList(FastFoldersPlugin, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{	
	global FastFolders
	FuzzyList := Array()
	Loop 10
		if(FastFolders[A_Index].Path)
			if(InStr(FastFolders[A_Index].Title,Filter) || InStr(FastFolders[A_Index].Path,Filter))
				Accessor.List.append(Object("Title",FastFolders[A_Index].Title,"Path",FastFolders[A_Index].Path,"Type","FastFolders", "Icon", 2)) ;Use generic folder icon
			else if(FastFoldersPlugin.Settings.FuzzySearch && FuzzySearch(FastFolders[A_Index].Title,Filter) < 0.4)
				FuzzyList.List.append(Object("Title",FastFolders[A_Index].Title,"Path",FastFolders[A_Index].Path,"Type","FastFolders", "Icon", 2)) ;Use generic folder icon
	Accessor.List.extend(FuzzyList)
}
Accessor_FastFolders_PerformAction(FastFolders, Accessor, AccessorListEntry)
{
	if(WinGetClass("ahk_id " Accessor.PreviousWindow) = "CabinetWClass" || WinGetClass("ahk_id " Accessor.PreviousWindow) = "ExploreWClass")
		ShellNavigate(AccessorListEntry.Path,Accessor.PreviousWindow)
	else
		Run(A_WinDir "\explorer.exe /n,/e," AccessorListEntry.Path)
}
Accessor_FastFolders_ListViewEvents(FastFolders, AccessorListEntry)
{
}
Accessor_FastFolders_EditEvents(FastFolders, AccessorListEntry, Filter, LastFilter)
{
	return true
}
Accessor_FastFolders_OnKeyDown(FastFolders, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global Accessor
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		AccessorCopyField("Path")
		return true
	}
	return false
}
Accessor_FastFolders_SetupContextMenu(FastFolders, AccessorListEntry)
{
	Menu, AccessorMenu, add, Open path in explorer,AccessorOK
	Menu, AccessorMenu, Default,Open path in explorer
	Menu, AccessorMenu, add, Open path in CMD,AccessorOpenCMD
	Menu, AccessorMenu, add, Copy Path (CTRL+C), AccessorCopyPath
	Menu, AccessorMenu, add, Explorer context menu, AccessorExplorerContextMenu
}