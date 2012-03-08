Class CProgramLauncherPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Program Launcher", CProgramLauncherPlugin)
	
	Description := "Run programs/files by typing a part of their name. All programs/files from the folders in the list `nbelow can be used. 7plus also looks for running programs and automatically adds them `nto the index, so you don't have to add large directories like Program Files or WinDir usually."
	
	;Since the actions of this plugin are constant we can store them here
	Actions := Array()
	
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
		this.RefreshCache()
		SetTimer, UpdateLauncherPrograms, 60000
	}
	
	ShowSettings(Settings, GUI, PluginGUI)
	{
		
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
		outputdebug plugin RefreshList()
		
		;Possibly remove file extension from filter
		strippedFilter := this.Settings.IgnoreFileExtensions ? RegexReplace(Filter, "\.\w+") : Filter
		;~ Filter := ExpandInternalPlaceHolders(Filter) ;TODO: Is this really needed? Might save some performance to leave it out
		index := 1
		Loop % this.List.MaxIndex()
		{
			ListEntry := this.List[index]
			if(!ListEntry.Command || !FileExist(ListEntry.Command))
			{
				this.List.Remove(A_Index)
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
				;~ outputdebug % "Result: " ExploreObj(result.base)
				result.Title := Name
				result.Path := ListEntry.Command
				result.args := ListEntry.args
				result.icon := ListEntry.hIcon
				;~ outputdebug % "bal" Exploreobj(result.Actions)
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
	;~ OnKeyDown()
	;~ {
	;~ }
	SetupContextMenu(Accessor, ListEntry)
	{
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
							if(this.List.FindKeyWithValue("Command",command) = 0)
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

;~ Accessor_ProgramLauncher_ShowSettings(ProgramLauncher, PluginSettings, PluginGUI, GoToLabel = "")
;~ {
	;~ global ProgramLauncherListView, ProgramLauncherAddPath, ProgramLauncherEditPath, ProgramLauncherDeletePath
	;~ static PLauncher,PSettings,PGUI, hEdit
	;~ if(GoToLabel = "")
	;~ {
		;~ PLauncher := ProgramLauncher
		;~ PSettings := PluginSettings
		;~ PGUI := PluginGUI
		;~ hEdit := 0
		;~ PSettings.tmpPaths := PLauncher.Paths.DeepCopy()
		;~ AddControl(PSettings, PGUI, "Edit", "Keyword", "", "", "Keyword:")
		;~ AddControl(PSettings, PGUI, "Edit", "BasePriority", "", "", "Base Priority:")
		;~ AddControl(PSettings, PGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
		;~ AddControl(PSettings, PGUI, "Checkbox", "IgnoreExtensions", "Ignore file extensions", "", "")
		;~ AddControl(PSettings, PGUI, "Edit", "Exclude", "", "", "Exclude:")
		;~ x := PGUI.x
		;~ GUI, Add, ListView, vProgramLauncherListView gProgramLauncherListView AltSubmit -Hdr -Multi -ReadOnly x%x% y+10 w330 R8, Path
		;~ Loop % PSettings.tmpPaths.MaxIndex()
			;~ LV_Add(A_Index = 1 ? "Select" : "", PSettings.tmpPaths[A_Index].Path)
		;~ GUI, Add, Button, x+10 gProgramLauncherAddPath w80, Add Path
		;~ GUI, Add, Button, y+10 gProgramLauncherEditPath vProgramLauncherEditPath w80, Browse
		;~ GUI, Add, Button, y+10 gProgramLauncherDeletePath vProgramLauncherDeletePath w80, Delete Path
		;~ GUI, Add, Button, y+10 gProgramLauncherRefreshCache w80, Refresh Cache
		;~ Gui, Add, Text, x%x% y+35, File extensions:
		;~ Gui, Add, Edit, hwndhEdit x+10 y+-17 w248
		;~ Gui, Add, Text, x+10 y+-17, Seperator: Comma
	;~ }
	;~ else if(GoToLabel = "ListView")
	;~ {
		;~ ListEvent := Errorlevel
		;~ Gui, ListView, ProgramLauncherListView
		;~ if(A_GuiEvent="I" && InStr(ListEvent, "S", true))
		;~ {	
			;~ GuiControl, enable, ProgramLauncherDeletePath
			;~ GuiControl, enable, ProgramLauncherEditPath
			;~ extensions := PSettings.tmpPaths[A_EventInfo].Extensions
			;~ ControlSetText,,%extensions%, ahk_id %hEdit%
		;~ }
		;~ else if(A_GuiEvent="I" && InStr(ListEvent, "s", true))
		;~ {
			;~ ControlGetText, extensions,, ahk_id %hEdit%
			;~ PSettings.tmpPaths[A_EventInfo].Extensions := extensions
			;~ GuiControl, disable, ProgramLauncherEditPath
			;~ GuiControl, disable, ProgramLauncherDeletePath
		;~ }
	;~ }
	;~ else if(GoToLabel = "AddPath")
	;~ {
		;~ Gui +OwnDialogs
		;~ path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Add indexing path", 0).Self.Path
		;~ if(path!="")
		;~ {
			;~ PSettings.tmpPaths.Insert(Object("Path", path, "Extensions", "exe"))
			;~ LV_Add("Select", path)
		;~ }
	;~ }
	;~ else if(GoToLabel = "EditPath")
	;~ {
		;~ selected := LV_GetNext()
		;~ if(selected)
		;~ {
			;~ Gui +OwnDialogs
			;~ FileSelectFolder, path,,,Add indexing path
			;~ ; path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Add indexing path", 0x50).Self.Path
			;~ if(path!="")
			;~ {
				;~ PSettings.tmpPaths[selected].Path := path
				;~ LV_Modify(selected, "Select Col1", path)
			;~ }
		;~ }
	;~ }
	;~ else if(GoToLabel = "DeletePath")
	;~ {
		;~ selected := LV_GetNext()
		;~ if(selected)
		;~ {
			;~ PSettings.tmpPaths.Delete(selected)
			;~ LV_Delete(selected)
		;~ }
	;~ }
	;~ else if(GoToLabel = "SaveSettings")
	;~ {		
		;~ Gui, ListView, ProgramLauncherListView
		;~ selected := LV_GetNext()
		;~ ControlGetText, extensions,, ahk_id %hEdit%
		;~ PSettings.tmpPaths[selected].Extensions := extensions
		;~ PLauncher.Paths := Array()
		;~ Loop % LV_GetCount()
		;~ {
			;~ LV_GetText(Path, A_Index, 1)
			;~ if(InStr(FileExist(ExpandPathPlaceholders(Path)), "D"))
				;~ PLauncher.Paths.Insert(Object("Path", Path,"Extensions",PSettings.tmpPaths[A_Index].Extensions))
			;~ else
				;~ MsgBox Ignoring %Path% because it is invalid.
		;~ }
		;~ RefreshProgramLauncherCache(PLauncher)
	;~ }
	;~ else if(GoToLabel = "RefreshCache")
		;~ RefreshProgramLauncherCache(PLauncher)
;~ }
;~ ProgramLauncherListView:
;~ Accessor_ProgramLauncher_ShowSettings("","","","ListView")
;~ return
;~ ProgramLauncherAddPath:
;~ Accessor_ProgramLauncher_ShowSettings("","","","AddPath")
;~ return
;~ ProgramLauncherEditPath:
;~ Accessor_ProgramLauncher_ShowSettings("","","","EditPath")
;~ return
;~ ProgramLauncherDeletePath:
;~ Accessor_ProgramLauncher_ShowSettings("","","","DeletePath")
;~ return
;~ ProgramLauncherRefreshCache:
;~ Accessor_ProgramLauncher_ShowSettings("","","","RefreshCache")
;~ return
;~ Accessor_ProgramLauncher_SaveSettings(ProgramLauncher, PluginSettings, PluginGUI)
;~ {
	;~ Accessor_ProgramLauncher_ShowSettings("","","","SaveSettings")
;~ }



UpdateLauncherPrograms:
;~ UpdateLauncherPrograms()
return
;This function is periodically called and adds running programs to the ProgramLauncher cache
;~ UpdateLauncherPrograms()
;~ {
	;~ global Accessor
	;~ if(!IsObject(Accessor) || !IsObject(Accessor.List) || Accessor.GUINum)
		;~ return
	;~ for i, Window in Accessor.List
	;~ {
		;~ if(Window.Type = "WindowSwitcher")
		;~ {
			;~ WindowFullPath := GetModuleFileNameEx(Window.PID)
			;~ if(WindowFullPath) ;Fails sometimes for some reason
			;~ {
				;~ found := false
				;~ for index, ListEntry in ProgramLauncher.List
				;~ {
					;~ if(ListEntry.Command = WindowFullPath)
					;~ {
						;~ found := true
						;~ break
					;~ }
				;~ }
				;~ if(!found)
				;~ {
					;~ path := Window.Path
					;~ SplitPath, path, name
					;~ ProgramLauncher.List.Insert(Object("Name", name,"Command", WindowFullPath))
				;~ }
			;~ }
		;~ }
	;~ }
;~ }