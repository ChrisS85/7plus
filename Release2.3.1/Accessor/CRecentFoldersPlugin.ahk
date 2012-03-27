Class CRecentFoldersPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Recent Folders", CRecentFoldersPlugin)
	
	Description := "Access recently used folders and quickly navigate to them in many programs."
		
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "RF"
		KeywordOnly := false
		MinChars := 2
		FuzzySearch := false
		UseHistory := true
		UseFrequent := true
		UseFastFolders := true
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open Folder", "OpenFolder")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.OpenPathWithAccessor)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Type := "Recent Folders"
		Actions := new this.CActions()
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	OnOpen(Accessor)
	{
		if(Navigation.FindNavigationSource(Accessor.PreviousWindow, "SetPath"))
		{
			Accessor.SetFilter(this.Settings.Keyword " ")
			Edit_Select(0, -1, "", "ahk_id " Accessor.GUI.EditControl.hwnd)
			this.Priority := 10000
		}
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		global ExplorerHistory,FastFolders

		;We have 3 sources here, and we want to match by different criteria...phew
		NameStartsWithFilterResults := Array()
		NameContainsFilterResults := Array()
		PathContainsFilterResults := Array()
		FuzzyResults := Array()
		if(this.Settings.UseHistory)
		{
			Detail := "History"
			for index, Entry in ExplorerHistory.History
				if(A_Index != 1)
					GoSub RecentFolders_CheckEntry
		}
		if(this.Settings.UseFastFolders)
		{
			Detail := "Fast Folders"
			for index2, Entry in FastFolders
				GoSub RecentFolders_CheckEntry
		}
		if(this.Settings.UseFrequent)
		{
			Detail := "Frequent"
			for index3, Entry in ExplorerHistory.FrequentPaths
				GoSub RecentFolders_CheckEntry
		}
		Results := Array()
		Results.Extend(NameStartsWithFilterResults)
		Results.Extend(NameContainsFilterResults)
		Results.Extend(PathContainsFilterResults)
		Results.Extend(FuzzyResults)

		;Find and remove duplicates
		i := 1
		while(Result := Results[i])
		{
			j := i + 1
			while(Result2 := Results[j])
			{
				if(Result2.Path = Result.Path)
				{
					Results.Remove(j)
					continue
				}
				j++
			}
			i++
		}
		return Results

		;Put some code in labels to save some repetitions. Yes I feel nasty for doing this...;)
		RecentFolders_CheckEntry:
		if(Entry.Path)
		{
			if(pos := InStr(Entry.Name, Filter))
			{
				GoSub RecentFolders_MakeResult
				if(pos = 1)
					NameStartsWithFilterResults.Insert(Result)
				else
					NameContainsFilterResults.Insert(Result)
			}
			else if(pos := InStr(Entry.Path, Filter))
			{
				GoSub RecentFolders_MakeResult
				PathContainsFilterResults.Insert(Result)
			}
			else if(this.Settings.FuzzySearch && FuzzySearch(Entry.Name, Filter) < 0.4)
			{
				GoSub RecentFolders_MakeResult
				FuzzyResults.Insert(Result)
			}
		}
		return

		RecentFolders_MakeResult:
		Result := new this.CResult()
		Result.Title := Entry.Name
		Result.Path := Entry.Path
		Result.Icon := Accessor.GenericIcons.Folder
		Result.Detail1 := Detail
		return
	}
	OpenFolder(Accessor, ListEntry)
	{
		Navigation.SetPath(ListEntry.Path, Accessor.PreviousWindow)
	}
}