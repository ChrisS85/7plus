Accessor_FileSystem_Init(ByRef FileSystem, Settings)
{
	FileSystem.KeywordOnly := false
	FileSystem.MinChars := 2
	FileSystem.DefaultKeyword := ""
	FileSystem.Description := "Browse the file system by typing a path. `nUse Tab for switching through matching entries and enter to enter a folder.`nApplications launched through this method are directly added to Program Launcher cache."
}
Accessor_FileSystem_ShowSettings(FileSystem, PluginSettings, PluginGUI)
{
}
Accessor_FileSystem_IsInSinglePluginContext(FileSystem, Filter, LastFilter)
{
	Filter := ExpandPathPlaceholders(Filter)
	outputdebug filter %filter%
	SplitPath, Filter, name, dir,,,drive
	return dir != "" && !InStr(Filter, "://") ;Don't match URLs
}
Accessor_FileSystem_GetDisplayStrings(FileSystem, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	if(InStr(FileExist(AccessorListEntry.Path),"D"))
		Detail1 := "Folder"
	else
		Detail1 := "File"
}
Accessor_FileSystem_OnAccessorOpen(FileSystem, Accessor)
{
}
Accessor_FileSystem_OnAccessorClose(FileSystem, Accessor)
{
}
Accessor_FileSystem_ListViewEvents(FileSystem, AccessorListEntry)
{
	IsDirectory := InStr(FileExist(AccessorListEntry.Path),"D")
	if(A_GUIEvent = "DoubleClick" && IsDirectory) ;Go into directories
		Accessor_WM_KEYDOWN(9,0)
	if(IsDirectory)
		FileSystem.OKName := "Open Folder"
	else
		FileSystem.OKName := "Open File"
}
Accessor_FileSystem_EditEvents(FileSystem, AccessorListEntry, Filter, LastFilter)
{
	return true
}
Accessor_FileSystem_FillAccessorList(FileSystem, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	Filter := ExpandPathPlaceholders(Filter)
	outputdebug filter1 %filter%
	SplitPath, filter, name, dir,,,drive
	if(dir)
	{
		if(FileSystem.AutocompletionString)
			name := FileSystem.AutocompletionString
		Loop %dir%\*%name%*, 1, 0
		{
			hIcon := DllCall("Shell32\ExtractAssociatedIcon", UInt, 0, Str, A_LoopFileFullPath, UShortP, iIndex)
			DllCall("ImageList_ReplaceIcon", UInt, Accessor.ImageListID, Int, -1, UInt, hIcon)
			DestroyIcon(hIcon)
			IconCount++
			Accessor.List.append(Object("Title",A_LoopFileName,"Path",A_LoopFileFullPath,"Type","FileSystem", "Icon", IconCount))
		}
	}
}
Accessor_FileSystem_PerformAction(FileSystem, Accessor, AccessorListEntry)
{
	global AccessorPlugins
	ProgramLauncher := AccessorPlugins[AccessorPlugins.IndexOfSubItem("Type", "ProgramLauncher")]
	if(!AccessorListEntry.Path)
		return
	if(ProgramLauncher.List.indexOfSubItem("Command",AccessorListEntry.Path) = 0)
	{
		path := AccessorListEntry.Path
		SplitPath, path, name
		ProgramLauncher.List.append(Object("Name",name, "Command", path, "BasePath", ""))
	}
	Run(AccessorListEntry.Path)
}
Accessor_FileSystem_OnExit(FileSystem)
{
}
Accessor_FileSystem_OnKeyDown(FileSystem, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global AccessorEdit, Accessor
	if(wParam = 9)
	{
		Filter := ExpandPathPlaceholders(Filter)
		SplitPath, Filter, name, dir,,,drive
		LV_GetText(first,1,4)
		outputdebug bla %first%
		if(LV_GetCount() = 1 && InStr(FileExist(first),"D"))
		{
			LV_GetText(newname,1,3)
			FileSystemSetFolder(newname)
			return 1
		}
		if(selected && !FileSystem.AutocompletionString)
		{
			; if(InStr(FileExist(AccessorListEntry.Path),"D"))
			; {
				; LV_GetText(newname,selected,3)
				; FileSystemSetFolder(newname)
				; return 1
			; }
			; else
				return 0
		}
		else
		{
			if(name)
			{
				if(!Accessor.AutocompletionString)
					Accessor.AutocompletionString := name
				AutocompletionString := Accessor.AutocompletionString
				outputdebug dir %dir% autocomplete %AutocompletionString% name %name%
				Loop %dir%\*%AutocompletionString%*,1,0
				{
					outputdebug loop %A_LoopFileName%
					if(A_Index = 1)
						first := A_LoopFileName
					if(A_LoopFileName = name)
					{
						outputdebug use next
						usenext := true
						continue
					}
					if(usenext || (A_Index = 1 && name = AutocompletionString))
					{
						outputdebug use %A_LoopfileName%
						newname := A_LoopFileName
						break
					}
				}				
				Accessor.SuppressListViewUpdate := 1
			}
			else 
				return 0
		}
		if(!newname)
			newname := first
		GuiControl, ,AccessorEdit,%dir%\%newname%
		
		hwndEdit := Accessor.hwndEdit
		SendMessage, 0xC1, -1,,, AHK_ID %hwndEdit%  ; EM_LINEINDEX (Gets index number of line)
		CaretTo := ErrorLevel
		outputdebug caretto %carretto%
		SendMessage, 0xB1, CaretTo, CaretTo,, AHK_ID %hwndEdit% ;EM_SETSEL
		Loop % LV_GetCount()
		{
			LV_GetText(text,A_Index,3)
			if(text = newname)
			{
				LV_Modify(A_Index,"Select Vis")
				break
			}
		}
		return 1
	}
	else
		WindowSwitcher.AutocompletionString := ""
	if(wParam = 13 && selected && InStr(FileExist(AccessorListEntry.Path),"D")) ;Enter on Folders
	{
		FileSystemSetFolder(AccessorListEntry.Title)
		return 1
	}
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		AccessorCopyField("Path")
		return true
	}
	return 0
}
Accessor_FileSystem_SetupContextMenu(FileSystem, AccessorListEntry)
{
	path := AccessorListEntry.Path
	SplitPath, path, name, dir, ext
	if(InStr(FileExist(path), "D"))
	{
		Menu, AccessorMenu, add, Open path in explorer,AccessorOpenExplorer
		Menu, AccessorMenu, add, Open path in CMD,AccessorOpenCMD
		Menu, AccessorMenu, Default, Open path in explorer
	}
	else
	{
		if(InStr("exe,cmd,bat",ext))
		{
			Menu, AccessorMenu, add, Run program, AccessorOK
			Menu, AccessorMenu, Default, Run program
			Menu, AccessorMenu, add, Run program with arguments,AccessorRunWithArgs
		}
		else
		{
			Menu, AccessorMenu, add, Open document,AccessorOK
			Menu, AccessorMenu, Default,Open document
		}
		Menu, AccessorMenu, add, Open path in explorer,AccessorOpenExplorer
		Menu, AccessorMenu, add, Open path in CMD,AccessorOpenCMD
	}
	Menu, AccessorMenu, add, Copy Path (CTRL+C), AccessorCopyPath
	Menu, AccessorMenu, add, Explorer context menu, AccessorExplorerContextMenu
}
FileSystemSetFolder(subfolder)
{
	global Accessor, AccessorEdit
	outputdebug set folder to %subfolder%
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	GuiControlGet, Filter, , AccessorEdit
	Filter := ExpandPathPlaceholders(Filter)
	SplitPath, Filter, name, dir,,,drive
	if(dir)
	{
		GuiControl, ,AccessorEdit,%dir%\%subfolder%\			
		hwndEdit := Accessor.hwndEdit
		SendMessage, 0xC1, -1,,, AHK_ID %hwndEdit%  ; EM_LINEINDEX (Gets index number of line)
		CaretTo := ErrorLevel
		SendMessage, 0xB1, CaretTo, CaretTo,, AHK_ID %hwndEdit% ;EM_SETSEL
	}
}