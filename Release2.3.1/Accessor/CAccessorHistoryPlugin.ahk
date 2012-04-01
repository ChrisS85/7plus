Class CAccessorHistoryPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Accessor History", CAccessorHistoryPlugin)
	
	Description := "This plugin stores the recently executed Accessor entries and shows them when Accessor opens `n(and no other plugin shows things in the current context)."
		
	List := Array()
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "History"
		KeywordOnly := false
		FuzzySearch := false
		MaxEntries := 100
		MinChars := 0 ;This is actually 2, but not when Notepad++ is active
	}
	ShowSettings(Settings, GUI, PluginGUI)
	{
		AddControl(Settings, PluginGUI, "UpDown", "MaxEntries", "3-1000", "", "History length:", "", "", "", "", "The number of history entries to keep.")
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
	}
	OnOpen(Accessor)
	{
	}
	OnExit(Accessor)
	{
		for index, item in this.List
			if(item.Icon)
				DestroyIcon(item.Icon)
	}
	OnPreExecute(Accessor, ListEntry, Action, Plugin)
	{
		if(Action.SaveHistory && Plugin.SaveHistory)
		{
			;Remove all redundant history entries and destroy their icon copies
			while(this.List.MaxIndex() >= this.Settings.MaxEntries)
				DestroyIcon(this.List.Remove(this.Settings.MaxEntries).Icon)

			;Create a copy of the entry and duplicate its icon (it needs to be destroyed later)
			; NOTE: Actions can contain references to the plugin which mustn't be copied and is not changed, so we may use a reference to it
			Actions := ListEntry.Remove("Actions")
			Copy := ListEntry.DeepCopy()
			Copy.Actions := Actions
			Copy.Icon := DuplicateIcon(Copy.Icon)
			this.List.Insert(1, Copy)
		}
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		if(!Filter)
		{
			for index, item in this.List
				Results.Insert(item)
			return Results
		}
		TitleStartsWithList := Array()
		PathStartsWithList := Array()
		TitleContainsList := Array()
		PathContainsList := Array()
		FuzzyTitleList := Array()
		FuzzyPathList := Array()
		for index, item in this.List
		{
			if(pos := InStr(item.Title, Filter))
			{
				if(pos = 1)
					TitleStartsWithList.Insert(item)
				else if(pos > 1)
					TitleContainsList.Insert(item)
			}
			else if(pos := InStr(item.Path, Filter))
			{
				if(pos = 1)
					PathStartsWithList.Insert(item)
				else if(pos > 1)
					PathContainsList.Insert(item)
			}
			else if(this.Settings.FuzzySearch && FuzzySearch(item.Title, Filter) < 0.3)
				FuzzyTitleList.Insert(item)
			else if(this.Settings.FuzzySearch && FuzzySearch(item.Path, Filter) < 0.3)
				FuzzyPathList.Insert(item)
		}
		Results.Extend(TitleStartsWithList)
		Results.Extend(PathStartsWithList)
		Results.Extend(TitleContainsList)
		Results.Extend(PathContainsList)
		Results.Extend(FuzzyTitleList)
		Results.Extend(FuzzyPathList)
		return Results
	}
}