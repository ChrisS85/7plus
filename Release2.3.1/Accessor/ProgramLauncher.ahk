Accessor_ProgramLauncher_Init(ByRef ProgramLauncher, PluginSettings)
{
	ReadProgramLauncherCache(ProgramLauncher)
	RefreshProgramLauncherCache(ProgramLauncher)
	SetTimer, UpdateLauncherPrograms, 60000
	ProgramLauncher.Settings.Keyword := "run"
	ProgramLauncher.DefaultKeyword := "run"
	ProgramLauncher.KeywordOnly := false
	ProgramLauncher.MinChars := 2
	ProgramLauncher.OKName := "Run"	
	ProgramLauncher.Settings.FuzzySearch := PluginSettings.HasKey("FuzzySearch") ? PluginSettings.FuzzySearch : 1
	ProgramLauncher.Settings.IgnoreExtensions := PluginSettings.HasKey("IgnoreExtensions") ? PluginSettings.IgnoreExtensions : 1
	ProgramLauncher.Settings.Exclude := PluginSettings.HasKey("Exclude") ? PluginSettings.Exclude : 1
	ProgramLauncher.Description := "Run programs/files by typing a part of their name. All programs/files from the folders in the list `nbelow can be used. 7plus also looks for running programs and automatically adds them `nto the index, so you don't have to add large directories like Program Files or WinDir usually."
	ProgramLauncher.HasSettings := True
}
Accessor_ProgramLauncher_ShowSettings(ProgramLauncher, PluginSettings, PluginGUI, GoToLabel = "")
{
	global ProgramLauncherListView, ProgramLauncherAddPath, ProgramLauncherEditPath, ProgramLauncherDeletePath
	static PLauncher,PSettings,PGUI, hEdit
	if(GoToLabel = "")
	{
		PLauncher := ProgramLauncher
		PSettings := PluginSettings
		PGUI := PluginGUI
		hEdit := 0
		PSettings.tmpPaths := PLauncher.Paths.DeepCopy()
		AddControl(PSettings, PGUI, "Edit", "Keyword", "", "", "Keyword:")
		AddControl(PSettings, PGUI, "Edit", "BasePriority", "", "", "Base Priority:")
		AddControl(PSettings, PGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
		AddControl(PSettings, PGUI, "Checkbox", "IgnoreExtensions", "Ignore file extensions", "", "")
		AddControl(PSettings, PGUI, "Edit", "Exclude", "", "", "Exclude:")
		x := PGUI.x
		GUI, Add, ListView, vProgramLauncherListView gProgramLauncherListView AltSubmit -Hdr -Multi x%x% y+10 w330 R8, ID|Path
		Loop % PSettings.tmpPaths.MaxIndex()
			LV_Add(A_Index = 1 ? "Select" : "", A_Index, PSettings.tmpPaths[A_Index].Path)
		GUI, Add, Button, x+10 gProgramLauncherAddPath w80, Add Path
		GUI, Add, Button, y+10 gProgramLauncherEditPath vProgramLauncherEditPath w80, Browse
		GUI, Add, Button, y+10 gProgramLauncherDeletePath vProgramLauncherDeletePath w80, Delete Path
		GUI, Add, Button, y+10 gProgramLauncherRefreshCache w80, Refresh Cache
		Gui, Add, Text, x%x% y+35, File extensions:
		Gui, Add, Edit, hwndhEdit x+10 y+-17 w248
		Gui, Add, Text, x+10 y+-17, Seperator: Comma
	}
	else if(GoToLabel = "ListView")
	{
		ListEvent := Errorlevel
		Gui, ListView, ProgramLauncherListView
		if(A_GuiEvent="I" && InStr(ListEvent, "S", true))
		{	
			GuiControl, enable, ProgramLauncherDeletePath
			GuiControl, enable, ProgramLauncherEditPath
			LV_GetText(pos,A_EventInfo,1)
			extensions := PSettings.tmpPaths[pos].Extensions
			ControlSetText,,%extensions%, ahk_id %hEdit%
		}
		else if(A_GuiEvent="I" && InStr(ListEvent, "s", true))
		{
			LV_GetText(pos,A_EventInfo,1)
			ControlGetText, extensions,, ahk_id %hEdit%
			PSettings.tmpPaths[pos].Extensions := extensions
			GuiControl, disable, ProgramLauncherEditPath
			GuiControl, disable, ProgramLauncherDeletePath
		}
	}
	else if(GoToLabel = "AddPath")
	{
		Gui +OwnDialogs
		path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Add indexing path", 0).Self.Path
		if(path!="")
		{
			PSettings.tmpPaths.Insert(Object("Path", path, "Extensions", "exe"))
			LV_Add("Select", PSettings.tmpPaths.MaxIndex(), path)
		}
	}
	else if(GoToLabel = "EditPath")
	{
		selected := LV_GetNext()
		if(selected)
		{
			Gui +OwnDialogs
			FileSelectFolder, path,,,Add indexing path
			; path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Add indexing path", 0x50).Self.Path
			if(path!="")
			{
				LV_GetText(pos,selected,1)
				PSettings.tmpPaths[pos].Path := path
				LV_Modify(selected, "Select Col2", path)
			}
		}
	}
	else if(GoToLabel = "DeletePath")
	{
		selected := LV_GetNext()
		if(selected)
		{
			LV_GetText(pos,selected,1)
			PSettings.tmpPaths.Delete(pos)
			LV_Delete(selected)
		}
	}
	else if(GoToLabel = "SaveSettings")
	{		
		Gui, ListView, ProgramLauncherListView
		selected := LV_GetNext()
		LV_GetText(pos,selected,1)
		ControlGetText, extensions,, ahk_id %hEdit%
		PSettings.tmpPaths[pos].Extensions := extensions
		PLauncher.Paths := PSettings.tmpPaths.DeepCopy()
	}
	else if(GoToLabel = "RefreshCache")
		RefreshProgramLauncherCache(PLauncher)
}
ProgramLauncherListView:
Accessor_ProgramLauncher_ShowSettings("","","","ListView")
return
ProgramLauncherAddPath:
Accessor_ProgramLauncher_ShowSettings("","","","AddPath")
return
ProgramLauncherEditPath:
Accessor_ProgramLauncher_ShowSettings("","","","EditPath")
return
ProgramLauncherDeletePath:
Accessor_ProgramLauncher_ShowSettings("","","","DeletePath")
return
ProgramLauncherRefreshCache:
Accessor_ProgramLauncher_ShowSettings("","","","RefreshCache")
return
Accessor_ProgramLauncher_SaveSettings(ProgramLauncher, PluginSettings, PluginGUI)
{
	Accessor_ProgramLauncher_ShowSettings("","","","SaveSettings")
}
Accessor_ProgramLauncher_GetDisplayStrings(ProgramLauncher, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	Detail1 := "Program"
}
Accessor_ProgramLauncher_OnAccessorOpen(ProgramLauncher, Accessor)
{
	ProgramLauncher.Priority := ProgramLauncher.Settings.BasePriority
}
Accessor_ProgramLauncher_OnAccessorClose(ProgramLauncher, Accessor)
{
}
Accessor_ProgramLauncher_IsInSinglePluginContext(ProgramLauncher, Filter, LastFilter)
{
	return false
}
Accessor_ProgramLauncher_FillAccessorList(ProgramLauncher, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	FuzzyList := Array()
	InStrList := Array()
	strippedFilter := WindowSwitcher.Settings.IgnoreFileExtensions ? RegexReplace(Filter, "\.\w+") : Filter
	Filter := ExpandInternalPlaceHolders(Filter)
	Loop % ProgramLauncher.List.MaxIndex()
	{
		x := 0
		strippedExeName := WindowSwitcher.Settings.IgnoreFileExtensions ? RegexReplace(ProgramLauncher.List[A_Index].ExeName, "\.\w+") : ProgramLauncher.List[A_Index].ExeName 
		if(ProgramLauncher.List[A_Index].Command
		   && (strippedExeName && ((x := InStr(strippedExeName,StrippedFilter)) || (ProgramLauncher.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(strippedExeName,StrippedFilter) < 0.4)))
		   || (ProgramLauncher.List[A_Index].Name && ((x := InStr(ProgramLauncher.List[A_Index].Name,StrippedFilter)) || (ProgramLauncher.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(ProgramLauncher.List[A_Index].Name,StrippedFilter) < 0.4))))
		{
			if(!FileExist(ProgramLauncher.List[A_Index].Command))
			{
				ProgramLauncher.List.Delete(A_Index)
				continue
			}
			
			IconCount++
			if(!ProgramLauncher.List[A_Index].hIcon) ;Program launcher icons are cached lazy, only when needed
				ProgramLauncher.List[A_Index].hIcon := ExtractAssociatedIcon(0, ProgramLauncher.List[A_Index].Command, iIndex)
			ImageList_ReplaceIcon(Accessor.ImageListID, -1, ProgramLauncher.List[A_Index].hIcon)
			Name := ProgramLauncher.List[A_Index].Name ? ProgramLauncher.List[A_Index].Name : ProgramLauncher.List[A_Index].ExeName
			if(x = 1)
				Accessor.List.Insert(Object("Title", Name, "Path", ProgramLauncher.List[A_Index].Command, "Type", "ProgramLauncher", "Icon", IconCount))
			else if(x)
				InStrList.Insert(Object("Title", Name, "Path", ProgramLauncher.List[A_Index].Command, "Type", "ProgramLauncher", "Icon", IconCount))
			else
				FuzzyList.Insert(Object("Title", Name, "Path", ProgramLauncher.List[A_Index].Command, "Type", "ProgramLauncher", "Icon", IconCount))
		}
	}
	Accessor.List.Extend(InStrList)
	Accessor.List.Extend(FuzzyList)
}
Accessor_ProgramLauncher_PerformAction(ProgramLauncher, Accessor, AccessorListEntry)
{
	Run(AccessorListEntry.Path)
}
Accessor_ProgramLauncher_ListViewEvents(ProgramLauncher, AccessorListEntry)
{
}
Accessor_ProgramLauncher_EditEvents(ProgramLauncher, AccessorListEntry, Filter, LastFilter)
{
	return true
}
Accessor_ProgramLauncher_OnKeyDown(ProgramLauncher, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global Accessor
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		AccessorCopyField("Path")
		return true
	}
}
Accessor_ProgramLauncher_SetupContextMenu(ProgramLauncher, AccessorListEntry)
{
	Menu, AccessorMenu, add, Run program,AccessorOK
	Menu, AccessorMenu, Default,Run program
	Menu, AccessorMenu, add, Run program with arguments,AccessorRunWithArgs
	Menu, AccessorMenu, add, Open executable path in explorer,AccessorOpenExplorer
	Menu, AccessorMenu, add, Open executable path in CMD,AccessorOpenCMD
	Menu, AccessorMenu, add, Copy executable path (CTRL+C),AccessorCopyPath
	Menu, AccessorMenu, add, Explorer context menu, AccessorExplorerContextMenu
}
Accessor_ProgramLauncher_OnExit(ProgramLauncher)
{
	Loop % ProgramLauncher.List.MaxIndex()
		DestroyIcon(ProgramLauncher.List.Icon)	
	WriteProgramLauncherCache(ProgramLauncher)
}
ReadProgramLauncherCache(ProgramLauncher)
{
	ProgramLauncher.List := Array()
	ProgramLauncher.Paths := Array()
	if(!FileExist(Settings.ConfigPath "\ProgramCache.xml")) ;File doesn't exist, create default values
	{
		ProgramLauncher.Paths.Insert(Object("Path","%StartMenu%","Extensions","lnk,exe"))
		ProgramLauncher.Paths.Insert(Object("Path","%StartMenuCommon%","Extensions","lnk,exe"))
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
		ProgramLauncher.List.Insert(Object("ExeName", ExeName, "Name", name, "Command", command, "BasePath", XMLObjectListEntry.BasePath))
	}
	
	Loop % XMLObject.Paths.MaxIndex() ;Read scan directories
	{
		XMLPath := XMLObject.Paths[A_Index]
		ProgramLauncher.Paths.Insert(Object("Path", XMLPath.Path, "Extensions", XMLPath.Extensions))
	}
}
WriteProgramLauncherCache(ProgramLauncher)
{
	FileDelete, % Settings.ConfigPath "\ProgramCache.xml"
	XMLObject := Object("List", Array(), "Paths", Array())
	Loop % ProgramLauncher.List.MaxIndex()
		XMLObject.List.Insert(Object("Command", ProgramLauncher.List[A_Index].Command, "Name", ProgramLauncher.List[A_Index].Name, "BasePath", ProgramLauncher.List[A_Index].BasePath))
	Loop % ProgramLauncher.Paths.MaxIndex()
		XMLObject.Paths.Insert(Object("Path", ProgramLauncher.Paths[A_Index].Path, "Extensions", ProgramLauncher.Paths[A_Index].Extensions))
	
	XML_Save(XMLObject, Settings.ConfigPath "\ProgramCache.xml")
}
RefreshProgramLauncherCache(ProgramLauncher, Path ="")
{
	;Delete old cache entries which are to be refreshed
	pos := 1
	Loop % ProgramLauncher.List.MaxIndex()
	{
		if((Path && ProgramLauncher.List[pos].BasePath=Path) || (!Path && ProgramLauncher.List[pos].BasePath))
		{	
			if(ProgramLauncher.List[pos].hIcon)
				DestroyIcon(ProgramLauncher.List[pos].hIcon)
			ProgramLauncher.List.Delete(pos)
			continue
		}
		pos++
	}
	if(Path)
		Paths := Array(Path)
	else
		Paths := ProgramLauncher.Paths
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
				exclude := ProgramLauncher.Settings.Exclude
				command := A_LoopFileFullPath
				name := A_LoopFileName
				SplitPath, name,,,, name ;lnk name
				; outputdebug command %command% name %name%
				if(strEndsWith(command,".lnk"))
				{
					FileGetShortcut, %Command% , ResolvedCommand, , args
					if(!InStr(ResolvedCommand, A_WinDir "\Installer")) ; Fix for MSI Installer shortcuts which don't resolve to the proper executable
					{
						command := ResolvedCommand 
						; outputdebug command %command% args %args%
						SplitPath, command,,,ext
						if ext not in %extList%
							continue
							
						if(!args)
							SplitPath, command,ExeName ;Executable name
						command .= args
					}
				}
				;Exclude undesired programs (uninstall, setup,...)
				if command not contains %exclude%
				{					
					;Check for existing duplicates
					if(ProgramLauncher.List.FindKeyWithValue("Command",command) = 0)
					{
						if(ExeName)
							ProgramLauncher.List.Insert(Object("Name",name, "ExeName", ExeName, "Command", command, "BasePath", Path))
						else
							ProgramLauncher.List.Insert(Object("Name",name, "Command", command, "BasePath", Path))
					}
				}
			}
		}
	}
}

UpdateLauncherPrograms:
UpdateLauncherPrograms(AccessorPlugins[AccessorPlugins.FindKeyWithValue("Type", "ProgramLauncher")])
return
;This function is periodically called and adds running programs to the ProgramLauncher cache
UpdateLauncherPrograms(ProgramLauncher)
{
	global Accessor
	if(Accessor.GUINum)
		return
	Loop % Accessor.List.MaxIndex()
	{
		Window := Accessor.List[A_Index]
		if(Window.Type = "WindowSwitcher")
		{
			WindowFullPath := GetModuleFileNameEx(Window.PID)
			if(WindowFullPath) ;Fails sometimes for some reason
			{
				found := false
				Loop % ProgramLauncher.List.MaxIndex()
				{
					if(ProgramLauncher.List[A_Index].Command = WindowFullPath)
					{
						found := true
						break
					}
				}
				if(!found)
				{
					path := Window.Path
					SplitPath, path, name
					ProgramLauncher.List.Insert(Object("Name", name,"Command", WindowFullPath))
				}
			}
		}
	}
}