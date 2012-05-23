Class CUninstallPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Uninstall", CUninstallPlugin)
	
	Description := "This plugin lets you uninstall programs or remove the uninstall entries from the list."
	
	;List containing the uninstallation entries
	List := Array()
	
	;This plugin is not listed by the history plugin because the results may not be valid anymore.
	SaveHistory := false

	AllowDelayedExecution := false
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "Uninstall"
		KeywordOnly := true
		MinChars := 0
		FuzzySearch := false
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Uninstall", "Uninstall", "", true, false)
			__new()
			{
				this.Insert(new CAccessor.CAction("Remove entry", "RemoveUninstallEntry", "", false, false))
				this.Insert(new CAccessor.CAction("Open installation path in explorer`tCTRL + E", "OpenExplorer", new Delegate(this, "HasInstallLocation"), true, false))
				this.Insert(new CAccessor.CAction("Open installation path in CMD", "OpenCMD", new Delegate(this, "HasInstallLocation"), true, false))
				this.Insert(new CAccessor.CAction("Copy installation path`tCTRL + C", "Copy", new Delegate(this, "HasInstallLocation"), false, false))
			}
			HasInstallLocation(ListEntry)
			{
				return InStr(FileExist(ListEntry.Path), "D")
			}
		}
		Type := "Uninstall"
		Actions := new this.CActions()
		Priority := CUninstallPlugin.Instance.Priority
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	OnOpen(Accessor)
	{
		this.List := Array()
	}
	OnClose(Accessor)
	{
		for index, ListEntry in this.List
			if(ListEntry.Icon != Accessor.GenericIcons.Application)			
				DestroyIcon(ListEntry.Icon)
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		;Lazy loading
		if(this.List.MaxIndex() = 0)
		{
			Loop, HKLM , SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, 2, 0
			{
				GUID := A_LoopRegName ;Note: This is not always a GUID but can also be a regular name. It seems that MSIExec likes to use GUIDs
				RegRead, DisplayName, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%GUID%, DisplayName
				RegRead, UninstallString, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%GUID%, UninstallString
				RegRead, InstallLocation, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%GUID%, InstallLocation
				RegRead, DisplayIcon, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%GUID%, DisplayIcon
				if(RegexMatch(DisplayIcon,".+,\d*"))
				{
					Number := strTrim(SubStr(DisplayIcon, InStr(DisplayIcon,",",0,0) + 1), " ")
					DisplayIcon := strTrim(SubStr(DisplayIcon, 1, InStr(DisplayIcon,",",0,0) - 1), " ")
				}
				if(!Number)
					Number := 0
				if(FileExist(DisplayIcon))
					hIcon := ExtractAssociatedIcon(Number, DisplayIcon, iIndex)
				else
					hIcon := Accessor.GenericIcons.Application
				if(DisplayName)
					this.List.Insert(Object("GUID", GUID, "DisplayName", DisplayName, "UninstallString", UninstallString, "InstallLocation", InstallLocation, "Icon", hIcon))
			}
		}
		
		Results := Array()
		FuzzyResults := Array()
		for index, ListEntry in this.List
		{
			x := 0
			if(x := (Filter = "" || InStr(ListEntry.DisplayName, Filter)) || y := (this.Settings.FuzzySearch && FuzzySearch(ListEntry.DisplayName, Filter) < 0.4))
			{
				Result := new this.CResult()
				Result.Title := ListEntry.DisplayName
				Result.UninstallString := ListEntry.UninstallString
				Result.Path := ListEntry.InstallLocation
				Result.GUID := ListEntry.GUID
				Result.Icon := ListEntry.Icon
				
				if(x)
					Results.Insert(Result)
				else
					FuzzyList.Insert(Result)
			}
		}
		Results.extend(FuzzyResults)
		return Results
	}
	Uninstall(Accessor, ListEntry)
	{
		Run(ListEntry.UninstallString)
	}

	RemoveUninstallEntry(Accessor, ListEntry)
	{
		RegDelete, HKLM, % "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" ListEntry.GUID
		key := this.List.FindKeyWithValue("GUID", ListEntry.GUID)
		if(key)
		{
			this.List.Remove(key)
			Accessor.RefreshList()
		}
	}
}