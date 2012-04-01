Class CURLPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("URL", CURLPlugin)
	
	Description := "This plugin allows to open URLs in the browser and also has a history function.`nSelect a URL in another application, open Accessor and press enter to open that URL."
	
	;History containing the recently used URLs
	History := Array()
	
	;Array of Opera bookmarks
	OperaBookmarks := Array()

	;Array of Chrome bookmarks
	ChromeBookmarks := Array()

	;Array of IE bookmarks
	IEBookmarks := Array()

	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "URL"
		KeywordOnly := false
		MinChars := 3
		UseHistory := true
		MaxHistoryLen := 100
		SaveHistoryOnExit := true
		IncludeOperaBookmarks := true
		IncludeChromeBookmarks := true
		IncludeIEBookmarks := true
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open URL", "OpenURL")
			__new()
			{
				this.Insert(new CAccessor.CAction("Clear URL history", "ClearHistory", "", false, false))
				this.Insert(new CAccessor.CAction("Remove from history", "RemoveHistoryEntry", new Delegate(this, "IsHistory"), "", false, false))
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
		if(this.Settings.IncludeOperaBookmarks)
			this.LoadOperaBookmarks()
		if(this.Settings.IncludeChromeBookmarks)
			this.LoadChromeBookmarks()
		if(this.Settings.IncludeIEBookmarks)
			this.LoadIEBookmarks()
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return IsURL(Filter)
	}
	OnOpen(Accessor)
	{
		if(!Accessor.Filter && Accessor.CurrentSelection && IsURL(Accessor.CurrentSelection))
			Accessor.SetFilter(Accessor.CurrentSelection)
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
		if(this.Settings.IncludeOperaBookmarks)
			for index2, OperaBookmark in this.OperaBookmarks
				if(InStr(OperaBookmark.Name, Filter) || InStr(OperaBookmark.URL, Filter))
				{
					Result := new this.CResult()
					Result.Title := OperaBookmark.Name
					Result.Path := OperaBookmark.URL
					Result.Detail1 := "Bookmark"
					Result.Icon := Accessor.GenericIcons.URL
					Results.Insert(Result)
				}
		if(this.Settings.IncludeChromeBookmarks)
			for index3, ChromeBookmark in this.ChromeBookmarks
				if(InStr(ChromeBookmark.Name, Filter) || InStr(ChromeBookmark.URL, Filter))
				{
					Result := new this.CResult()
					Result.Title := ChromeBookmark.Name
					Result.Path := ChromeBookmark.URL
					Result.Detail1 := "Bookmark"
					Result.Icon := Accessor.GenericIcons.URL
					Results.Insert(Result)
				}
		if(this.Settings.IncludeIEBookmarks)
			for index4, IEBookmark in this.IEBookmarks
				if(InStr(IEBookmark.Name, Filter) || InStr(IEBookmark.URL, Filter))
				{
					Result := new this.CResult()
					Result.Title := IEBookmark.Name
					Result.Path := IEBookmark.URL
					Result.Detail1 := "Bookmark"
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

	LoadChromeBookmarks(obj = "")
	{
		if(!obj)
		{
			;Get path of bookmark file. Local appdata is not defined on XP but it can be retrieved through registry
			RegRead, LocalAppData, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, Local AppData
			if(FileExist(LocalAppData "\Google\Chrome\User Data\Default\Bookmarks"))
			{
				FileRead, json, % LocalAppData "\Google\Chrome\User Data\Default\Bookmarks"
				obj := lson(json)
				;obj := JSON_load(LocalAppData "\Google\Chrome\User Data\Default\Bookmarks")
				this.ChromeBookmarks := Array()
				for index, folder in obj.roots
					this.LoadChromeBookmarks(folder)
			}
		}
		else
		{
			if(obj.HasKey("Children"))
				for index, node in obj.Children
					this.LoadChromeBookmarks(node)
			if(obj.Type = "URL")
				this.ChromeBookmarks.Insert({Name : obj.Name, URL : obj.URL})
		}
	}
	LoadOperaBookmarks()
	{
		/*
		Example url:
#URL
	ID=329
	NAME=FastMail
	URL=http://redir.opera.com/bookmarks/fastmail
	DISPLAY URL=http://www.fastmail.fm/
	CREATED=1301005413
	UNIQUEID=FCAFE25AD1B88E4886653619102BB03A
	PARTNERID=opera-mail

		*/
		if(FileExist(A_AppData "\Opera\Opera\bookmarks.adr"))
		{
			this.OperaBookmarks := Array()
			state = 0 ; 0=undefined, 1= In URL
			Loop, Read, %A_AppData%\Opera\Opera\bookmarks.adr
			{
				if(A_LoopReadLine = "#URL")
				{
					state = 1
					URL := {}
				}
				else if(state = 1)
				{
					if(InStr(A_LoopReadLine, "NAME="))
						URL.Name := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "=") + 1)
					else if(InStr(A_LoopReadLine, "URL="))
						URL.URL := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "=") + 1)
					else
						continue
					if(URL.HasKey("URL") && URL.HasKey("Name"))
					{
						this.OperaBookmarks.Insert(URL)
						state = 0
					}
				}
			}
		}
	}
	LoadIEBookmarks()
	{
		Loop, % ExpandPathPlaceholders("%USERPROFILE%") "\Favorites\*.url", 0, 1
		{
			Loop, Read, %A_LoopFileLongPath%
			{
				if(pos := InStr(A_LoopReadLine, "URL="))
				{
					Target := SubStr(A_LoopReadLine, pos + 4)
					break
				}
			}
			if(IsURL(Target))
				this.IEBookmarks.Insert({Name : SubStr(A_LoopFileName, 1, -4), URL : Target})
		}
	}

	OpenURL(Accessor, ListEntry)
	{
		URL := IsURL(ListEntry.Path) ? ListEntry.Path : ListEntry.Title
		if(URL)
		{
			if(this.Settings.UseHistory)
			{
				if(index := this.History.FindKeyWithValue("URL", URL)) ;Move existing items to the top
					this.History.Remove(index)
				this.History.Insert(Object("URL", URL)) ;Add entered item to the top
				if(this.History.MaxIndex() > this.Settings.MaxHistoryLen) ;Make sure history len is not exceeded
					this.History.Remove(1)
			}
			url := (!InStr(URL, "://") ? "http://" : "") URL
			run %url%,, UseErrorLevel
		}
	}
	ClearHistory(Accessor, ListEntry)
	{
		this.History := Array()
		Accessor.RefreshList()
	}
	RemoveHistoryEntry(Accessor, ListEntry)
	{
		if(ListEntry.History)
		{
			this.History.Remove(this.History.FindKeyWithValue("URL", ListEntry.Title))
			Accessor.RefreshList()
		}
	}
}