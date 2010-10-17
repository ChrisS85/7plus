Accessor_ProgramLauncher_Init(ByRef ProgramLauncher, Settings)
{
	ReadProgramLauncherCache(ProgramLauncher)
	RefreshProgramLauncherCache(ProgramLauncher)
	; outputdebug % "final count 2 " ProgramLauncher.List.len()
	SetTimer, UpdateLauncherPrograms, 60000
	ProgramLauncher.Settings.Keyword := "run"
	ProgramLauncher.DefaultKeyword := "run"
	ProgramLauncher.KeywordOnly := false
	ProgramLauncher.MinChars := 2
	ProgramLauncher.OKName := "Run"	
	ProgramLauncher.Settings.FuzzySearch := Settings.FuzzySearch
	ProgramLauncher.Settings.IgnoreExtensions := Settings.IgnoreExtensions
	ProgramLauncher.Description := "Run programs/files by typing a part of their name. All programs/files from the folders `nin the list below can be used. 7plus also looks for running programs `nand automatically adds them to the index."
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
		SubEventGUI_Add(PSettings, PGUI, "Edit", "Keyword", "", "", "Keyword:")
		SubEventGUI_Add(PSettings, PGUI, "Edit", "BasePriority", "", "", "Base Priority:")
		SubEventGUI_Add(PSettings, PGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "")
		SubEventGUI_Add(PSettings, PGUI, "Checkbox", "IgnoreExtensions", "Ignore file extensions", "", "")
		GUI, Add, ListView, vProgramLauncherListView gProgramLauncherListView AltSubmit -Hdr -Multi w330 R8, ID|Path
		Loop % PSettings.tmpPaths.len()
			LV_Add(A_Index = 1 ? "Select" : "", A_Index, PSettings.tmpPaths[A_Index].Path)
		GUI, Add, Button, x+10 gProgramLauncherAddPath w80, Add Path
		GUI, Add, Button, y+10 gProgramLauncherEditPath vProgramLauncherEditPath w80, Browse
		GUI, Add, Button, y+10 gProgramLauncherDeletePath vProgramLauncherDeletePath w80, Delete Path
		GUI, Add, Button, y+10 gProgramLauncherRefreshCache w80, Refresh Cache
		x := PGUI.x
		Gui, Add, Text, x%x% y+35, File extensions:
		Gui, Add, Edit, hwndhEdit x+10 y+-17 w248
		Gui, Add, Text, x+10 y+-17, Seperator: Comma
	}
	else if(GoToLabel = "ListView")
	{
		ListEvent := Errorlevel
		outputdebug listevent %listevent%
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
			outputdebug save extensions %extensions% pos %pos%
			PSettings.tmpPaths[pos].Extensions := extensions
			GuiControl, disable, ProgramLauncherEditPath
			GuiControl, disable, ProgramLauncherDeletePath
		}
	}
	else if(GoToLabel = "AddPath")
	{
		Gui +OwnDialogs
		path:=COM_CreateObject("Shell.Application").BrowseForFolder(0, "Add indexing path", 0).Self.Path
		if(path!="")
		{
			PSettings.tmpPaths.append(Object("Path", path, "Extensions", "exe"))
			LV_Add("Select", PSettings.tmpPaths.len(), path)
		}
	}
	else if(GoToLabel = "EditPath")
	{
		selected := LV_GetNext()
		if(selected)
		{
			Gui +OwnDialogs
			FileSelectFolder, path,,,Add indexing path
			; path:=COM_CreateObject("Shell.Application").BrowseForFolder(0, "Add indexing path", 0x50).Self.Path
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
	; outputdebug Accessor_ProgramLauncher_GetDisplayStrings %Title%
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
	
	strippedFilter := WindowSwitcher.Settings.IgnoreFileExtensions ? RegexReplace(Filter, "\.\w+") : Filter 
	; outputdebug % "Accessor_ProgramLauncher_FillAccessorList count " ProgramLauncher.List.len()
	Loop % ProgramLauncher.List.len()
	{
		x := 0
		strippedName := WindowSwitcher.Settings.IgnoreFileExtensions ? RegexReplace(ProgramLauncher.List[A_Index].Name, "\.\w+") : ProgramLauncher.List[A_Index].Name 
		if(ProgramLauncher.List[A_Index].Command && strippedName && (x := InStr(strippedName,StrippedFilter) || (ProgramLauncher.Settings.FuzzySearch && strlen(StrippedFilter) < 5 && FuzzySearch(StrippedName,StrippedFilter) < 0.4)))
		{
			if(!FileExist(ProgramLauncher.List[A_Index].Command))
			{
				ProgramLauncher.List.Delete(A_Index)
				continue
			}
			
			IconCount++
			if(!ProgramLauncher.List[A_Index].hIcon) ;Program launcher icons are cached lazy, only when needed
				ProgramLauncher.List[A_Index].hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, ProgramLauncher.List[A_Index].Command, UShortP, iIndex)
			DllCall("ImageList_ReplaceIcon", UInt, Accessor.ImageListID, Int, -1, UInt, ProgramLauncher.List[A_Index].hIcon)
			if(x)
				Accessor.List.append(Object("Title",ProgramLauncher.List[A_Index].Name,"Path",ProgramLauncher.List[A_Index].Command,"Type","ProgramLauncher", "Icon", IconCount))
			else
				FuzzyList.append(Object("Title",ProgramLauncher.List[A_Index].Name,"Path",ProgramLauncher.List[A_Index].Command,"Type","ProgramLauncher", "Icon", IconCount))
		}
	}
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
	Loop % ProgramLauncher.List.len()
		DestroyIcon(ProgramLauncher.List.Icon)	
	WriteProgramLauncherCache(ProgramLauncher)
}
ReadProgramLauncherCache(ProgramLauncher)
{
	global ConfigPath
	SplitPath, ConfigPath,,path
	path .= "\ProgramCache.xml"
	ProgramLauncher.List := Array()
	ProgramLauncher.Paths := Array()
	if(!FileExist(path))
		return
	; outputdebug read ProgramLauncher cache from %path%
	FileRead, xml, %path%
	XMLObject := XML_Read(xml)
	;Convert empty and single arrays to real array
	if(!XMLObject.List.len())
		XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()
	if(!XMLObject.Paths.len())
		XMLObject.Paths := IsObject(XMLObject.Paths) ? Array(XMLObject.Paths) : Array()
		
	
	
	ProgramLauncher.Exclude := XMLObject.Exclude
	; outputdebug % "xml list count " xmlobject.list.len()
	; outputdebug % "xml paths count " xmlobject.paths.len()
	Loop % XMLObject.List.len()
	{
		XMLObjectListEntry := XMLObject.List[A_Index]
		command := XMLObjectListEntry.Command
		SplitPath, command, name
		ProgramLauncher.List.append(Object("Name",name,"Command",command,"BasePath",XMLObjectListEntry.BasePath))
	}
	Loop % XMLObject.Paths.len()
	{
		XMLPath := XMLObject.Paths[A_Index]
		ProgramLauncher.Paths.append(Object("Path",XMLPath.Path,"Extensions",XMLPath.Extensions))
	}
}
WriteProgramLauncherCache(ProgramLauncher)
{
	global ConfigPath
	SplitPath, ConfigPath,,path
	path .= "\ProgramCache.xml"
	FileDelete, %path%
	XMLObject := Object("List",Array(),"Paths",Array(),"Exclude",ProgramLauncher.Exclude)
	Loop % ProgramLauncher.List.len()
		XMLObject.List.append(Object("Command",ProgramLauncher.List[A_Index].Command,"BasePath",ProgramLauncher.List[A_Index].BasePath))
	Loop % ProgramLauncher.Paths.len()
		XMLObject.Paths.append(Object("Path",ProgramLauncher.Paths[A_Index].Path,"Extensions",ProgramLauncher.Paths[A_Index].Extensions))
	
	XML_Save(XMLObject,path)
}
RefreshProgramLauncherCache(ProgramLauncher, Path ="")
{
	;Delete old cache entries which are to be refreshed
	pos := 1
	Loop % ProgramLauncher.List.len()
	{
		if((Path && ProgramLauncher.List[pos].BasePath=Path) || (!Path && ProgramLauncher.List[pos].BasePath))
		{
			; outputdebug % "delete " ProgramLauncher.List[pos].Command			
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
	; outputdebug % "paths len: " Paths.len()
	Loop % Paths.len()
	{
		Path := Paths[A_Index].Path
		; outputdebug path %path%
		Path := ExpandGlobalPlaceholders(Path)
		if(!Path)
			continue
		; outputdebug path loop %path%
		extList := Paths[A_Index].Extensions
		; outputdebug extenseions %extlist%
		Loop, %Path%\*.*, , 1
		{
			; outputdebug file system loop %A_LoopFileFullPath%
			if A_LoopFileExt in %extList%
			{
				; outputdebug in extlist
				exclude := ProgramLauncher.Exclude
				; outputdebug exclude %exclude%
				command := A_LoopFileFullPath
				name := A_LoopFileName
				if(strEndsWith(command,".lnk"))
				{
					FileGetShortcut, %command% , command, , args
					if(!args)
						SplitPath, command,name
					command .= args
					; outputdebug resolved lnk to %command%
				}
				if command not contains %exclude%
				{
					; outputdebug command not excluded
					found := false
					if(ProgramLauncher.List.indexOfSubItem("Command",command) = 0)
					{
						; outputdebug not in old list, append it
						ProgramLauncher.List.append(Object("Name",name, "Command", command, "BasePath", Path))
					}
				}
			}
		}
	}
	; outputdebug % "final count " ProgramLauncher.List.len()
}

UpdateLauncherPrograms:
UpdateLauncherPrograms(AccessorPlugins[AccessorPlugins.subIndexOf("Type", "ProgramLauncher")])
return
;This function is periodically called and adds running programs to the ProgramLauncher cache
UpdateLauncherPrograms(ProgramLauncher)
{
	global Accessor
	if(Accessor.GUINum)
		return
	; outputdebug start loop
	Loop % Accessor.List.len()
	{
		Window := Accessor.List[A_Index]
		if(Window.Type = "WindowSwitcher")
		{
			WindowFullPath := GetModuleFileNameEx(Window.PID)
			if(WindowFullPath) ;Fails sometimes for some reason
			{
				found := false
				Loop % ProgramLauncher.List.len()
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
					; outputdebug not found %path%
					SplitPath, path, name
					ProgramLauncher.List.append(Object("Name", name,"Command", WindowFullPath))
				}
			}
		}
	}
}