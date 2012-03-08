Class CAccessor
{
	;The GUI representing the Accessor
	GUI := ""
	
	;History of previous entries
	History := {}
	
	;Plugins used by the Accessor
	static Plugins := Array()
	
	;The current (singleton) instance
	static Instance
	
	;Accessor keywords for auto expansion
	Keywords := Array()
	
	;Some generic icons used throughout multiple Accessor plugins
	GenericIcons := {}
	
	;The list of visible entries
	List := Array()
	
	;An action that can be performed on an Accessor result
	Class CAction
	{
		__new(Name, Function)
		{
			this.Name := Name
			this.Function := Function
		}
	}
	__new()
	{
		;Singleton
		if(this.Instance)
			return ""
		this.Instance := this
		
		FileRead, xml, % Settings.ConfigPath "\Accessor.xml"
		if(!xml)
		{
			xml = 
			( LTrim
				<Keywords>
				<Keyword>
				<Command>http://dict.leo.org/ende?search=${1}</Command>
				<Key>leo</Key>
				</Keyword><Keyword>
				<Command>http://google.com/search?q=${1}</Command>
				<Key>google</Key>
				</Keyword><Keyword>
				<Command>http://en.wikipedia.org/wiki/Special:Search?search=${1}</Command>
				<Key>w</Key>
				</Keyword><Keyword>
				<Command>http://maps.google.com/maps?q=${1}</Command>
				<Key>gm</Key>
				</Keyword><Keyword>
				<Command>http://www.amazon.com/s?url=search-alias`%3Daps&field-keywords=${1}</Command>
				<Key>a</Key>
				</Keyword><Keyword>
				<Command>http://www.bing.com/search?q=${1}</Command>
				<Key>bing</Key>
				</Keyword><Keyword>
				<Command>http://www.youtube.com/results?search_query=${1}</Command>
				<Key>y</Key>
				</Keyword><Keyword>
				<Command>http://www.imdb.com/find?q=${1}</Command>
				<Key>i</Key>
				</Keyword><Keyword>
				<Command>http://www.wolframalpha.com/input/?i=${1}</Command>
				<Key>wa</Key>
				</Keyword></Keywords>
			)
		}
		XMLObject := XML_Read(xml)
		
		;Init plugins
		for index, Plugin in this.Plugins
		{
			Plugin.Instance := this.Plugins[index] := new Plugin()
			XMLPlugin := XMLObject[Plugin.Type]
			Plugin.Instance.Settings.Load(XMLPlugin)
			Plugin.Instance.Init(XMLPlugin.Settings)
		}
		
		;Init keywords
		if(!IsObject(XMLObject.Keywords))
			XMLObject.Keywords := {}
		if(!IsObject(XMLObject.Keywords.Keyword) || !XMLObject.Keywords.Keyword.MaxIndex())
			XMLObject.Keywords.Keyword := IsObject(XMLObject.Keywords.Keyword) ? Array(XMLObject.Keywords.Keyword) : Array()
		for index, Keyword in XMLObject.Keywords.Keyword
			this.Keywords.Insert({Key : Keyword.Key, Command : Keyword.Command})
		
		;Init generic icons
		this.GenericIcons.Application := ExtractIcon("shell32.dll", 3, 64)
		this.GenericIcons.File := ExtractIcon("shell32.dll", 1, 64)
		this.GenericIcons.Folder := ExtractIcon("shell32.dll", 4, 64)
		;Stupid method to get the icon for the default web browser
		FileAppend, test, %A_Temp%\7plus\test.htm
		this.GenericIcons.URL := ExtractAssociatedIcon(0, A_Temp "\7plus\test.htm", iIndex)
		FileDelete, %A_Temp%\7plus\test.htm
	}
	Show(Action)
	{
		if(this.GUI)
			return
		
		;Active window for plugins that depend on the context
		this.PreviousWindow := WinExist("A")
		
		;Create and show GUI
		this.GUI := new CAccessorGUI()
		this.GUI.Show()
		
		this.LauncherHotkey := Action.LauncherHotkey
		
		;Init History TODO: Is this correct when a plugin changes it?
		this.History.Index := 1
		this.History[1] := ""
		
		;Notify plugins. They can adjust their priorities or set a filter here.
		for index, Plugin in this.Plugins
		{
			Plugin.Priority := Plugin.Settings.BasePriority
			Plugin.OnOpen(this)
		}
		
		;Check if a plugin set a custom filter
		if(!this.Filter)
			this.RefreshList()
		
		;Prevent WM_KEYDOWN messages
		this.OldKeyDown := OnMessage(0x100)
		OnMessage(0x100, "")
	}
	SetFilter(Text)
	{
		this.Filter := Text
		GUI.SetFilter(Text)
	}
	OnFilterChanged(Filter)
	{
		this.Filter := Filter
		ListEntry := this.List[this.GUI.ListView.SelectedIndex]
		
		NeedsUpdate := 1
		for index, Plugin in this.Plugins ;Check if single context plugin requests an update
		{
			if(Plugin.Enabled && SingleContext := ((Plugin.Settings.Keyword && Filter && InStr(Filter, Plugin.Settings.Keyword) = 1) || Plugin.IsInSinglePluginContext(Filter, this.LastFilter)))
			{
				this.SingleContext := Plugin.Type
				NeedsUpdate := Plugin.OnFilterChanged(ListEntry, Filter, LastFilter)
				break
			}
		}
		if(!SingleContext)
			this.SingleContext := false
		if(!NeedsUpdate) ;Check if any plugin requests an update
			for index, Plugin in this.Plugins
				if(Plugin.Enabled && !Plugin.Settings.KeywordOnly)
				{
					NeedsUpdate := Plugin.OnFilterChanged(ListEntry, Filter, LastFilter)
					break
				}
		if(!this.History.CycleHistory)
			this.History[1] := Filter
		else
			this.History.CycleHistory := 0
		if(NeedsUpdate)
			this.RefreshList()
	}
	
	;This function parses and expands an entered filter string using the Accessor Keywords
	ExpandFilter(ByRef Filter, LastFilter)
	{
		;Expand keywords into their real commands
		for Index, Keyword in this.Keywords
		{
			;if filter starts with keyword and ends directly after it or has a space after it
			if(InStr(Filter, Keyword.Key) = 1 && (strlen(Filter) = strlen(Keyword.Key) || InStr(Filter, " ") = strLen(Keyword.Key) + 1))
			{
				Filter := StringReplace(Filter, Keyword.Key, Keyword.Command)
				UsingKeyword := true
				break
			}
		}
		
		;Parse parameters. They are split by spaces. Quotes (" ") can be used to treat multiple words as one parameter. The first parameter is the Filter variable without the options.
		Parameters := Array()
		p0 := Parse(Filter, "q"")1 2 3 4 5 6 7 8 9 10", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
		
		Loop % min(p0, 10)
			Parameters.Insert(A_Index - 1, p%A_Index%) ;Store parameters with offset of -1, so p1 will become p0 since it isn't a real parameter but rather the keyword
		
		if(UsingKeyword)
		{
			if(InStr(Filter, "${1}"))
				Filter := p1 ;If atleast one placeholder is used, all parameters will be inserted 
			
			;Code below treats the ${1}-${10} placeholders that may be used with keywords, e.g. to launch a search engine url with a specific query.
			for Index, Parameter in Parameters
			{
				if(Index = 0)
					continue
				
				;If this is the last placeholder used in the query, insert all parameters into it so queries with spaces become possible for the last placeholder
				if(InStr(Filter, "${" Index "}") && !InStr(Filter, "${" (Index+1) "}"))
				{
					CollectedParameters := Parameter
					Loop % Parameters.MaxIndex() - Index
						CollectedParameters .= " " Parameters[A_Index + Index]
					Filter := StringReplace(Filter, "${" Index "}", CollectedParameters, "ALL")
					UsingPlaceholder := true
					break
				}
				else if(InStr(Filter, "${" Index "}"))
				{
					Filter := StringReplace(Filter, "${" Index "}", Parameter, "ALL")
					UsingPlaceholder := true
				}
				else
					break
			}
			if(UsingPlaceholder)
				Parameters := Array() ;Clear parameters since they are now integrated in the query
		}
		return Parameters
	}
	
	;This is the main function that populates the Accessor list.
	RefreshList()
	{
		if(this.SuppressListViewUpdate)
		{
			this.SuppressListViewUpdate := false
			return
		}
		
		if(!this.GUI)
			return
		LastFilter := this.LastFilter
		Filter := this.Filter
		Parameters := this.ExpandFilter(Filter, LastFilter)
		
		;~ this.ListViewReady := false
		this.GUI.ListView.Redraw := false
		
		this.GUI.ListView.Items.Clear()
		this.GUI.ListView.ImageListManager.Clear()
		
		;~ this.ImageListID := IL_Create(20,5,this.Settings.LargeIcons = 1) ; Create an ImageList so that the ListView can display some icons
		;~ IconCount := 4
		;~ ImageList_ReplaceIcon(this.ImageListID, -1, this.GenericIcons.Application)
		;~ ImageList_ReplaceIcon(this.ImageListID, -1, this.GenericIcons.Folder)
		;~ ImageList_ReplaceIcon(this.ImageListID, -1, this.GenericIcons.URL)
		;~ ImageList_ReplaceIcon(this.ImageListID, -1, this.GenericIcons.File)
		
		this.List := Array()
		
		;Find out if we are in a single plugin context, and add only those items
		for index, Plugin in this.Plugins
		{
			if(Plugin.Settings.Enabled && SingleContext := ((Plugin.Settings.Keyword && Filter && KeywordSet := InStr(Filter, Plugin.Settings.Keyword " ") = 1) || Plugin.IsInSinglePluginContext(Filter, LastFilter)))
			{
				this.SingleContext := Plugin.Type
				Filter := strTrimLeft(Filter, Plugin.Settings.Keyword " ")
				Result := Plugin.RefreshList(this, Filter, LastFilter, KeywordSet, Parameters)
				if(Result)
					this.List.Extend(Result)
				break
			}
		}
		;If we aren't, let all plugins add the items we want according to their priorities
		if(!SingleContext)
		{
			this.SingleContext := false
			Pluginlist := ""
			for index, Plugin in this.Plugins
				Pluginlist .= (Pluginlist ? "," : "") index
			Sort, Pluginlist, F AccessorPrioritySort D`,
			Loop, Parse, Pluginlist, `,
			{
				Plugin := this.Plugins[A_LoopField]
				if(Plugin.Settings.Enabled && !Plugin.Settings.KeywordOnly && StrLen(Filter) >= Plugin.Settings.MinChars)
				{
					Result := Plugin.RefreshList(Accessor, Filter, LastFilter, False, Parameters)
					if(Result)
						this.List.Extend(Result)
				}
			}
		}
		;Now that items are added, add them to the listview
		;~ LV_SetImageList(Accessor.ImageListID, 1) ; Attach the ImageLists to the ListView so that it can later display the icons
		for index, ListEntry in this.List
		{
			Plugin := this.Plugins.GetItemWithValue("Type", ListEntry.Type)
			Plugin.GetDisplayStrings(ListEntry, Title := ListEntry.Title, Path := ListEntry.Path, Detail1 := ListEntry.Detail1, Detail2 := ListEntry.Detail2)
			item := this.GUI.ListView.Items.Add("", Title, Path, Detail1, Detail2)
			item.Icon := ListEntry.Icon
			;~ LV_Add("Icon" AccessorListEntry.Icon, "", A_Index, Title, Path, Detail1, Detail2)
		}
		;~ this.ListViewReady := true
		this.LastFilter := Filter
		this.LastParameters := Parameters
		selected := LV_GetNext()
		if(this.GUI.ListView.SelectedItems.MaxIndex() != 1)
			this.GUI.ListView.SelectedIndex := 1
		
		this.GUI.ListView.Redraw := true
	}
	
	;Registers an Accessor plugin with this class. This needs to be done
	RegisterPlugin(Type, Plugin)
	{
		this.Plugins.Insert(Plugin)
		return Type
	}
	Close()
	{
		this.GUI.Close()
	}
	OnExit()
	{
		;Close an open instance
		if(this.GUI)
			this.Close()
		
		;Save Accessor related data
		FileDelete, % Settings.ConfigPath "\Accessor.xml"
		XMLObject := {}
		for index, Plugin in this.Plugins
		{
			XMLObject[Plugin.Type] := Plugin.Settings.DeepCopy()
			Plugin.OnExit()
		}
		XMLObject.Keywords := Object("Keyword", this.Keywords)
		
		XML_Save(XMLObject, Settings.ConfigPath "\Accessor.xml")
		
		;Clean up
		DestroyIcon(Accessor.GenericIcons.Application)
		DestroyIcon(Accessor.GenericIcons.File)
		DestroyIcon(Accessor.GenericIcons.Folder)
		DestroyIcon(Accessor.GenericIcons.URL)
	}
	OnSelectionChanged()
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			if(this.GUI.btnOK.Text != ListEntry.Actions.DefaultAction.Name)
				this.GUI.btnOK.Text := ListEntry.Actions.DefaultAction.Name
		}
	}
	OnDoubleClick()
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			Plugin := this.Plugins.GetItemWithValue("Type", ListEntry.Type)
			if(!Plugin.OnDoubleClick(ListEntry))
				this.PerformAction()
		}
	}
	OnClose()
	{
		for index, Plugin in this.Plugins
			Plugin.OnClose(this)
		this.LastFilter := ""
		this.GUI := ""
		OnMessage(0x100, this.OldKeyDown) ; Restore previous KeyDown handler
	}
	
	;Changes the currently selected history entry and returns its text. Does not affect the GUI!
	ChangeHistory(Dir)
	{
		if(Dir = 1) ;Up
		{
			if(this.History.MaxIndex() >= this.History.Index + 1 && this.History.Index < 10)
			{
				this.History.Index++
				this.History.CycleHistory := 1
				return this.History[this.History.Index]
			}
		}
		else if(Dir = -1) ;Down
		{
			if(this.History.Index > 1)
			{
				this.History.Index--
				this.History.CycleHistory := 1
				return this.History[this.History.Index]
			}
		}
	}
	
	;This function is called to perform an action on a selected list entry.
	;Plugins may handle each function on their own, otherwise they will be handled directly by Accessor if available.
	PerformAction(Action = "")
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			if(Action && !IsObject(Action))
				Action := ListEntry.Actions.DefaultAction.Name = Action ? ListEntry.Actions.DefaultAction : ListEntry.Actions.GetItemWithValue("Name", Action)
			if(!Action && ListEntry.Actions.DefaultAction)
				Action := ListEntry.Actions.DefaultAction
			else if(!Action)
			{
				Msgbox % "No Action found for " ListEntry.Type "!"
				return
			}
			Plugin := this.Plugins.GetItemWithValue("Type", ListEntry.Type)
			if(Action && (IsFunc(Plugin[Action.Function]) || IsFunc(this[Action.Function])))
			{
				this.History.Insert(2, this.Filter)
				while(this.History.MaxIndex() > 10)
					this.History.Delete(11)
				if(IsFunc(Plugin[Action.Function]))
					KeepAccessorOpen := Plugin[Action.Function](this, ListEntry)
				else if(IsFunc(this[Action.Function]))
					KeepAccessorOpen := this[Action.Function](ListEntry, this.Plugins.GetItemWithValue("Type", ListEntry.Type))
				
				if(!KeepAccessorOpen && this.GUI)
					this.GUI.Close()
			}
		}
	}
	ShowActionMenu()
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			Menu, AccessorContextMenu, Add, test, AccessorContextMenu
			Menu, AccessorContextMenu, DeleteAll
			Menu, AccessorContextMenu, Add, % ListEntry.Actions.DefaultAction.Name, AccessorContextMenu
			Menu, AccessorContextMenu, Default, % ListEntry.Actions.DefaultAction.Name
			outputdebug % isobject(ListEntry.Actions)
			for key, action in ListEntry.Actions				
				Menu, AccessorContextMenu, Add, % action.Name, AccessorContextMenu
			Menu, AccessorContextMenu, Show
		}
	}
	Run(ListEntry, Plugin)
	{
		if(ListEntry.Path)
		{
			WorkingDir := GetWorkingDir(ListEntry.Path)
			CProgramLauncherPlugin.AddToCache(ListEntry)
			Run(Quote(ListEntry.Path) (ListEntry.args ? " " ListEntry.args : ""), WorkingDir)
		}
	}
	RunAsAdmin(ListEntry, Plugin)
	{
		if(ListEntry.Path)
		{
			WorkingDir := GetWorkingDir(ListEntry.Path)
			CProgramLauncherPlugin.AddToCache(ListEntry)
			Run(Quote(ListEntry.Path) (ListEntry.args ? " " ListEntry.args : ""), WorkingDir, "", 0)
		}
	}
	RunWithArgs(ListEntry, Plugin)
	{
		if(ListEntry.Path)
		{
			CProgramLauncherPlugin.AddToCache(ListEntry)
			Event := new CEvent()
			Event.Name := "Run with arguments"
			Event.Temporary := true
			Event.Actions.Insert(new CInputAction())
			Event.Actions[1].Text := "Enter program arguments"
			Event.Actions[1].Title := "Enter program arguments"
			Event.Actions[1].Cancel := true
			Event.Actions.Insert(new CRunAction())
			Event.Actions[2].Command := """" ListEntry.Path """ ${Input}"
			Event.Actions[2].WorkingDirectory := GetWorkingDir(ListEntry.Path)
			EventSystem.TemporaryEvents.RegisterEvent(Event)
			Event.TriggerThisEvent()
		}
	}
	Copy(ListEntry, Plugin, Field = "Path")
	{
		Clipboard := ListEntry[Field]
		return 1
	}
	
	OpenExplorer(ListEntry, Plugin)
	{
		if(type := FileExist(ListEntry.Path))
		{
			if(!InStr(type,"D"))
				Run(A_WinDir "\explorer.exe /Select," ListEntry.Path)
			else
				Run(A_WinDir "\explorer.exe /n,/e," ListEntry.Path)
		}
	}
	OpenCMD(ListEntry, Plugin)
	{
		if(path := ListEntry.Path)
		{
			if(!InStr(FileExist(path),"D"))
				SplitPath, path,, path
			Run("cmd.exe /k cd /D """ path """", GetWorkingDir(ListEntry.Path))
		}
	}
	ExplorerContextMenu(ListEntry, Plugin)
	{
		if(ListEntry.Path)
		{
			ShellContextMenu(ListEntry.Path)
			return 1
		}
	}
}
AccessorContextMenu:
CAccessor.Instance.PerformAction(A_ThisMenuItem)
return

Class CAccessorGUI extends CGUI
{
	EditControl := this.AddControl("Edit", "EditControl", "w800 y10 -Multi", "")
	ListView := this.AddControl("ListView", "ListView", "w800 y+10 AltSubmit 0x8 -Multi R15 NoSortHdr", "Title|Path| | |")
	btnOK := this.AddControl("Button", "btnOK", "y10 x+10 w75", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "y+8 w75", "&Cancel")
	StatusBar := this.AddControl("Statusbar", "StatusBar", "", "")
	__new()
	{
		this.MinimizeBox := false
		this.MaximizeBox := false
		this.AlwaysOnTop := true
		this.Caption := false
		this.Border := true
		this.Title := "7Plus Accessor"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		this.ListView.IndependentSorting := true
		this.ListView.ModifyCol()
		;~ this.GUI.ListView.ModifyCol(1, "Auto") ; icon column
		;~ this.GUI.ListView.(2, 0) ; hidden column for row number    
		this.ListView.ModifyCol(1, 300) ;Col_3_w) ; resize title column
		this.ListView.ModifyCol(2, 330) ; resize path column
		this.ListView.ModifyCol(3, 55)
		this.ListView.ModifyCol(4, "AutoHdr") ; OnTop
		
		this.OnGUIMessage(0x06,"WM_ACTIVATE")
	}
	SetFilter(Text)
	{
		this.EditControl.Text := Text
	}
	EditControl_TextChanged()
	{
		;Logic is handled in CAccessor
		CAccessor.Instance.OnFilterChanged(this.EditControl.Text)
	}
	WM_ACTIVATE(msg, wParam, lParam, hwnd)
	{
		if(!this.IsDestroyed && wParam = 0 && lParam = this.hwnd)
			this.Close()
	}
	ListView_SelectionChanged()
	{
		;Logic is handled in CAccessor
		CAccessor.Instance.OnSelectionChanged()
	}
	ListView_DoubleClick()
	{
		;Logic is handled in CAccessor
		CAccessor.Instance.OnDoubleClick()
	}
	ListView_ContextMenu()
	{
		CAccessor.Instance.ShowActionMenu()
	}
	PreClose()
	{
		if(!this.IsDestroyed)
			CAccessor.Instance.OnClose()
	}
	btnCancel_Click()
	{
		this.Close()
	}
	btnOK_Click()
	{
		CAccessor.Instance.PerformAction()
	}
	
	OnUp()
	{
		if(GetKeyState("Control", "P"))
		{
			if(History := CAccessor.Instance.ChangeHistory(1))
			{
				this.EditControl.Text := History
				SendMessage, 0xC1, -1,,, % "ahk_id " this.EditControl.hwnd ; EM_LINEINDEX (Gets index number of line)
				CaretTo := ErrorLevel
				SendMessage, 0xB1, 0, CaretTo,, % "ahk_id " this.EditControl.hwnd ;EM_SETSEL
			}
		}
		else if(this.ListView.SelectedItems.MaxIndex() = 1)
		{
			selected := this.ListView.SelectedIndex
			count := this.ListView.Items.MaxIndex()
			selected := Mod(selected + count - 2, count) + 1
			this.ListView.Items[selected].Modify("Select Vis")
		}
	}
	OnDown()
	{
		if(GetKeyState("Control", "P"))
		{
			if(History := CAccessor.Instance.ChangeHistory(-1))
			{
				this.EditControl.Text := History
				SendMessage, 0xC1, -1,,, % "ahk_id " this.EditControl.hwnd ; EM_LINEINDEX (Gets index number of line)
				CaretTo := ErrorLevel
				SendMessage, 0xB1, 0, CaretTo,, % "ahk_id " this.EditControl.hwnd ;EM_SETSEL
			}
		}
		else if(this.ListView.SelectedItems.MaxIndex() = 1)
		{
			selected := this.ListView.SelectedIndex
			selected := Mod(selected, this.ListView.Items.MaxIndex()) + 1
			this.ListView.Items[selected].Modify("Select Vis")
		}
	}
}


AccessorPrioritySort(First,Second)
{
	return CAccessor.Plugins[First].Priority = CAccessor.Plugins[Second].Priority ? First > Second ? 1 : First < Second ? -1 : 0 : CAccessor.Plugins[First].Priority < CAccessor.Plugins[Second].Priority ? 1 : -1
}
#if CAccessor.Instance.GUI
Tab::Down
*Up::CAccessor.Instance.GUI.OnUp()
*Down::CAccessor.Instance.GUI.OnDown()
#if
#if CAccessor.Instance.GUI && CAccessor.Instance.GUI.ActiveControl = CAccessor.Instance.GUI.EditControl
PgUp::
PostMessage, 0x100, 0x21, 0,, % "ahk_id " CAccessor.Instance.GUI.ListView.hwnd
return
PgDn::
PostMessage, 0x100, 0x22, 0,, % "ahk_id " CAccessor.Instance.GUI.ListView.hwnd
return
AppsKey::
PostMessage, 0x100, 0x5D, 0,, % "ahk_id " CAccessor.Instance.GUI.ListView.hwnd
return
#if

#if CAccessor.Instance.GUI && (!CAccessor.Instance.SingleContext || !CAccessor.Plugins.GetItemWithValue("Type", CAccessor.Instance.SingleContext).HandlesEnter)
Enter::
NumpadEnter::
CAccessor.Instance.PerformAction()
return
#if

#if CAccessor.Instance.GUI && !Edit_TextIsSelected("", "ahk_id " CAccessor.Instance.GUI.EditControl.hwnd)
^c::
CAccessor.Instance.PerformAction(CAccessor.CActions.Copy)
return
#if

;~ AccessorContextMenu:
;~ AccessorContextMenu()
;~ return
;~ AccessorContextMenu()
;~ {
	;~ global AccessorPlugins
	;~ if(A_GuiControl = "AccessorListView")
	;~ {
		;~ selected := A_EventInfo
		;~ if(!selected)
			;~ return
		
		;~ Menu, AccessorMenu, add, 1,AccessorOK
		;~ Menu, AccessorMenu, DeleteAll
		;~ if(AccessorListEntry := AccessorGetSelectedListEntry())
		;~ {
			;~ if(AccessorPlugin := AccessorPlugins.GetItemWithValue("Type", AccessorListEntry.Type))
			;~ {
				;~ AccessorPlugin.SetupContextMenu(AccessorListEntry)
				;~ Menu, AccessorMenu, Show
			;~ }
		;~ }
	;~ }
;~ }

Class CAccessorPluginSettingsWindow extends CGUI
{
	PluginGUI := object("x",38,"y",80)
	Width := 500
	Height := 560
	btnHelp := this.AddControl("Button", "btnHelp", "x" this.PluginGUI.x " y" (this.Height - 34) " w70 h23", "&Help")
	btnOK := this.AddControl("Button", "btnOK", "x" (this.Width - 174) " y" (this.Height - 34) " w70 h23 Default", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "x" (this.Width - 94) " y" (this.Height - 34) " w70 h23", "&Cancel")
	grpPlugin := this.AddControl("GroupBox", "grpPlugin", "x28 y62 w" (this.Width - 54) " h" (this.Height - 110), "&Options")
	
	__new(Plugin, OriginalPlugin)
	{
		this.DestroyOnClose := true
		this.CloseOnEscape := true
		SettingsWindow.Enabled := false
		this.Owner := SettingsWindow.hwnd
		this.ToolWindow := true
		this.OwnDialogs := true
		if(!Plugin)
			this.Close()
		else
			this.Plugin := Plugin
		Gui, % this.GUINum ":Default"
		this.txtDescription := this.AddControl("Text", "txtDescription", "x40 y18", OriginalPlugin.Description)
		hwnd := AddControl(Plugin.Settings, this.PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
		if(!Plugin.Settings.HasKey("Keyword"))
			GuiControl, % this.GUINum ":Disable", %hwnd%
		
		AddControl(Plugin.Settings, this.PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:")
		
		hwnd := AddControl(Plugin.Settings, this.PluginGUI, "Checkbox", "KeywordOnly", "Keyword Only")
		if(!Plugin.Settings.HasKey("KeywordOnly"))
			GuiControl, % this.GUINum ":Disable", %hwnd%
		
		this.OriginalPlugin := OriginalPlugin
		OriginalPlugin.ShowSettings(Plugin.Settings, this, this.PluginGUI)
	}
	PreClose()
	{
		if(SettingsWindow)
		{
			SettingsWindow.Enabled := true
			SettingsWindow.OnAccessorPluginSettingsWindowClosed(this.ModifiedPlugin)
		}
	}
	btnOK_Click()
	{
		
		if(this.OriginalPlugin.SaveSettings(this.Plugin.Settings, this, this.PluginGUI) != false)
		{
			SubmitControls(this.Plugin.Settings, this.PluginGUI)
			this.ModifiedPlugin := this.Plugin
			this.Close()
		}
	}
	btnCancel_Click()
	{
		this.Close()
	}
	btnHelp_Click()
	{
		run % "http://code.google.com/p/7plus/wiki/docsAccessor" this.Plugin.Type ",,UseErrorLevel"
	}
}

Class CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	;~ Type := CAccessor.RegisterType("Type", CAccessorPlugin)
	;The actual priority of this plugin in the current state. Depends on the context
	Priority := 0
	;True if this plugin handles the enter key manually.
	HandlesEnter := 0
	;Settings specific to this plugin
	Settings := new this.CSettings()
	Description := "No description here, move along"
	
	;This class contains settings for an Accessor plugin. The values shown here are required for all plugins!
	;Commented values can be read-only.
	Class CSettings extends CRichObject
	{
		;Disabled plugins are ignored.
		Enabled := true
		
		;The keyword is used to show only entries from this plugin as results
		;~ Keyword := ""
		
		;The default priority of this plugin when Accessor opens.
		;The plugin may use a higher priority when the context requires it in OnOpen()
		BasePriority := 0
		
		;If true, the results from this plugin are only shown when the keyword is entered in the query.
		;~ KeywordOnly := false
		
		;Minimum amount of characters required to show results from this plugin. Used for speed and cleaner result lists.
		MinChars := 2
		
		;Called when properties of this class are loaded. The plugin usually doesn't need to load the properties manually.
		Load(XML)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base" && XML.HasKey(key))
					this[key] := XML[key]
		}
		
		;Code below demonstrates read-only properties. They are still saved to disk but the values from disk aren't used.
		;The property itself must not be declared in this class. Common read-only properties will be disabled in settings dialog.
		;~ __get(Name)
		;~ {
			;~ if(Name = "KeywordOnly")
				;~ return false
		;~ }
		;~ __set(Name, Value)
		;~ {
			;~ if(Name = "KeywordOnly")
				;~ return false
		;~ }
	}
	
	;A template class containing default actions that can be used in plugins
	Class CActions
	{
		static Run := new CAccessor.CAction("Run", "Run")
		static RunAsAdmin := new CAccessor.CAction("Run as admin", "RunAsAdmin")
		static RunWithArgs := new CAccessor.CAction("Run with arguments", "RunWithArgs")
		static Copy := new CAccessor.CAction("Copy path", "Copy")
		static OpenExplorer := new CAccessor.CAction("Open in Explorer", "OpenExplorer")
		static OpenCMD := new CAccessor.CAction("Open in CMD", "OpenCMD")
		static ExplorerContextMenu := new CAccessor.CAction("Explorer context menu", "ExplorerContextMenu")
	}
	
	;An object representing a result of an Accessor query
	Class CResult
	{
		;The array contains all possible actions on this result (of type CAccessor.CAction).
		;It needs to have a DefaultAction member which is not included in the array itself.
		Actions := Array()
		Type := "Unset"
		Icon := CAccessor.GenericIcons.Application
		Title := ""
		Path := ""
		Detail1 := ""
		Detail2 := ""
	}
	
	__New()
	{
	}
	ShowSettings(Settings, GUI, PluginGUI)
	{
	}
	
	;Called to find out if the plugin wants to have only its results displayed in the current context.
	IsInSinglePluginContext(Filter, LastFilter)
	{
	}
	
	;Called to allow the plugin to adjust the strings displayed on the GUI
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
	}
	
	OnOpen(Accessor)
	{
	}
	OnClose(Accessor)
	{
	}
	OnExit(Accessor)
	{
	}
	
	;Called to get the results from this plugin
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
	}
	
	;Called when a result from this plugin was double clicked on the GUI. Needs to return true if it was handled
	OnDoubleClick(ListEntry)
	{
		return false
	}
	;Called when the query is changed.
	;This function should return true if the new query string requires an update of the results from this plugin
	OnFilterChanged(ListEntry, Filter, LastFilter)
	{
		return true
	}
	;~ OnKeyDown()
	;~ {
	;~ }
	SetupContextMenu(Accessor, ListEntry)
	{
	}
}

;~ #include %A_ScriptDir%\Accessor\AccessorEventPlugin.ahk
;~ #include %A_ScriptDir%\Accessor\Calc.ahk
;~ #include %A_ScriptDir%\Accessor\ExplorerHistory.ahk
;~ #include %A_ScriptDir%\Accessor\FastFolders.ahk
;~ #include %A_ScriptDir%\Accessor\FileSystem.ahk
;~ #include %A_ScriptDir%\Accessor\Google.ahk
;~ #include %A_ScriptDir%\Accessor\Notepad++.ahk
;~ #include %A_ScriptDir%\Accessor\Notes.ahk
;~ #include %A_ScriptDir%\Accessor\ProgramLauncher.ahk
#include %A_ScriptDir%\Accessor\CProgramLauncherPlugin.ahk
;~ #include %A_ScriptDir%\Accessor\SciTE4AutoHotkey.ahk
;~ #include %A_ScriptDir%\Accessor\WindowSwitcher.ahk
;~ #include %A_ScriptDir%\Accessor\Uninstall.ahk
;~ #include %A_ScriptDir%\Accessor\URL.ahk
;~ #include %A_ScriptDir%\Accessor\Weather.ahk
;~ #include %A_ScriptDir%\Accessor\Run.ahk