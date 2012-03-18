Class CURLPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("URL", CURLPlugin)
	
	Description := "This plugin allows to open URLs in the browser and also has a history function."
	
	;History containing the recently used URLs
	History := Array()
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "URL"
		KeywordOnly := false
		MinChars := 3
		UseHistory := true
		MaxHistoryLen := 100
		SaveHistoryOnExit := true
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open URL", "OpenURL")
			__new()
			{
				this.Insert(new CAccessor.CAction("Clear URL history", "ClearHistory"))
				this.Insert(new CAccessor.CAction("Remove from history", "RemoveHistoryEntry", new Delegate(this, "IsHistory")))
			}
			IsHistory(ListEntry)
			{
				return ListEntry.History = true
			}
		}
		Type := "URL"
		Actions := new this.CActions()
	}
	Init(PluginSettings)
	{
		if(!FileExist(Settings.ConfigPath "\History.xml"))
			return
		FileRead, xml, % Settings.ConfigPath "\History.xml"
		XMLObject := XML_Read(xml)
		if(IsObject(XMLObject))
		{
			;Convert empty and single arrays to real array
			if(!IsObject(XMLObject.List) || !XMLObject.List.MaxIndex())
				XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		
			
			Loop % min(XMLObject.List.MaxIndex(), this.Settings.MaxHistoryLen)
				this.History.Insert(Object("URL", XMLObject.List[A_Index].URL))
		}
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return IsURL(Filter)
	}
	OnExit(Accessor)
	{
		FileDelete, % Settings.ConfigPath "\History.xml"
		if(!this.Settings.SaveHistoryOnExit)
			return
		XMLObject := Object("List",Array())
		for index, item in this.History
			XMLObject.List.Insert(Object("URL", item.URL))
		XML_Save(XMLObject, Settings.ConfigPath "\History.xml")
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		
		if(CouldBeURL(Filter))
		{
			Result := new this.CResult()
			Result.Title := Filter
			Result.Path := "Open URL"
			Result.Icon := Accessor.GenericIcons.URL
			Result.Detail1 := "URL"
			Results.Insert(Result)
		}
		if(this.Settings.UseHistory)
			for index, HistoryEntry in this.History
				if(InStr(HistoryEntry.URL, Filter) && HistoryEntry.URL != Filter && CouldBeURL(HistoryEntry.URL))
				{	
					Result := new this.CResult()
					Result.Title := HistoryEntry.URL
					Result.Path := "Open URL"
					Result.History := true
					Result.Detail1 := "History"
					Result.Icon := Accessor.GenericIcons.URL
					Results.Insert(Result)
				}
		return Results
	}
	ShowSettings(PluginSettings, Accessor, PluginGUI)
	{
		AddControl(PluginSettings, PluginGUI, "Checkbox", "UseHistory", "Use history", "", "")
		AddControl(PluginSettings, PluginGUI, "Checkbox", "SaveHistoryOnExit", "Save history on exit", "", "")
		AddControl(PluginSettings, PluginGUI, "Edit", "MaxHistoryLen", "", "", "History length:","Clear history","Accessor_URL_ClearHistory")
	}
	OpenURL(Accessor, ListEntry)
	{
		if(ListEntry.Title)
		{
			if(this.Settings.UseHistory)
			{			
				if(index := this.History.FindKeyWithValue("URL",ListEntry.Title)) ;Move existing items to the top
					this.History.Remove(index)
				this.History.Insert(Object("URL", ListEntry.Title)) ;Add entered item to the top
				if(this.History.MaxIndex() > this.Settings.MaxHistoryLen) ;Make sure history len is not exceeded
					this.History.Remove(1)
			}
			url := (!InStr(ListEntry.Title, "://") ? "http://" : "") ListEntry.Title
			run %url%,, UseErrorLevel
		}
		return
	}
	ClearHistory(Accessor, ListEntry)
	{
		this.History := Array()
		Accessor.RefreshList()
	}
	RemoveHistoryEntry(Accessor, ListEntry)
	{
		this.History.Remove(this.History.FindKeyWithValue("URL", ListEntry.Title))
		Accessor.RefreshList()
	}
}