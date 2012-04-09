Class CAccessor
{
	;The GUI representing the Accessor
	GUI := ""
	
	;History of previous entries
	History := []
	
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
	
	Class CSettings
	{
		LargeIcons := false
		CloseWhenDeactivated := true
		TitleBar := false
		UseAero := true
		Transparency := 0 ;0 to 255. 0 is considered opaque here so the attribute isn't set
		Width := 900
		Height := 360
		OpenInMonitorOfMouseCursor := true ;If true, Accessor window will open in the monitor where the mouse cursor is.
		UseSelectionForKeywords := true ;If set, the selected text will automatically be used as ${1} parameter in keywords if no text is typed
		__new(XML)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base" && XML.HasKey(key))
					this[key] := XML[key]
		}
		Save(ByRef XML)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base")
					XML[key] := value
		}
	}
	;An action that can be performed on an Accessor result
	Class CAction extends CRichObject
	{
		; Name: Appears in context menus and on the OK button.
		; Function: Called to carry out the action. 
		; Condition: Called to check if this action is valid in the current context. Supports Delegates
		; SaveHistory: If true, the result will be saved in the history when this action is performed.
		; Close: If true, Accessor will be closed after this action is performed.
		; AllowDelayedExecution: If true, this action will be visible when a timer is set by the user
		__new(Name, Function, Condition = "", SaveHistory = true, Close = true, AllowDelayedExecution = true)
		{
			this.Name := Name
			this.Function := Function
			this.Condition := Condition
			this.SaveHistory := SaveHistory
			this.Close := Close
			this.AllowDelayedExecution := AllowDelayedExecution
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
		
		;Create and load settings
		this.Settings := new this.CSettings(XMLObject)
		
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
		this.GenericIcons.7plus := ExtractIcon(A_ScriptDir "\7+-w.ico")
	}
	Show(Action)
	{
		if(this.GUI)
			return
		
		;Active window for plugins that depend on the context
		this.PreviousWindow := WinExist("A")

		;Store current selection so it can be inserted into keyword queries
		this.CurrentSelection := GetSelectedText()

		;Create and show GUI
		this.GUI := new CAccessorGUI()
		this.GUI.Show()
		;Redraw is needed because Aero can cause rendering issues without it
		this.GUI.Redraw()
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
	
	;Sets the filter and tries to wait (for max. 5 seconds) until results are there
	SetFilter(Text)
	{
		this.Filter := Text
		this.SuppressListViewUpdate := true
		this.GUI.SetFilter(Text)
		SetTimerF(this.WaitTimer := new Delegate(this, "WaitForRefresh"), -100)
	}
	WaitForRefresh()
	{
		static count := 0
		if(this.SuppressListViewUpdate && count < 50)
		{
			count++
			SetTimerF(this.WaitTimer, -100)
		}
		else
		{
			count := 0
			this.Remove(this.WaitTimer)
			this.OnFilterChanged(this.Filter)
		}
	}
	OnFilterChanged(Filter)
	{
		this.Filter := Filter
		if(this.SuppressListViewUpdate)
		{
			this.SuppressListViewUpdate := false
			return
		}
		ListEntry := this.List[this.GUI.ListView.SelectedIndex]
		
		NeedsUpdate := 1
		for index, Plugin in this.Plugins ;Check if single context plugin requests an update
		{
			if(Plugin.Settings.Enabled && SingleContext := ((Plugin.Settings.Keyword && Filter && InStr(Filter, Plugin.Settings.Keyword) = 1) || Plugin.IsInSinglePluginContext(Filter, this.LastFilter)))
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
				if(Plugin.Settings.Enabled && !Plugin.Settings.KeywordOnly)
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
	ExpandFilter(ByRef Filter, LastFilter, ByRef Time)
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
		
		;Mighty timer parsing
		if(InStr(Filter, " in "))
		{
			if(pos := RegexMatch(Filter, "iJ) in (?:(?<m>\d+) *(?:minutes?|mins?|m)?$|(?<h>\d+) *(?:hours?|h)$|(?<s>\d+) *(?:seconds?|secs?|s)$|(?<m>\d+) *(?:minutes?|mins?|m)?(?:[ ,]+(?<s>\d+) *(?:seconds?|secs?|s)?)?$|(?<h>\d+) *(?:hours?|h)(?:[ ,]+(?<m>\d+) *(?:minutes?|mins?|m))?(?:[ ,]+(?<s>\d+) *(?:seconds?|secs?|s)?)?$|(?:(?<h>\d+):)?(?<m>\d+)(?::(?<s>\d+))?$)", Timer))
			{
				Filter := SubStr(Filter, 1, pos - 1)
				Time := (Timerh ? Timerh * 3600 : 0) + (Timerm ? Timerm * 60 : 0) + (Timers ? Timers : 0)
			}
		}

		;Parse parameters. They are split by spaces. Quotes (" ") can be used to treat multiple words as one parameter. The first parameter is the Filter variable without the options.
		Parameters := Array()
		p0 := Parse(Filter, "q"")1 2 3 4 5 6 7 8 9 10", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)

		;Make parameters available to events
		All := ""
		Loop 9
		{
			Index := A_Index + 1
			EventSystem.GlobalPlaceholders.Remove("Acc" A_Index)
			EventSystem.GlobalPlaceholders.Insert("Acc" A_Index, p%Index%)
			All .= (A_Index = 1 ? "" : " ") p%Index%
		}
		EventSystem.GlobalPlaceholders.Remove("AccAll")
		EventSystem.GlobalPlaceholders.Insert("AccAll", All)

		Loop % min(p0, 10)
			Parameters.Insert(A_Index - 1, p%A_Index%) ;Store parameters with offset of -1, so p1 will become p0 since it isn't a real parameter but rather the keyword
		
		if(UsingKeyword)
		{
			if(InStr(Filter, "${1}"))
				Filter := p1 ;If atleast one placeholder is used, all parameters will be inserted

			UsingPlaceholder := false
			;Code below treats the ${1}-${10} placeholders that may be used with keywords, e.g. to launch a search engine url with a specific query.
			for Index2, Parameter in Parameters
			{
				if(Index2 = 0)
					continue
				;If this is the last placeholder used in the query, insert all parameters into it so queries with spaces become possible for the last placeholder
				if(InStr(Filter, "${" Index2 "}") && !InStr(Filter, "${" (Index2 + 1) "}"))
				{
					CollectedParameters := Parameter
					Loop % Parameters.MaxIndex() - Index2
						CollectedParameters .= " " Parameters[A_Index + Index2]
					Filter := StringReplace(Filter, "${" Index2 "}", CollectedParameters, "ALL")
					UsingPlaceholder := true
					break
				}
				else if(InStr(Filter, "${" Index2 "}"))
				{
					Filter := StringReplace(Filter, "${" Index2 "}", Parameter, "ALL")
					UsingPlaceholder := true
				}
				else
					break
			}
			if(UsingPlaceholder)
				Parameters := Array() ;Clear parameters since they are now integrated in the query
			;if no parameters are entered after query, lets try to insert the current selection so the user can quickly search for it with a keyword query.
			else if(this.CurrentSelection && this.Settings.UseSelectionForKeywords && InStr(Filter, "${1}"))
				Filter := StringReplace(Filter, "${1}", this.CurrentSelection, "ALL")
		}
		return Parameters
	}
	
	;This is the main function that populates the Accessor list.
	RefreshList()
	{
		if(!this.GUI)
			return
		LastFilter := this.LastFilter
		Filter := this.Filter
		Parameters := this.ExpandFilter(Filter, LastFilter, Time)

		if(Time)
			FormattedTime := "in " Floor(Time/3600) ":" Floor(Mod(Time, 3600) / 60) ":" Floor(Mod(Time, 60))

		;Plugins which need to use the filter string without any preparsing should use this one which doesn't contain the timer at the end
		this.FilterWithoutTimer := Filter

		this.GUI.ListView.Redraw := false
		
		this.GUI.ListView.Items.Clear()
		this.GUI.ListView.ImageListManager.Clear()
		this.List := Array()
		
		;Find out if we are in a single plugin context, and add only those items
		for index, Plugin in this.Plugins
		{
			if(Plugin.Settings.Enabled && ((Time > 0 && Plugin.AllowDelayedExecution) || !Time) && SingleContext := ((Plugin.Settings.Keyword && Filter && KeywordSet := InStr(Filter, Plugin.Settings.Keyword " ") = 1) || Plugin.IsInSinglePluginContext(Filter, LastFilter)))
			{
				if(KeywordSet && this.CurrentSelection && this.Settings.UseSelectionForKeywords && Filter = Plugin.Settings.Keyword " ")
					Filter .= this.CurrentSelection
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
			for index2, Plugin in this.Plugins
				Pluginlist .= (Pluginlist ? "," : "") index2
			Sort, Pluginlist, F AccessorPrioritySort D`,
			Loop, Parse, Pluginlist, `,
			{
				Plugin := this.Plugins[A_LoopField]
				if(Plugin.Settings.Enabled && ((Time > 0 && Plugin.AllowDelayedExecution) || !Time) && !Plugin.Settings.KeywordOnly && StrLen(Filter) >= Plugin.Settings.MinChars)
				{
					Result := Plugin.RefreshList(this, Filter, LastFilter, False, Parameters)
					if(Result)
						this.List.Extend(Result)
				}
			}
		}

		;Now that items are added, add them to the listview
		for index3, ListEntry in this.List
		{
			if(Time > 0)
			{
				ListEntry.Time := Time
				ListEntry.Detail2 := FormattedTime
			}
			Plugin := this.Plugins.GetItemWithValue("Type", ListEntry.Type)
			Plugin.GetDisplayStrings(ListEntry, Title := ListEntry.Title, Path := ListEntry.Path, Detail1 := ListEntry.Detail1, Detail2 := ListEntry.Detail2)
			item := this.GUI.ListView.Items.Add("", Title, Path, Detail1, Detail2)
			item.Icon := ListEntry.Icon
		}

		this.LastFilter := Filter
		this.LastParameters := Parameters
		selected := LV_GetNext()
		if(this.GUI.ListView.SelectedItems.MaxIndex() != 1)
			this.GUI.ListView.SelectedIndex := 1

		this.GUI.ListView.ModifyCol(1, Round(this.GUI.ListView.Width * 3 / 8)) ;Col_3_w) ; resize title column
		this.GUI.ListView.ModifyCol(2, Round(this.GUI.ListView.Width * 3.3 / 8)) ; resize path column
		this.GUI.ListView.ModifyCol(3, Round(this.GUI.ListView.Width * 0.8 / 8)) ; resize detail1 column
		this.GUI.ListView.ModifyCol(4, "AutoHdr") ; resize detail2 column

		this.GUI.ListView.Redraw := true

		;Set default text when no results and set enabled state
		if(!(this.GUI.btnOK.Enabled := this.List.MaxIndex()))
			this.GUI.btnOK.Text := "Run"
	}
	
	;Registers an Accessor plugin with this class. This needs to be done
	RegisterPlugin(Type, Plugin)
	{
		this.Plugins.Insert(Plugin)
		return Type
	}
	Close()
	{
		;Needs to be delayed because it is called from within a message handler which is critical.
		SetTimerF(new Delegate(this.GUI, "Close"), -10)
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
			XMLObject[Plugin.Type] := PluginSettings := {}
			Plugin.Settings.Save(PluginSettings)
			Plugin.OnExit(this)
		}
		XMLObject.Keywords := Object("Keyword", this.Keywords)
		this.Settings.Save(XMLObject)
		XML_Save(XMLObject, Settings.ConfigPath "\Accessor.xml")
		
		;Clean up
		DestroyIcon(this.GenericIcons.Application)
		DestroyIcon(this.GenericIcons.File)
		DestroyIcon(this.GenericIcons.Folder)
		DestroyIcon(this.GenericIcons.URL)
	}
	OnSelectionChanged()
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			if(this.GUI.btnOK.Text != ListEntry.Actions.DefaultAction.Name)
				this.GUI.btnOK.Text := ListEntry.Actions.DefaultAction.Name
			if(!ListEntry.Actions.DefaultAction.Condition || ListEntry.Actions.DefaultAction.Condition.(ListEntry))
				this.GUI.btnOK.Enabled := true
			else
				this.GUI.btnOK.Enabled := false
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
		this.Filter := ""
		this.GUI := ""
		this.List := ""
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
	PerformAction(Action = "", ListEntry = "")
	{
		outputdebug % "PerformAction: " ListEntry.path
		this.Remove("ClickedListEntry") ;Not needed anymore
		if(IsObject(ListEntry) || IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
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
				if(ListEntry.Time > 0)
				{
					Event := new CEvent()
					Event.Name := "Timed Accessor Result"
					Event.Temporary := true
					Event.Trigger := new CTimerTrigger()
					Event.Trigger.Time := ListEntry.Time * 1000
					Event.Trigger.ShowProgress := true
					Event.Trigger.Text := ListEntry.Title " " ListEntry.Path
					Event.Actions.Insert(new CAccessorResultAction())

					Copy := this.CopyResult(ListEntry)
					Copy.Remove("Time")
					Event.Actions[1].Result := Copy
					Event.Actions[1].Action := Action
					EventSystem.TemporaryEvents.RegisterEvent(Event)
					Event.Enable()
					;Event.TriggerThisEvent()
				}
				else
				{
					;Call PreExecute function to notify plugins of execution
					for index, p in this.Plugins
						p.OnPreExecute(this, ListEntry, Action, Plugin)
					;Update filter history
					this.History.Insert(2, this.Filter)
					while(this.History.MaxIndex() > 10)
						this.History.Remove()
					if(IsFunc(Plugin[Action.Function]))
						Plugin[Action.Function](this, ListEntry, Action)
					else if(IsFunc(this[Action.Function]))
						this[Action.Function](ListEntry, this.Plugins.GetItemWithValue("Type", ListEntry.Type), Action)
				}
				if(Action.Close && this.GUI)
					this.GUI.Close()
			}
		}
	}
	;Used to copy an Accessor result
	CopyResult(Result)
	{
		; NOTE: Actions can contain references to the plugin which mustn't be copied and is not changed, so we may use a reference to it
		Actions := Result.Remove("Actions")
		Copy := Result.DeepCopy()
		Copy.Actions := Actions
		Result.Actions := Actions
		return Copy
	}
	ShowActionMenu(ListEntry = "")
	{
		if(IsObject(ListEntry) || IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]) || IsObject(ListEntry := this.Plugins.GetItemWithValue("Type", this.SingleContext).Result))
		{
			outputdebug % "actionmenu: " ListEntry.path
			Menu, AccessorContextMenu, Add, test, AccessorContextMenu
			Menu, AccessorContextMenu, DeleteAll
			if((!ListEntry.Actions.DefaultAction.Condition || ListEntry.Actions.DefaultAction.Condition.(ListEntry)) && ((ListEntry.Time > 0 && ListEntry.Actions.DefaultAction.AllowDelayedExecution) || !ListEntry.Time))
			{
				entries := true
				Menu, AccessorContextMenu, Add, % ListEntry.Actions.DefaultAction.Name, AccessorContextMenu
				Menu, AccessorContextMenu, Default, % ListEntry.Actions.DefaultAction.Name
			}
			for key, action in ListEntry.Actions
				if((!action.Condition || action.Condition.(ListEntry)) && ((ListEntry.Time > 0 && action.AllowDelayedExecution) || !ListEntry.Time))
				{
					entries := true
					Menu, AccessorContextMenu, Add, % action.Name, AccessorContextMenu
				}
			if(entries)
				Menu, AccessorContextMenu, Show
		}
	}
	;Checks if the selected result has a specific action
	HasAction(Action)
	{
		if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
			return ListEntry.Actions.DefaultAction.Function = Action.Function || ListEntry.Actions.FindKeyWithValue("Function", Action.Function)
	}
	;Runs the selected entry as command and possibly caches it in program launcher plugin
	Run(ListEntry, Plugin)
	{
		if(ListEntry.Path)
		{
			WorkingDir := GetWorkingDir(ListEntry.Path)
			
			;Cache if executable file is being run
			Path := ListEntry.Path
			SplitPath, Path,,,ext
			if(FileExist(ListEntry.Path) && InStr("exe,cmd,bat,ahk", ext))
				CProgramLauncherPlugin.Instance.AddToCache(ListEntry)
			
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
			ShellContextMenu(ListEntry.Path)
	}
	OpenPathWithAccessor(ListEntry, Plugin)
	{
		if(ListEntry.Path)
			this.SetFilter(ListEntry.Path (strEndsWith(ListEntry.Path, "\") ? "" : "\"))
	}
}
AccessorContextMenu:
CAccessor.Instance.PerformAction(A_ThisMenuItem, CAccessor.Instance.ClickedListEntry) ;ClickedListEntry is only valid for clicks on empty parts of the window
return

Class CAccessorGUI extends CGUI
{
	Width := CAccessor.Instance.Settings.Width
	Height := CAccessor.Instance.Settings.Height
	EditControl := this.AddControl("Edit", "EditControl", "w" this.Width - 94 " y10 -Multi", "")
	ListView := this.AddControl("ListView", "ListView", "w" this.Width - 94 " y+10 h" (this.Height - 46) " AltSubmit 0x8 -Multi NoSortHdr", "Title|Path| | |")
	btnOK := this.AddControl("Button", "btnOK", "y10 x+10 w75 section Default", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "y+8 w75", "&Cancel")
	btnConfigKeywords := this.AddControl("Button", "btnConfigKeywords", "xs+0 y" this.Height - 56 " w75", "&Keywords")
	btnConfigPlugins := this.AddControl("Button", "btnConfigPlugins", "xs+0 y" this.Height - 28 " w75", "&Plugins")
	__new()
	{
		if(CAccessor.Instance.Settings.OpenInMonitorOfMouseCursor)
		{
			Monitor := FindMonitorFromMouseCursor()
			this.X := (Monitor.Right - Monitor.Left) / 2 - this.Width / 2
			this.Y := (Monitor.Bottom - Monitor.Top) / 2 - this.Height / 2
		}
		else
		{
			this.X := A_ScreenWidth / 2 - this.Width / 2
			this.Y := A_ScreenHeight / 2 - this.Height / 2
		}
		this.MinimizeBox := false
		this.MaximizeBox := false
		this.AlwaysOnTop := true
		DllCall("dwmapi\DwmIsCompositionEnabled","IntP", DWMEnabled)
		if(!CAccessor.Instance.Settings.TitleBar && (CAccessor.Instance.Settings.UseAero && WinVer >= WIN_Vista && DWMEnabled))
			this.SysMenu := false
		else if(!CAccessor.Instance.Settings.TitleBar)
			this.Caption := false
			
		this.Border := true
		this.Title := "7Plus Accessor"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		if(CAccessor.Instance.Settings.UseAero && WinVer >= WIN_Vista && DWMEnabled)
		{
			VarSetCapacity(margin,16)
			NumPut(-1,&margin,0,Uint)
			NumPut(-1,&margin,4,Uint)
			NumPut(-1,&margin,8,Uint)
			NumPut(-1,&margin,12,Uint)
			Gui, % this.GUINum ":Color", 0x070809
			WinSet,TransColor,0x070809,% "ahk_id " this.hwnd 
			DllCall("Dwmapi.dll\DwmExtendFrameIntoClientArea", "Ptr", this.hwnd, "Ptr", &margin)
		}
		else
			this.txtConfig := this.AddControl("Text", "txtConfig", "xs+0 y" this.Height - 71, "Config:")
		
		if(CAccessor.Instance.Settings.Transparency)
			WinSet, Trans, % CAccessor.Instance.Settings.Transparency, % "ahk_id " this.hwnd
		
		this.ListView.LargeIcons := CAccessor.Instance.Settings.LargeIcons
		this.ListView.IndependentSorting := true
		this.ListView.ModifyCol(1, Round(this.ListView.Width * 3 / 8)) ;Col_3_w) ; resize title column
		this.ListView.ModifyCol(2, Round(this.ListView.Width * 3.3 / 8)) ; resize path column
		this.ListView.ModifyCol(3, Round(this.ListView.Width * 0.8 / 8)) ; resize detail1 column
		this.ListView.ModifyCol(4, "AutoHdr") ; resize detail2 column
		this.OnMessage(0x06,"WM_ACTIVATE")
		this.Redraw()
	}
	SetFilter(Text)
	{
		this.EditControl.Text := Text
		Edit_Select(strLen(Text), -1, "", "ahk_id " this.EditControl.hwnd)
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
		if(!IsObject(ListEntry := CAccessor.Instance.List[this.ListView.SelectedIndex]) && IsObject(ListEntry := CAccessor.Instance.Plugins.GetItemWithValue("Type", CAccessor.Instance.SingleContext).Result))
			CAccessor.Instance.ClickedListEntry := ListEntry
		CAccessor.Instance.ShowActionMenu()
	}
	ContextMenu()
	{
		if(IsObject(ListEntry := CAccessor.Instance.Plugins.GetItemWithValue("Type", CAccessor.Instance.SingleContext).Result))
		{
			CAccessor.Instance.ClickedListEntry := ListEntry
			CAccessor.Instance.ShowActionMenu(ListEntry)
		}
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
	btnConfigPlugins_Click()
	{
		this.Close()
		SettingsWindow.Show("Plugins")
	}
	btnConfigKeywords_Click()
	{
		this.Close()
		SettingsWindow.Show("Keywords")
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

;#if CAccessor.Instance.GUI && (!CAccessor.Instance.SingleContext || !CAccessor.Plugins.GetItemWithValue("Type", CAccessor.Instance.SingleContext).HandlesEnter)
;Enter::
;NumpadEnter::
;CAccessor.Instance.PerformAction()
;return
;#if


#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.OpenExplorer))
^e::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.OpenExplorer)
return
#if
#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.OpenPathWithAccessor))
^f::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.OpenPathWithAccessor)
return
#if
#if CAccessor.Instance.GUI && !Edit_TextIsSelected("", "ahk_id " CAccessor.Instance.GUI.EditControl.hwnd)
^c::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.Copy)
return
#if

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
		hwnd := AddControl(Plugin.Settings, this.PluginGUI, "Edit", "Keyword", "", "", "Keyword:", "", "", "", "", "You can enter the keyword in Accessor at the beginning of a query to only show results from this plugin.")
		if(!Plugin.Settings.HasKey("Keyword"))
			GuiControl, % this.GUINum ":Disable", %hwnd%
		
		AddControl(Plugin.Settings, this.PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:", "", "", "", "", "The priority of a plugin determines the order of its results in the Accessor window.`n Some plugins dynamically adjust their priority based on the current context.")
		
		hwnd := AddControl(Plugin.Settings, this.PluginGUI, "Checkbox", "KeywordOnly", "Keyword Only", "", "", "", "", "", "", "If checked, this plugin will only show results when its keyword was entered.")
		if(!Plugin.Settings.HasKey("KeywordOnly"))
			GuiControl, % this.GUINum ":Disable", %hwnd%
		if(Plugin.Settings.HasKey("FuzzySearch"))
			AddControl(Plugin.Settings, this.PluginGUI, "Checkbox", "FuzzySearch", "Use fuzzy search (slower)", "", "", "", "", "", "", "Fuzzy search allows this plugin to find programs that don't match exactly.`nThis is good if you mistype a program but it will noticably drain on the Accessor performance.")
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
	
	;The plugin can set if it can be listed by the Accessor history plugin.
	;If the single results from this plugin depend on outer circumstances, such as the existence of a window, it should not be listed
	;since the result may have become invalid.
	SaveHistory := true
	
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
		Save(ByRef XML)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base")
					XML[key] := value
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
		static Copy := new CAccessor.CAction("Copy path`tCTRL + C", "Copy", "", false, false, false)
		static OpenExplorer := new CAccessor.CAction("Open in Explorer`tCTRL + E", "OpenExplorer")
		static OpenCMD := new CAccessor.CAction("Open in CMD", "OpenCMD")
		static ExplorerContextMenu := new CAccessor.CAction("Explorer context menu", "ExplorerContextMenu", "", false, false, false)
		static OpenPathWithAccessor := new CAccessor.CAction("Open path with Accessor`tCTRL + F", "OpenPathWithAccessor", "", false, false, false)
	}
	
	;An object representing a result of an Accessor query.
	; IMPORTANT: All plugins need to only rely on the contents of a result object to perform their actions.
	;            They must not store temporary data in the plugin object that is needed to perform an action.
	;            This is because of the Accessor History plugin that creates copies of results and shows them when the original plugin may not be aware of it.
	;			 The plugin can have a SaveHistory property that indicates if it is indexed by the history plugin.
	;			 When results may not be valid anymore at another time or context this should be set to true.
	Class CResult extends CRichObject
	{
		;The array contains all possible actions on this result (of type CAccessor.CAction).
		;It needs to have a DefaultAction member which is not included in the array itself.
		Actions := Array()
		Type := "Unset"
		Icon := CAccessor.Instance.GenericIcons.Application
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

#include %A_ScriptDir%\Accessor\CEventPlugin.ahk
#include %A_ScriptDir%\Accessor\CProgramLauncherPlugin.ahk
#include %A_ScriptDir%\Accessor\CCalculatorPlugin.ahk
#include %A_ScriptDir%\Accessor\CRecentFoldersPlugin.ahk
#include %A_ScriptDir%\Accessor\CFileSystemPlugin.ahk
#include %A_ScriptDir%\Accessor\CGooglePlugin.ahk
#include %A_ScriptDir%\Accessor\CNotepadPlusPlusPlugin.ahk
#include %A_ScriptDir%\Accessor\CNotePlugin.ahk
#include %A_ScriptDir%\Accessor\CSciTE4AutoHotkeyPlugin.ahk
#include %A_ScriptDir%\Accessor\CWindowSwitcherPlugin.ahk
#include %A_ScriptDir%\Accessor\CUninstallPlugin.ahk
#include %A_ScriptDir%\Accessor\CURLPlugin.ahk
#include %A_ScriptDir%\Accessor\CWeatherPlugin.ahk
#include %A_ScriptDir%\Accessor\CRunPlugin.ahk
#include %A_ScriptDir%\Accessor\CRegistryPlugin.ahk
#include %A_ScriptDir%\Accessor\CKeywordPlugin.ahk
#include %A_ScriptDir%\Accessor\CAccessorHistoryPlugin.ahk ;This should be included last, so it will only show on Accessor opening when other plugins don't show things

/*
Future plugins:
Services
Processes
twitter
Control panel
trillian
winget
*/