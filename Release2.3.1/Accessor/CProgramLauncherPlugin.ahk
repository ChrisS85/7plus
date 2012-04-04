Class CProgramLauncherPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Program Launcher", CProgramLauncherPlugin)
	
	Description := "Run programs/files by typing a part of their name. All programs/files from the folders in the list `nbelow can be used. 7plus also looks for running programs and automatically adds them `nto the index, so you don't have to add large directories like Program Files or WinDir usually."
	
	;List of cached programs
	List := Array()
	
	;List of cached paths
	Paths := Array()

	AllowDelayedExecution := true
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "run"
		KeywordOnly := false
		FuzzySearch := false
		IgnoreExtensions := true
		;Exclude := "setup,install,uninst,remove"
		MinChars := 2
		;RefreshOnStartup := true
	}
	Class CIndexingPath
	{
		Path := ""
		Extensions := "lnk,exe"
		Actions := [{Action : "Run", Command : "${File}"}]
		UpdateOnStart := true
		UpdateOnOpen := false
		Exclude := "setup,install,uninst,remove"
		Load(XML)
		{
			if(XML.HasKey("Path"))
			{
				for key, value in this
				{
					if(!IsFunc(value) && key != "Base" && key != "Actions" && XML.HasKey(key))
						this[key] := XML[key]
					else if(key = "Actions" && XML.HasKey("Actions"))
					{
						this.Actions := Array()
						if(!XML.Actions.MaxIndex())
							XML.Actions := [XML.Actions]
						for index, action in XML.Actions
							if(action.HasKey("Action") && action.HasKey("Command"))
								this.Actions.Insert({Action : action.Action, Command : action.Command})
					}
				}
			}
		}
		Write(XML)
		{
			XMLPath := {}
			for key, value in this
			{
				if(!IsFunc(value) && key != "Base" && key != "Actions")
					XMLPath[key] := this[key]
				else if(key = "Actions")
				{
					XMLPath.Actions := Array()
					for index, action in value
						if(action.HasKey("Action") && action.HasKey("Command"))
							XMLPath.Actions.Insert({Action : action.Action, Command : action.Command})
				}
			}
			XML.Insert(XMLPath)
		}
	}
	Class CIndexedFile
	{
		args := ""
		BasePath := ""
		Command := ""
		ResolvedName := ""
		Filename := ""
		Load(XML)
		{
			if(XML.HasKey("Command"))
				for key, value in this
					if(!IsFunc(value) && key != "Base" && XML.HasKey(key))
						this[key] := XML[key]
			if(!this.ResolvedName)
			{
				Command := this.Command
				SplitPath, command, ResolvedName
				this.ResolvedName := Command
			}
		}
		Write(XML)
		{
			XMLFile := {}
			for key, value in this
				if(!IsFunc(value) && key != "Base")
					XMLFile[key] := this[key]
			XML.Insert(XMLFile)
		}
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
		for index, IndexingPath in this.Paths
			if(IndexingPath.UpdateOnStart)
				this.RefreshCache(IndexingPath)
		SetTimer, UpdateLauncherPrograms, 60000
	}
	
	ShowSettings(Settings, GUI, PluginGUI)
	{
		this.SettingsWindow := {Settings: Settings, GUI: GUI, PluginGUI: PluginGUI}
		this.SettingsWindow.Paths := this.Paths.DeepCopy()
		AddControl(Settings, PluginGUI, "Checkbox", "IgnoreExtensions", "Ignore file extensions", "", "", "", "", "", "", "If checked, file extensions will be excluded from the query.")
		AddControl(Settings, PluginGUI, "Edit", "Exclude", "", "", "Exclude:", "", "", "", "", "Files which contain one of these strings will not be listed as results.")
		x := PGUI.x
		GUI.ListBox := GUI.AddControl("ListBox", "ListBox", "-Hdr -Multi -ReadOnly x" PluginGUI.x " y+10 w330 R9", "")
		for index, IndexedPath in this.SettingsWindow.Paths
			GUI.ListBox.Items.Add(IndexedPath.Path)
		GUI.ListBox.SelectionChanged.Handler := new Delegate(this, "Settings_PathSelectionChanged")
		GUI.ListBox.DoubleClick.Handler := new Delegate(this, "Settings_Edit")
		
		GUI.btnAddPath := GUI.AddControl("Button", "btnAddPath", "x+10 w80", "&Add Path")
		GUI.btnAddPath.Click.Handler := new Delegate(this, "Settings_AddPath")
		
		GUI.btnEdit := GUI.AddControl("Button", "btnEdit", "y+10 w80", "&Edit")
		GUI.btnEdit.Click.Handler := new Delegate(this, "Settings_Edit")
		
		GUI.btnDeletePath := GUI.AddControl("Button", "btnDeletePath", "y+10 w80", "&Delete Path")
		GUI.btnDeletePath.Click.Handler := new Delegate(this, "Settings_DeletePath")
		
		GUI.btnRefreshCache := GUI.AddControl("Button", "btnRefreshCache", "y+10 w80", "&Refresh Cache")
		GUI.btnRefreshCache.Click.Handler := new Delegate(this, "Settings_RefreshCache")


		if(GUI.ListBox.Items.MaxIndex())
			GUI.ListBox.SelectedIndex := 1
		else
		{
			GUI.btnEdit.Enabled := false
			GUI.btnDeletePath.Enabled := false
		}
	}
	SaveSettings(Settings, GUI, PluginGUI)
	{
		this.Paths := Array()
		for index, IndexedPath in this.SettingsWindow.Paths
		{
			if(InStr(FileExist(ExpandPathPlaceholders(IndexedPath.Path)), "D"))
				this.Paths.Insert(IndexedPath)
			else
				MsgBox % "Ignoring " IndexedPath.Path " because it is invalid."
		}
		this.RefreshCache()
		this.Remove("SettingsWindow")
	}
	Settings_PathSelectionChanged(Sender, Row)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedItem)
		{
			this.SettingsWindow.GUI.btnDeletePath.Enabled := true
			this.SettingsWindow.GUI.btnEdit.Enabled := true
		}
		else
		{
			this.SettingsWindow.GUI.btnDeletePath.Enabled := false
			this.SettingsWindow.GUI.btnEdit.Enabled := false
		}
	}
	Settings_AddPath(Sender)
	{
		fd := new CFolderDialog()
		fd.Title := "Add indexing path"
		if(fd.Show())
		{
			IndexPathObject := new this.CIndexingPath()
			IndexPathObject.Path := fd.Folder
			PathEditorWindow := new CProgramLauncherPathEditorWindow(IndexPathObject, true)
			PathEditorWindow.OnClose.Handler := new Delegate(this, "IndexPath_OnClose")
			PathEditorWindow.Show()
		}
	}
	Settings_Edit(Params*)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedItem)
		{
			PathEditorWindow := new CProgramLauncherPathEditorWindow(this.SettingsWindow.Paths[this.SettingsWindow.GUI.ListBox.SelectedIndex], false)
			PathEditorWindow.OnClose.Handler := new Delegate(this, "IndexPath_OnClose")
			PathEditorWindow.Show()
		}
	}
	IndexPath_OnClose(Sender)
	{
		outputdebug % "onclose" sender.Result.Path
		if(IndexPathObject := Sender.Result)
		{
			if(Sender.Temporary)
			{
				this.SettingsWindow.Paths.Insert(IndexPathObject)
				this.SettingsWindow.GUI.ListBox.Items.Add(IndexPathObject.Path)
			}
			else
			{
				this.SettingsWindow.Paths[this.SettingsWindow.GUI.ListBox.SelectedIndex] := IndexPathObject
				this.SettingsWindow.GUI.ListBox.SelectedItem.Text := IndexPathObject.Path
			}
		}
	}
	Settings_DeletePath(Sender)
	{
		if(this.SettingsWindow.GUI.ListBox.SelectedItem)
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
		for index, IndexingPath in this.Paths
			if(IndexingPath.UpdateOnOpen)
				this.RefreshCache(IndexingPath)
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
			
			;Match by name of the resolved filename
			strippedResolvedName := this.Settings.IgnoreFileExtensions ? RegexReplace(ListEntry.ResolvedName, "\.\w+") : ListEntry.ResolvedName 
			ExeMatch := strippedResolvedName && ((MatchPos := InStr(strippedResolvedName,StrippedFilter)) || (this.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(strippedResolvedName,StrippedFilter) < 0.4))
			
			;Match by filename
			FilenameMatch := ListEntry.Filename && ((MatchPos := InStr(ListEntry.Filename,StrippedFilter)) || (this.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(ListEntry.Filename,StrippedFilter) < 0.4))
			
			if(ExeMatch || NameMatch)
			{
				;~ IconCount++
				if(!ListEntry.hIcon) ;Program launcher icons are cached lazy, only when needed
					ListEntry.hIcon := ExtractAssociatedIcon(0, ListEntry.Command, iIndex)
				;~ ImageList_ReplaceIcon(Accessor.ImageListID, -1, ListEntry.hIcon)
				Name := ListEntry.Filename ? ListEntry.Filename : ListEntry.ResolvedName
				
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
		if(!this.List.FindKeyWithValue("Command",ListEntry.Path))
		{
			path := ListEntry.Path
			SplitPath, path, Filename
			IndexedFile := new this.CIndexedFile()
			IndexedFile.Filename := Filename
			IndexedFile.Command := path
			this.List.Insert(IndexedFile)
		}
	}

	;Reads the cached files from HDD
	ReadCache()
	{
		this.List := Array()
		this.Paths := Array()
		if(!FileExist(Settings.ConfigPath "\ProgramCache.xml")) ;File doesn't exist, create default values
		{
			IndexingPath := new this.CIndexingPath()
			IndexingPath.Path := "%StartMenu%"
			this.Paths.Insert(IndexingPath)

			IndexingPath := new this.CIndexingPath()
			IndexingPath.Path := "%StartMenuCommon%"
			this.Paths.Insert(IndexingPath)

			IndexingPath := new this.CIndexingPath()
			IndexingPath.Path := "%Desktop%"
			this.Paths.Insert(IndexingPath)

			IndexingPath := new this.CIndexingPath()
			IndexingPath.Path := "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
			this.Paths.Insert(IndexingPath)

			; TODO: Should this be included?
			;IndexingPath := new this.CIndexingPath()
			;IndexingPath.Path := "%UserProfile%\AppData\Roaming\Microsoft\Windows\Recent"
			;IndexingPath.Extensions := "*"
			;IndexingPath.UpdateOnOpen := true
			;this.Paths.Insert(IndexingPath)
			return
		}
		
		FileRead, xml, % Settings.ConfigPath "\ProgramCache.xml"
		XMLObject := XML_Read(xml)
		
		;Convert empty and single arrays to real array
		if(!XMLObject.List.MaxIndex())
			XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()
		if(!XMLObject.Paths.MaxIndex())
			XMLObject.Paths := IsObject(XMLObject.Paths) ? Array(XMLObject.Paths) : Array()
		
		for index, XML in XMLObject.List ;Read cached files
		{
			XMLFile := new this.CIndexedFile()
			XMLFile.Load(XML)
			if(!this.List.FindKeyWithValue("Command", XMLFile.Command))
				this.List.Insert(XMLFile)
		}
		
		for index2, XML in XMLObject.Paths ;Read scan directories
		{
			Path := new this.CIndexingPath()
			Path.Load(XML)
			this.Paths.Insert(Path)
		}
	}
	
	;Writes the cached programs to disk
	WriteCache()
	{
		FileDelete, % Settings.ConfigPath "\ProgramCache.xml"
		XMLObject := Object("List", Array(), "Paths", Array())
		for index, IndexedFile in this.List
			IndexedFile.Write(XMLObject.List)
		for index2, Path in this.Paths
			Path.Write(XMLObject.Paths)
		
		XML_Save(XMLObject, Settings.ConfigPath "\ProgramCache.xml")
	}
	
	;Updates the list of cached programs, optionally for a specific path only
	RefreshCache(Path = "")
	{
		;Delete old cache entries which are to be refreshed
		pos := 1
		Loop % this.List.MaxIndex()
		{
			;Remove indexed files which match the specified paths or remove all indexed files from any path (but not others!)
			if((Path && this.List[pos].BasePath = Path.Path) || (!Path && this.List[pos].BasePath))
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
		for index, Path in Paths
		{
			BasePath := ExpandInternalPlaceholders(Path.Path)
			if(!BasePath)
				continue
			extList := ToArray(Path.Extensions, ",")
			;Loop over all files (extensions filtered manually since there may be more than one)
			Loop, % BasePath "\*.*", , 1
			{
				if(extList.Contains(A_LoopFileExt) || extList.Contains("*"))
				{
					exclude := Path.Exclude
					command := A_LoopFileLongPath
					Filename := A_LoopFilename
					SplitPath, Filename,,,ext, Filename
					if(ext = "lnk")
					{
						FileGetShortcut, %Command% , ResolvedCommand, , args
						; Don't resolve:
						; - MSI Installer shortcuts which don't resolve to the proper executable
						; - Network paths which may take too long
						if(!InStr(ResolvedCommand, A_WinDir "\Installer") && InStr(ResolvedCommand, "\\") != 1)
						{
							command := ResolvedCommand
							;Check the extension again after resolving the link.
							SplitPath, command,,, ext
							if((!extList.Contains(ext) && !extList.Contains("*")))
								continue
							if(!args)
								SplitPath, command, ResolvedName ;Filename
						}
					}
					;Ignore empty commands and directories
					if(!command || InStr(FileExist(command),"D"))
						continue
					
					;Exclude undesired programs (uninstall, setup,...)
					if command not contains %exclude%
					{
						if Filename not contains %exclude%
						{
							;Check for existing duplicates
							if(!this.List.FindKeyWithValue("Command", command))
							{
								IndexedFile := new this.CIndexedFile()
								IndexedFile.Command := Command
								IndexedFile.args := args
								IndexedFile.BasePath := BasePath
								IndexedFile.Filename := Filename
								if(ResolvedName)
									IndexedFile.ResolvedName := ResolvedName
								this.List.Insert(IndexedFile)
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
	for i, Window in WindowList
	{
		if(Window.Path) ;Fails sometimes for some reason
		{
			if(!CProgramLauncherPlugin.Instance.List.FindKeyWithValue("Command", Window.Path))
			{
				path := Window.Path
				SplitPath, path, Filename
				exclude := CProgramLauncherPlugin.Instance.Settings.Exclude
				if path not contains %exclude%
				{
					IndexedFile := new CProgramLauncherPlugin.IndexedFile()
					IndexedFile.Filename := Filename
					IndexedFile.Command := Window.Path
					CProgramLauncherPlugin.Instance.List.Insert(IndexedFile)
				}
			}
		}
	}
}

Class CProgramLauncherPathEditorWindow extends CGUI
{
	txtPath := this.AddControl("Text", "txtPath", "x10 y13 section", "Path:")
	editPath := this.AddControl("Edit", "editPath", "x80 yp-3 w350", "")
	btnPath := this.AddControl("Button", "btnPath", "x+10 yp-2 w60", "Browse")
	txtExtensions := this.AddControl("Text", "txtExtensions", "xs+0 y+13", "Extensions:")
	editExtensions := this.AddControl("Edit", "editExtensions", "x80 yp-3 w350", "")
	txtSeparator := this.AddControl("Text", "txtSeparator", "x+10 yp+3", "Separator: Comma")
	txtExclude := this.AddControl("Text", "txtExclude", "xs+0 y+13", "Exclude:")
	editExclude := this.AddControl("Edit", "editExclude", "x80 yp-3 w350", "")
	chkUpdateOnOpen := this.AddControl("CheckBox", "chkUpdateOnOpen", "xs+0 y+13", "Update this path each time Accessor opens")
	chkUpdateOnStart := this.AddControl("CheckBox", "chkUpdateOnStart", "xs+0 y+10", "Update this path when 7plus starts")
	listActions := this.AddControl("ListView", "listActions", "xs+0 y+10 w520 Section", "Action|Command")
	btnAddAction := this.AddControl("Button", "btnAddAction", "x+10 yp+0 w80", "&Add Action")
	btnDeleteAction := this.AddControl("Button", "btnDeleteAction", "xp+0 y+10 w80", "&Delete Action")
	txtAction := this.AddControl("Text", "txtAction", "xs+0", "Action:")
	editAction := this.AddControl("Edit", "editAction", "x+10 yp-3", "")
	txtCommand := this.AddControl("Text", "txtCommand", "x+10 yp+3", "Command:")
	editCommand := this.AddControl("Edit", "editCommand", "x+10 yp-3 w217", "")
	btnBrowse := this.AddControl("Button", "btnBrowse", "x+10 yp-2 w60", "Browse")
	btnOK := this.AddControl("BUtton", "btnOK", "xs+350 y+15 w80 Default", "&OK")
	btnCancel := this.AddControl("BUtton", "btnCancel", "x+10 yp+0 w80", "&Cancel")
	__new(IndexPathObject, Temporary)
	{
		this.Temporary := Temporary
		this.Title := "Edit Program Launcher indexing path"
		this.chkUpdateOnOpen.Tooltip := "This option might be desired for the recent docs folder, but it will increase Accessor opening times."
		this.DestroyOnClose := true
		this.CloseOnEscape := true
		for index, item in IndexPathObject.Actions
			this.listActions.Items.Add(index = 1 ? "Select" : "", item.Action, item.Command)
		this.chkUpdateOnOpen.Checked := IndexPathObject.UpdateOnOpen
		this.chkUpdateOnStart.Checked := IndexPathObject.UpdateOnStart
		this.editExtensions.Text := IndexPathObject.Extensions
		this.editExclude.Text := IndexPathObject.Exclude
		this.editPath.Text := IndexPathObject.Path
		this.listActions.ModifyCol(1, 200)
		this.listActions.ModifyCol(2, "AutoHdr")
		this.listActions_SelectionChanged()
	}
	btnOK_Click()
	{
		IndexPathObject := new CProgramLauncherPlugin.CIndexingPath()
		IndexPathObject.Path := this.editPath.Text
		IndexPathObject.Extensions := this.editExtensions.Text
		IndexPathObject.Exclude := this.editExclude.Text
		IndexPathObject.UpdateOnOpen := this.chkUpdateOnOpen.Checked
		IndexPathObject.UpdateOnStart := this.chkUpdateOnStart.Checked
		IndexPathObject.Actions := Array()
		;Find and fix dupes
		for index, item in this.listActions.Items
		{
			found := false
			for index2, item2 in IndexPathObject.Actions
			{
				if(item2.Action = item.Text)
				{
					found := true
					break
				}
			}
			if(!found)
			{
				IndexPathObject.Actions.Insert({Action : item.Text, Command : item[2]})
				continue
			}
			Loop
			{
				found := false
				index3 := A_Index + 1
				for index4, item4 in IndexPathObject.Actions
				{
					if(item4.Action = item.Text "(" index3 ")")
					{
						found := true
						break
					}
				}
				if(!found)
					break
			}
			if(!found)
				IndexPathObject.Actions.Insert({Action : item.Text "(" index3 ")", Command : item[2]})
		}
		this.Result := IndexPathObject
		this.Close()
	}
	btnCancel_Click()
	{
		this.Close()
	}
	btnPath_Click()
	{
		fd := new CFolderDialog()
		fd.Title := "Set indexing path"
		fd.Folder := this.editPath.Text
		if(fd.Show())
			this.editPath.Text := fd.Folder
	}
	btnBrowse_Click()
	{
		fd := new CFolderDialog()
		fd.Title := "Set indexing path"
		fd.Folder := this.editPath.Text
		if(fd.Show())
			this.editCommand.Text := fd.Folder
	}
	btnAddAction_Click()
	{
		found := false
		for index, item in this.listActions.Items
		{
			if(item.Text = "New Action")
			{
				found := true
				break
			}
		}
		if(!found)
		{
			this.listActions.Items.Add("", "New Action", "${File}")
			return
		}
		else
		{
			while(found)
			{
				found := false
				index := A_Index + 1
				for index2, item in this.listActions.Items
				{
					if(item.Text = "New Action (" index ")")
					{
						found := true
						break
					}
				}
				if(!found)
				{
					this.listActions.Items.Add("", "New Action (" index ")", "${File}")
					return
				}
			}
		}
	}
	btnDeleteAction_Click()
	{
		if(this.listActions.SelectedItems.MaxIndex() = 1)
			this.listActions.Items.Delete(this.listActions.SelectedIndex)
	}
	listActions_SelectionChanged()
	{
		if(this.listActions.SelectedItems.MaxIndex() = 1)
		{
			this.editAction.Enabled := true
			this.editCommand.Enabled := true
			this.btnBrowse.Enabled := true
			this.editAction.Text := this.listActions.SelectedItem.Text
			this.editCommand.Text := this.listActions.SelectedItem[2]
		}
		else
		{
			this.editAction.Enabled := false
			this.editCommand.Enabled := false
			this.btnBrowse.Enabled := false
			this.editAction.Text := ""
			this.editCommand.Text := ""
		}
	}
	editAction_TextChanged()
	{
		if(this.listActions.SelectedItems.MaxIndex() = 1)
			this.listActions.SelectedItem.Text := this.editAction.Text
	}
	editCommand_TextChanged()
	{
		if(this.listActions.SelectedItems.MaxIndex() = 1)
			this.listActions.SelectedItem[2] := this.editCommand.Text
	}
}