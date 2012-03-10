Class CSciTE4AutoHotkeyPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("SciTE4AutoHotkey tab switcher", CSciTE4AutoHotkeyPlugin)
	
	Description := "Activate a specific SciTE4AutoHotkey tab by typing a part of its name. This plugin restores the text `nwhich was previously entered when the current tab was last active. `nThis way you can quicly switch between the most used tabs."
		
	MRUList := Array()
	
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "sc"
		KeywordOnly := false
		FuzzySearch := false
		MinChars := 0 ;This is actually 2, but not when SciTE4AutoHotkey is active
	}
	
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Activate Tab", "ActivateTab")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.Run)
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Type := "SciTE4AutoHotkey tab switcher"
		Detail1 := "S4AHK Tab"
		Actions := new this.CActions()
	}
	Init()
	{
		path := this.GetSciTE4AutoHotkeyPath()
		if(path)
			this.Icon := ExtractIcon(path, 1, 64)
		
		;Scite4Autohotkey uses a COM automation object that allows to remote control it. 
		;However, it does not register this object for all users when using the portable version of SciTE4AHK.
		;To make this version work, 7plus registers the COM object manually on startup and deregisters it on exit.
		RegRead, IsRegistered, HKCR, Scite4AHK.Application
		Scite4Autohotkey.IsRegistered := !(A_IsAdmin && ErrorLevel)
		if(!Scite4Autohotkey.IsRegistered)
		{
			RegWrite, REG_SZ, HKCR, Scite4AHK.Application,, Scite4AHK.Application
			RegWrite, REG_SZ, HKCR, Scite4AHK.Application\CLSID,, {D7334085-22FB-416E-B398-B5038A5A0784}
		}
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	OnOpen(Accessor)
	{
		this.List1 := this.GetListOfOpenSciTE4AutoHotkeyTabs()
		if(!this.Icon)
		{
			path := this.GetSciTE4AutoHotkeyPath()
			if(path)
				this.Icon := ExtractIcon(path, 1, 64)
		}
		;if SciTEWindow is open and there is an entry with the last used command for the current tab, put it in edit box
		if(WinExist("ahk_class SciTEWindow") = Accessor.PreviousWindow)
		{
			this.Priority := 10000
			if(index := this.MRUList.FindKeyWithValue("Path", Path := this.GetSciTE4AutoHotkeyActiveTab()))
			{
				Accessor.SetFilter(this.MRUList[index].Command)
				Edit_Select(0, -1, "", "ahk_id " Accessor.GUI.EditControl.hwnd)
				
				for index2, item in Accessor.GUI.ListView.Items
					if(item[2] = this.MRUList[index].Entry && item[3] = "S4AHK Tab")
					{
						Accessor.GUI.ListView.SelectedIndex := index2
						break
					}
			}
			else
			{
				Accessor.SetFilter(this.Settings.Keyword " ")
				Edit_Select(0, -1, "", "ahk_id " Accessor.GUI.EditControl.hwnd)
			}
		}
	}
	OnExit(Accessor)
	{
		DestroyIcon(this.Icon)
		;If the SciTE4AutoHotkey COM object was registered temporarily by 7plus, it needs to be deregistered on exit.
		if(!this.IsRegistered)
			RegDelete, HKCR, Scite4AHK.Application
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		if(!WinActive("ahk_class SciTEWindow") && strLen(Filter) < 2 && !KeywordSet)
			return
		if(!this.List1.MaxIndex())
			return
		Results := Array()
		Actions := 
		if(!Filter && KeywordSet)
		{
			for index, Path in this.List1
			{
				GoSub S4AHK_CreateResult
				Results.Insert(Result)
			}
			return Results
		}
		InStrList := Array()
		FuzzyList := Array()
		for index, Path in this.List1
		{
			SplitPath, Path, Name
			pos := InStr(Name, Filter)
			if(pos = 1)
			{
				GoSub S4AHK_CreateResult
				Results.Insert(Result)
			}
			else if(pos > 1)
			{
				GoSub S4AHK_CreateResult
				InStrList.Insert(Result)
			}
			else if(SciTE4AutoHotkey.Settings.FuzzySearch && FuzzySearch(Name,Filter) < 0.3)
			{
				GoSub S4AHK_CreateResult
				FuzzyList.Insert(Result)
			}
		}
		Results.Extend(InStrList)
		Results.Extend(FuzzyList)
		return Results
		
		S4AHK_CreateResult:
		SplitPath, Path, Name
		Result := new this.CResult()
		Result.Title := Name
		Result.Path := Path
		Result.Icon := this.Icon
		return
	}
	
	;Functions specific to this plugin:
	ActivateTab(Accessor, ListEntry)
	{
		if(WinExist("ahk_class SciTEWindow") = Accessor.PreviousWindow)
		{
			if(Accessor.Filter)
			{
				if(!(index := this.MRUList.FindKeyWithValue("Path", ActiveTab := this.GetSciTE4AutoHotkeyActiveTab())))
					this.MRUList.Insert(Object("Path", ActiveTab, "Command", Accessor.Filter, "Entry", ListEntry.Path))
				else
				{
					this.MRUList[index].Command := Accessor.Filter
					this.MRUList[index].Entry := ListEntry.Path
				}
			}
			else
				Msgbox Filter not found!
		}
		this.ActivateSciTE4AutoHotkeyTab(this.List1.indexOf(ListEntry.Path))
		return
	}
	
	ActivateSciTE4AutoHotkeyTab(Index)
	{
		hwnd := WinExist("ahk_class SciTEWindow")
		if(!hwnd)
			return
		scite := ComObjActive("SciTE4AHK.Application")
		scite.SwitchToTab(Index - 1) ; the index is zero-based
		WinActivate, % "ahk_id " scite.SciTEHandle
	}
	GetListOfOpenSciTE4AutoHotkeyTabs()
	{
		hwnd := WinExist("ahk_class SciTEWindow")
		if(!hwnd) ;SciTEWindow not running, empty list
			return Array()
		list := Array()
		scite := ComObjActive("SciTE4AHK.Application")
		tabs := scite.Tabs.Array 
		; tabs is a SafeArray containing the file names 
		Loop, % scite.tabs.Count
		   list.Insert(tabs[A_Index-1])
		return list
	}
	GetSciTE4AutoHotkeyPath()
	{
		hwnd := WinExist("ahk_class SciTEWindow")
		if(!hwnd)
			return ""
		WinGet, pid, PID, ahk_id %hwnd%
		Path := GetModuleFileNameEx(pid)
		return Path
	}
	GetSciTE4AutoHotkeyActiveTab()
	{
		hwnd := WinExist("ahk_class SciTEWindow")
		if(!hwnd)
			return ""		
		scite := ComObjActive("SciTE4AHK.Application")
		return scite.CurrentFile
	}
}