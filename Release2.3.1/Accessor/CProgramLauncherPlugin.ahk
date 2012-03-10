Class CProgramLauncherPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Program Launcher", CProgramLauncherPlugin)
	
	Description := "Run programs/files by typing a part of their name. All programs/files from the folders in the list `nbelow can be used. 7plus also looks for running programs and automatically adds them `nto the index, so you don't have to add large directories like Program Files or WinDir usually."
	
	;List of cached programs
	List := Array()
	
	;List of cached paths
	Paths := Array()
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "run"
		KeywordOnly := false
		FuzzySearch := false
		IgnoreExtensions := true
		Exclude := "setup,install,uninst,remove"
		MinChars := 2
		RefreshOnStartup := true
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := CAccessorPlugin.CActions.Run
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.RunWithArgs)
				this.Insert(CAccessorPlugin.CActions.RunAsAdmin)
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Type := "Program Launcher"
		Actions := new this.CActions()
	}
	Init()
	{
		this.ReadCache()
		if(this.Settings.RefreshOnStartup)
			this.RefreshCache()
		SetTimer, UpdateLauncherPrograms, 60000
	}
	
	ShowSettings(Settings, GUI, PluginGUI)
	{
		this.SettingsWindow := {Settings: Settings, GUI: GUI, PluginGUI: PluginGUI}
		this.SettingsWindow.Paths := this.Paths.DeepCopy()
		AddControl(Settings, PluginGUI, "Checkbox", "RefreshOnStartup", "Refresh cache on startup", "", "", "", "", "", "", "Disable this if 7plus starts too slow because you're scanning large directories.")
		AddControl(Settings, PluginGUI, "Checkbox", "IgnoreExtensions", "Ignore file extensions", "", "", "", "", "", "", "If checked, file extensions will be excluded from the query.")
		AddControl(Settings, PluginGUI, "Edit", "Exclude", "", "", "Exclude:", "", "", "", "", "Files which contain one of these strings will not be listed as results.")
		x := PGUI.x
		GUI.ListBox := GUI.AddControl("ListBox", "ListBox", "-Hdr -Multi -ReadOnly x" PluginGUI.x " y+10 w330 R9", "")
		for index, Path in this.SettingsWindow.Paths
			GUI.ListBox.Items.Add(Path.Path)
		GUI.ListBox.SelectionChanged.Handler := new Delegate(this, "Settings_PathSelectionChanged")
		
		GUI.btnAddPath := GUI.AddControl("Button", "btnAddPath", "x+10 w80", "&Add Path")
		GUI.btnAddPath.Click.Handler := new Delegate(this, "Settings_AddPath")
		
		GUI.btnBrowse := GUI.AddControl("Button", "btnBrowse", "y+10 w80", "&Browse")
		GUI.btnBrowse.Click.Handler := new Delegate(this, "Settings_Browse")
		
		GUI.btnDeletePath := GUI.AddControl("Button", "btnDeletePath", "y+10 w80", "&Delete Path")
		GUI.btnDeletePath.Click.Handler := new Delegate(this, "Settings_DeletePath")
		
		GUI.btnRefreshCache := GUI.AddControl("Button", "btnRefreshCache", "y+10 w80", "&Refresh Cache")
		GUI.btnRefreshCache.Click.Handler := new Delegate(this, "Settings_RefreshCache")
		
		GUI.txtExtensions := GUI.AddControl("Text", "txtExtensions", "x" PluginGUI.x " y+35", "File extensions:")
		GUI.editExtensions := GUI.AddControl("Edit", "editExtensions", "x+10 y+-17 w248", "")
		GUI.editExtensions.TextChanged.Handler := new Delegate(this, "Settings_ExtensionChanged")
		GUI.txtSeparator := GUI.AddControl("Text", "txtSeparator", "x+10 y+-17", "Separator: Comma")
	}
	SaveSettings(Settings, GUI, PluginGUI)
	{
		this.Paths := Array()
		for index, Item in this.SettingsWindow.GUI.ListBox.Items
		{
			if(InStr(FileExist(ExpandPathPlaceholders(Item.Text)), "D"))
				this.Paths.Insert(Object("Path", Item.Text,"Extensions",this.SettingsWindow.Paths[index].Extensions))
			else
				MsgBox % "Ignoring " Item.Text " because it is invalid."
		}
		this.RefreshCache()
	}
	Settings_PathSelectionChanged(Sender, Row)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedItem)
		{
			this.SettingsWindow.GUI.btnDeletePath.Enabled := 1
			this.SettingsWindow.GUI.btnBrowse.Enabled := 1
			this.SettingsWindow.GUI.editExtensions.Text := this.SettingsWindow.Paths[this.SettingsWindow.GUI.ListBox.SelectedIndex].Extensions
		}
		else
		{
			this.SettingsWindow.GUI.btnDeletePath.Enabled := 0
			this.SettingsWindow.GUI.btnBrowse.Enabled := 0
		}
	}
	Settings_ExtensionChanged(Sender)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedItem)
			this.SettingsWindow.Paths[this.SettingsWindow.GUI.ListBox.SelectedIndex].Extensions := this.SettingsWindow.GUI.editExtensions.Text
	}
	Settings_AddPath(Sender)
	{
		fd := new CFolderDialog()
		fd.Title := "Add indexing path"
		if(fd.Show())
		{
			this.SettingsWindow.Paths.Insert({Path: fd.Folder, Extensions: "exe"})
			this.SettingsWindow.GUI.ListBox.Items.Add(fd.Folder)
		}
	}
	Settings_Browse(Sender)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedIndices.MaxIndex() = 1)
		{
			fd := new CFolderDialog()
			fd.Title := "Set indexing path"
			if(fd.Show())
			{
				this.SettingsWindow.Paths[this.SettingsWindow.GUI.ListBox.SelectedIndex].Path := fd.Folder
				this.SettingsWindow.GUI.ListBox.SelectedItem.Text := fd.Folder
			}
		}
	}
	Settings_DeletePath(Sender)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedIndices.MaxIndex() = 1)
		{
			this.SettingsWindow.Paths.Remove(this.SettingsWindow.GUI.ListBox.SelectedIndex)
			this.SettingsWindow.GUI.ListBox.Items.Delete(this.SettingsWindow.GUI.ListBox.SelectedIndex)
		}
	}
	Settings_RefreshCache(Sender)
	{
		this.RefreshCache()
	}
	
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
		Detail1 := "Program"
	}
	OnOpen(Accessor)
	{
	}
	OnClose(Accessor)
	{
	}
	OnExit(Accessor)
	{
		for index, ListEntry in this.List
			DestroyIcon(this.List.hIcon)
		this.WriteCache()
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		FuzzyList := Array()
		InStrList := Array()
		
		;Possibly remove file extension from filter
		strippedFilter := this.Settings.IgnoreFileExtensions ? RegexReplace(Filter, "\.\w+") : Filter
		;~ Filter := ExpandInternalPlaceHolders(Filter) ;TODO: Is this really needed? Might save some performance to leave it out
		index := 1
		Loop % this.List.MaxIndex()
		{
			ListEntry := this.List[index]
			if(!ListEntry.Command || !FileExist(ListEntry.Command))
			{
				this.List.Remove(index)
				continue
			}
			MatchPos := 0
			
			;Match by name of the executable
			strippedExeName := this.Settings.IgnoreFileExtensions ? RegexReplace(ListEntry.ExeName, "\.\w+") : ListEntry.ExeName 
			ExeMatch := strippedExeName && ((MatchPos := InStr(strippedExeName,StrippedFilter)) || (this.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(strippedExeName,StrippedFilter) < 0.4))
			
			;Match by name of the link
			NameMatch := ListEntry.Name && ((MatchPos := InStr(ListEntry.Name,StrippedFilter)) || (this.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(ListEntry.Name,StrippedFilter) < 0.4))
			
			if(ExeMatch || NameMatch)
			{
				;~ IconCount++
				if(!ListEntry.hIcon) ;Program launcher icons are cached lazy, only when needed
					ListEntry.hIcon := ExtractAssociatedIcon(0, ListEntry.Command, iIndex)
				;~ ImageList_ReplaceIcon(Accessor.ImageListID, -1, ListEntry.hIcon)
				Name := ListEntry.Name ? ListEntry.Name : ListEntry.ExeName
				
				;Create result
				result := new this.CResult()
				result.Title := Name
				result.Path := ListEntry.Command
				result.args := ListEntry.args
				result.icon := ListEntry.hIcon
				;Put entries which start with the match at first
				if(MatchPos = 1)
					Results.Insert(result)
				else if(MatchPos)
					InStrList.Insert(result)
				else
					FuzzyList.Insert(result)
			}
			index++
		}
		Results.Extend(InStrList)
		Results.Extend(FuzzyList)
		return Results
	}	
	
	;Functions specific to this plugin:
	
	;Possibly add the selected program to ProgramLauncher cache
	AddToCache(ListEntry)
	{
		if(!ListEntry.Path)
			return
		if(this.List.FindKeyWithValue("Command",ListEntry.Path) = 0)
		{
			path := ListEntry.Path
			SplitPath, path, name
			this.List.Insert(Object("Name", name, "Command", path, "BasePath", ""))
		}
	}

	;Reads the cached files from HDD
	ReadCache()
	{
		this.List := Array()
		this.Paths := Array()
		if(!FileExist(Settings.ConfigPath "\ProgramCache.xml")) ;File doesn't exist, create default values
		{
			this.Paths.Insert(Object("Path","%StartMenu%","Extensions","lnk,exe"))
			this.Paths.Insert(Object("Path","%StartMenuCommon%","Extensions","lnk,exe"))
			this.Paths.Insert(Object("Path","%Desktop%","Extensions","lnk,exe"))
			this.Paths.Insert(Object("Path","%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar","Extensions","lnk,exe"))
			return
		}
		
		FileRead, xml, % Settings.ConfigPath "\ProgramCache.xml"
		XMLObject := XML_Read(xml)
		
		;Convert empty and single arrays to real array
		if(!XMLObject.List.MaxIndex())
			XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()
		if(!XMLObject.Paths.MaxIndex())
			XMLObject.Paths := IsObject(XMLObject.Paths) ? Array(XMLObject.Paths) : Array()
			
		Loop % XMLObject.List.MaxIndex() ;Read cached files
		{
			XMLObjectListEntry := XMLObject.List[A_Index]
			command := XMLObjectListEntry.Command
			SplitPath, command, ExeName
			if(!this.List.FindKeyWithValue("Command", command))
				this.List.Insert(Object("ExeName", ExeName, "Name", XMLObjectListEntry.Name, "Command", command, "args", XMLObjectListEntry.args, "BasePath", XMLObjectListEntry.BasePath))
		}
		
		Loop % XMLObject.Paths.MaxIndex() ;Read scan directories
		{
			XMLPath := XMLObject.Paths[A_Index]
			this.Paths.Insert(Object("Path", XMLPath.Path, "Extensions", XMLPath.Extensions))
		}
	}
	
	;Writes the cached programs to disk
	WriteCache()
	{
		FileDelete, % Settings.ConfigPath "\ProgramCache.xml"
		XMLObject := Object("List", Array(), "Paths", Array())
		for index, ListEntry in this.List
			XMLObject.List.Insert(Object("Command", ListEntry.Command, "Name", ListEntry.Name, "args", ListEntry.args, "BasePath", ListEntry.BasePath))
		for index, ListEntry in this.Paths
			XMLObject.Paths.Insert(Object("Path", ListEntry.Path, "Extensions", ListEntry.Extensions))
		
		XML_Save(XMLObject, Settings.ConfigPath "\ProgramCache.xml")
	}
	
	;Updates the list of cached programs, optionally for a specific path only
	RefreshCache(Path ="")
	{
		;Delete old cache entries which are to be refreshed
		pos := 1
		Loop % this.List.MaxIndex()
		{
			if((Path && this.List[pos].BasePath = Path) || (!Path && this.List[pos].BasePath))
			{	
				if(this.List[pos].hIcon)
					DestroyIcon(this.List[pos].hIcon)
				this.List.Remove(pos)
				continue
			}
			pos++
		}
		if(Path)
			Paths := Array(Path)
		else
			Paths := this.Paths
		Loop % Paths.MaxIndex()
		{
			Path := Paths[A_Index].Path
			Path := ExpandInternalPlaceholders(Path)
			if(!Path)
				continue
			extList := Paths[A_Index].Extensions
			Loop, %Path%\*.*, , 1
			{
				if A_LoopFileExt in %extList%
				{
					exclude := this.Settings.Exclude
					command := A_LoopFileLongPath
					name := A_LoopFileName
					SplitPath, name,,,ext, name
					if(ext = "lnk")
					{
						FileGetShortcut, %Command% , ResolvedCommand, , args
						if(!InStr(ResolvedCommand, A_WinDir "\Installer")) ; Fix for MSI Installer shortcuts which don't resolve to the proper executable
						{
							command := ResolvedCommand
							
							SplitPath, command,,,ext
							if ext not in %extList%
								continue
							if(!args)
								SplitPath, command,ExeName ;Executable name
						}
					}
					if(!command)
						continue
					
					;Exclude undesired programs (uninstall, setup,...)
					if command not contains %exclude%
					{
						if name not contains %exclude%
						{
							;Check for existing duplicates
							if(!this.List.FindKeyWithValue("Command",command))
							{
								if(ExeName)
									this.List.Insert(Object("Name",name, "ExeName", ExeName, "Command", command, "args", args, "BasePath", Path))
								else
									this.List.Insert(Object("Name",name, "Command", command, "args", args, "BasePath", Path))
							}
						}
					}
				}
			}
		}
	}
}

UpdateLauncherPrograms:
UpdateLauncherPrograms()
return
;This function is periodically called and adds running programs to the ProgramLauncher cache
UpdateLauncherPrograms()
{
	global WindowList
	if(!IsObject(CAccessor.Instance) || !IsObject(WindowList))
		return
	outputdebug update launcher programs
	for i, Window in WindowList
	{
		if(Window.Path) ;Fails sometimes for some reason
		{
			if(!CProgramLauncherPlugin.Instance.List.FindKeyWithValue("Command", Window.Path))
			{
				outputdebug % "didn't find " window.path
				path := Window.Path
				SplitPath, path, name
				exclude := CProgramLauncherPlugin.Instance.Settings.Exclude
				if path not contains %exclude%
				{
					outputdebug add %name%
					CProgramLauncherPlugin.Instance.List.Insert(Object("Name", name,"Command", Window.Path))
				}
			}
		}
	}
}