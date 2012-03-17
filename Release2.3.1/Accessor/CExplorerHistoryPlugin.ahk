Class CExplorerHistoryPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Explorer History", CExplorerHistoryPlugin)
	
	Description := "Access the stored Explorer history by typing a part of a folder name."
		
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "EH"
		KeywordOnly := false
		MinChars := 2
		FuzzySearch := false
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open Folder", "OpenFolder")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Type := "Explorer History"
		Actions := new this.CActions()
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	OnOpen(Accessor)
	{
		if(this.ExplorerOpen := InStr("ExploreWClass,CabinetWClass", WinGetClass("ahk_id " Accessor.PreviousWindow)))
		{
			Accessor.SetFilter(this.Settings.Keyword " ")
			Edit_Select(0, -1, "", "ahk_id " Accessor.GUI.EditControl.hwnd)
			this.Priority := 10000
		}
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		global ExplorerHistory
		Results := Array()
		FuzzyResults := Array()
		for index, HistoryEntry in ExplorerHistory
			if(HistoryEntry.Path && A_Index != 1)
			{
				if(InStr(HistoryEntry.Name, Filter) || InStr(HistoryEntry.Path, Filter))
				{
					Result := new this.CResult()
					Result.Title := HistoryEntry.Name
					Result.Path := HistoryEntry.Path
					Result.Icon := Accessor.GenericIcons.Folder
					Results.Insert(Result)
				}
				else if(this.Settings.FuzzySearch && FuzzySearch(HistoryEntry.Name, Filter) < 0.4)
				{
					Result := new this.CResult()
					Result.Title := HistoryEntry.Name
					Result.Path := HistoryEntry.Path
					Result.Icon := Accessor.GenericIcons.Folder
					FuzzyResults.Insert(Result)
				}
			}
		Results.extend(FuzzyResults)
		return Results
	}
	OpenFolder(Accessor, ListEntry)
	{
		ShellNavigate(ListEntry.Path, Accessor.PreviousWindow)
	}
}