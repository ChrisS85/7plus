Class CFileSystemPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("File System", CFileSystemPlugin)
	
	Description := "Browse the file system by typing a path. `nUse Tab for switching through matching entries and enter to enter a folder.`nApplications launched through this method are directly added to the program launcher plugin cache."
	
	;List of current icon handles
	Icons := Array()
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "fs"
		KeywordOnly := false
		MinChars := 3
		UseIcons := false
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CFileActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open file", "Run")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Class CExecutableActions extends CArray
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
		Class CFolderActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Enter folder", "EnterDirectory")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		__new(Type)
		{
			if(Type = "Folder")
				this.Actions := new this.CFolderActions()
			else if(Type = "Executable")
				this.Actions := new this.CExecutableActions()
			else
				this.Actions := new this.CFileActions()
		}
		Type := "File System"
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		Filter := ExpandPathPlaceholders(Filter)
		SplitPath, Filter, name, dir,,,drive
		if((x := InStr(dir, ":") ) != 0 && x != 2) ;Colon may only be drive separator
			return false
		return dir != "" && !InStr(Filter, "://") ;Don't match URLs
	}
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
		if(InStr(FileExist(ListEntry.Path),"D"))
			Detail1 := "Folder"
		else
			Detail1 := "File"
	}
	OnClose(Accessor)
	{
		;Get rid of old icons from last query
		if(this.Settings.UseIcons)
			for index, Icon in this.Icons
				DestroyIcon(Icon)
		this.AutoCompletionString := ""
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		;Get rid of old icons from last query
		if(this.Settings.UseIcons)
			for index, Icon in this.Icons
				DestroyIcon(Icon)
		
		Results := Array()
		Filter := ExpandPathPlaceholders(Filter)
		SplitPath, filter, name, dir,,,drive
		if(dir)
		{
			if(this.AutocompletionString)
				name := this.AutocompletionString
			Loop %dir%\*%name%*, 1, 0
			{
				IsFolder := InStr(FileExist(A_LoopFileFullPath), "D")
				IsExecutable := A_LoopFileExt && InStr("exe,cmd,bat,ahk", A_LoopFileExt)
				
				Result := new this.CResult(IsFolder ? "Folder" : (IsExecutable ? "Executable" : "File"))
				Result.Title := A_LoopFileName
				Result.Path := A_LoopFileFullPath
				if(this.Settings.UseIcons)
				{
					hIcon := ExtractAssociatedIcon(0, A_LoopFileFullPath, iIndex)
					this.Icons.Insert(hIcon)
				}
				else
				{
					if(IsFolder)
						hIcon := Accessor.GenericIcons.Folder
					else if(IsExecutable)
						hIcon := Accessor.GenericIcons.Application
					else
						hIcon := Accessor.GenericIcons.File
				}
				Result.Icon := hIcon
				Results.Insert(Result)
			}
		}
		return Results
	}
	ShowSettings(PluginSettings, Accessor, PluginGUI)
	{
		AddControl(PluginSettings, PluginGUI, "Checkbox", "UseIcons", "Use exact icons (much slower)", "", "")
	}
	
	EnterDirectory(Accessor, ListEntry)
	{
		this.AutoCompletionString := ""
		if(InStr(FileExist(ListEntry.Path),"D"))
			Accessor.SetFilter(ListEntry.Path "\")
		return 1
	}
	OnTab()
	{
		Accessor := CAccessor.Instance
		if(Accessor.List.MaxIndex() = 1 && InStr(FileExist(Accessor.List[1].Path),"D")) ;Go into folder if there is only one entry
		{
			Accessor.PerformAction()
			return
		}
		
		Filter := ExpandPathPlaceholders(Accessor.Filter)
		SplitPath, Filter, name, dir,,,drive
		
		if(name)
		{
			if(!this.AutocompletionString)
				this.AutocompletionString := name
			AutocompletionString := this.AutocompletionString
			Loop %dir%\*%AutocompletionString%*,1,0
			{
				if(A_Index = 1)
					first := A_LoopFileName
				if(A_LoopFileName = name)
				{
					usenext := true
					continue
				}
				if(usenext || (A_Index = 1 && name = AutocompletionString))
				{
					newname := A_LoopFileName
					break
				}
			}
		}
		else
			return 0
		if(!newname)
			newname := first
		if(!newname)
			return
		
		Accessor.SuppressListViewUpdate := 1
		Accessor.SetFilter(dir "\" newname) 
		Edit_Select(InStr(dir "\" newname, "\", false, 0), -1, "", "ahk_id " Accessor.GUI.EditControl.hwnd)
		for index, item in Accessor.GUI.ListView.Items
		{
			if(item.Text = newname)
			{
				item.Selected := true
				break
			}
		}
		return 1
	}
	OnFilterChanged(ListEntry, Filter, LastFilter)
	{
		this.AutocompletionString := ""
		return true
	}
}
#if (CAccessor.Instance.GUI && CAccessor.Instance.SingleContext = "File System")
Tab::
CFileSystemPlugin.Instance.OnTab()
return
#if
#if (CAccessor.Instance.GUI && CAccessor.Instance.SingleContext = "File System" && CAccessor.Instance.GUI.ActiveControl = CAccessor.Instance.GUI.ListView)
Backspace::
CAccessor.Instance.SetFilter(SubStr(CAccessor.Instance.Filter, 1, InStr(CAccessor.Instance.Filter, "\", false, 0, strEndsWith(CAccessor.Instance.Filter, "\") ? 2 : 1)))
return
#if
;~ Accessor_FileSystem_OnKeyDown(FileSystem, wParam, lParam, Filter, selected, AccessorListEntry)
;~ {
	;~ global AccessorEdit, Accessor
	;~ if(wParam = 9)
	;~ {
		
	;~ }
	;~ else
		;~ WindowSwitcher.AutocompletionString := ""
	;~ if(wParam = 13 && selected && InStr(FileExist(AccessorListEntry.Path),"D")) ;Enter on Folders
	;~ {
		;~ FileSystemSetFolder(AccessorListEntry.Title)
		;~ return 1
	;~ }
	
	;~ return 0
;~ }