Class CAccessor
{
	;The GUI representing the Accessor
	GUI := ""
	
	;History of previous entries
	History := []
	
	;Plugins used by the Accessor
	static Plugins := RichObject()
	
	;The current (singleton) instance
	static Instance
	
	;Data for buttons in GUI that represent queries or results
	Buttons := []

	;Accessor keywords for auto expansion
	Keywords := Array()
	
	;Some generic icons used throughout multiple Accessor plugins
	GenericIcons := {}
	
	;The list of visible entries
	List := Array()
	
	;Current Filter string (as entered by user)
	Filter := ""

	;Previous filter string (as entered by user)
	LastFilter := ""

	;Current filter string without a possibly existing timer string
	FilterWithoutTimer := ""

	;Selected file before Accessor was open
	SelectedFile := ""

	;Directory of a previously active navigateable program
	CurrentDirectory := ""

	;Selected filepath of a previously active navigateable program (first file only)
	CurrentSelection := ""

	;Used to manage parallelism of quick query text changes
	;If the Accessor is currently refreshing, it is instructed to refresh again when the text changes while it is refreshing
	;By doing this it should be possible to always be up to date with the minimum amount of refreshes.
	RepeatRefresh := false
	IsRefreshing := false

	Class CSettings
	{
		LargeIcons := true
		CloseWhenDeactivated := true
		TitleBar := false
		UseAero := true
		Transparency := 0 ;0 to 255. 0 is considered opaque here so the attribute isn't set
		Width := 900
		Height := 600
		OpenInMonitorOfMouseCursor := true ;If true, Accessor window will open in the monitor where the mouse cursor is.
		UseSelectionForKeywords := true ;If set, the selected text will automatically be used as ${1} parameter in keywords if no text is typed
		FuzzySearchThreshold := 0.6
		__new(SavedSettings)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base" && SavedSettings.HasKey(key))
					this[key] := SavedSettings[key]
		}
		Save(SavedSettings)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base")
					SavedSettings[key] := value
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

	;Represents the data for a button in Accessor for storing a query or a result
	Class CAccessorButton
	{
		Text := ""

		;Data for query
		Icon := ""
		Query := ""
		;Selections of query
		SelectionStart := -1
		SelectionEnd := -1

		;Instance of CResult when query is not used
		Result := "" 
		Load(json)
		{
			this.Slot := json.Slot
			this.Text := json.Text
			this.Icon := json.Icon
			this.Query := json.Query
			this.SelectionStart := json.SelectionStart
			this.SelectionEnd := json.SelectionEnd
			this.Result := json.Result
		}
		Save(json)
		{
			json.Slot := this.Slot
			json.Text := this.Text
			json.Icon := this.Icon
			json.Query := this.Query
			json.SelectionStart := this.SelectionStart
			json.SelectionEnd := this.SelectionEnd
			json.Result := this.Result
		}
		Execute()
		{
			Accessor := CAccessor.Instance
			if(this.Query)
				Accessor.SetFilter(this.Query, this.SelectionStart, this.SelectionEnd)
			else
				Accessor.PerformAction("", this.Result)
		}
	}

	;This class tracks the usage history of single Accessor results to improve the ordering in the results list.
	Class CResultUsageTracker
	{
		;Each plugin can define a key which is used to index its results
		Plugins := {}
		;Each time a result is executed its weighting factor is increased by this value divided by the current value + 1.
		static UsageIncrement := 0.1
		;Each time a result is executed all weighting factors are decreased by this value so that often used results can be removed after a while when they haven't been used anymore.
		static TimePenalty := 0.004

		__new()
		{
			this.LoadResultUsageHistory()
		}
		OnExit()
		{
			this.SaveResultUsageHistory()
		}
		LoadResultUsageHistory()
		{
			if(FileExist(Settings.ConfigPath "\AccessorUsageHistory.json"))
			{
				FileRead, json, % Settings.ConfigPath "\AccessorUsageHistory.json"
				this.Plugins := lson(json)
			}
			;Make sure that objects for all plugins exist
			for index, Plugin in CAccessor.Plugins
				if(!this.Plugins.HasKey(Plugin.Type))
					this.Plugins[Plugin.Type] := {}
		}
		SaveResultUsageHistory()
		{
			FileDelete, % Settings.ConfigPath "\AccessorUsageHistory.json"
			string := lson(this.Plugins)
			FileAppend, %string%, % Settings.ConfigPath "\AccessorUsageHistory.json"
		}
		TrackResultUsage(ExecutedResult, Plugin)
		{
			if(!ExecutedResult.ResultIndexingKey)
				return
			;This result has been tracked before
			if(this.Plugins[Plugin.Type].HasKey(ExecutedResult[ExecutedResult.ResultIndexingKey]))
				this.Plugins[Plugin.Type][ExecutedResult[ExecutedResult.ResultIndexingKey]] += this.UsageIncrement / (this.Plugins[Plugin.Type][ExecutedResult[ExecutedResult.ResultIndexingKey]] + 1)
			;New result
			else
				this.Plugins[Plugin.Type][ExecutedResult[ExecutedResult.ResultIndexingKey]] := this.UsageIncrement

			;Add penalty to all results so they will be forgotten over time
			NewPlugin := {}
			for IndexingKey, weighting in this.Plugins[Plugin.Type]
			{
				weighting -= this.TimePenalty
				;Remove weightings which have become too low
				if(weighting > 0)
					NewPlugin[IndexingKey] := weighting
			}
			this.Plugins[Plugin.Type] := NewPlugin
		}
	}

	__new()
	{
		;Singleton
		if(this.Instance)
			return ""
		this.Instance := this
		
		if(FileExist(Settings.ConfigPath "\Accessor.xml"))
		{
			FileRead, xml, % Settings.ConfigPath "\Accessor.xml"
			SavedSettings := XML_Read(xml)
			SavedPluginSettings := SavedSettings
			SavedKeywords := SavedSettings.Keywords.Keyword
			FileDelete, % Settings.ConfigPath "\Accessor.xml"
		}
		else
		{
			FileRead, json, % Settings.ConfigPath "\Accessor.json"
			if(!json)
				SavedSettings := {Plugins : {}}
			else
				SavedSettings := lson(json)
			if(!SavedSettings.HasKey("Keywords"))
			{
				SavedSettings.Keywords := []
				SavedSettings.Keywords.Insert({Key : "leo", 	Command : "http://dict.leo.org/ende?search=${1}"})
				SavedSettings.Keywords.Insert({Key : "google", 	Command : "http://google.com/search?q=${1}"})
				SavedSettings.Keywords.Insert({Key : "w", 		Command : "http://en.wikipedia.org/wiki/Special:Search?search=${1}"})
				SavedSettings.Keywords.Insert({Key : "gm", 		Command : "http://maps.google.com/maps?q=${1}"})
				SavedSettings.Keywords.Insert({Key : "a", 		Command : "http://www.amazon.com/s?url=search-alias`%3Daps&field-keywords=${1}"})
				SavedSettings.Keywords.Insert({Key : "bing", 	Command : "http://www.bing.com/search?q=${1}"})
				SavedSettings.Keywords.Insert({Key : "y", 		Command : "http://www.youtube.com/results?search_query=${1}"})
				SavedSettings.Keywords.Insert({Key : "i", 		Command : "http://www.imdb.com/find?q=${1}"})
				SavedSettings.Keywords.Insert({Key : "wa", 		Command : "http://www.wolframalpha.com/input/?i=${1}"})
				SavedSettings.Keywords.Insert({Key : "ebay", 	Command : "http://www.ebay.com/sch/i.html?_nkw=${1}"})
				SavedSettings.Keywords.Insert({Key : "yahoo", 	Command : "http://de.search.yahoo.com/search?p=${1}"})
			}
			if(!SavedSettings.HasKey("Buttons"))
			{
				outputdebug AddButtons
				SavedSettings.Buttons := []
				Button := new this.CAccessorButton()
				Button.Text := "Google Search"
				Button.Query := "google "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Wikipedia Search"
				Button.Query := "w "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Youtube Search"
				Button.Query := "y "
				Button.Icon := A_ScriptDir "\Icons\Youtube.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Google Maps Search"
				Button.Query := "gm "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Amazon Search"
				Button.Query := "a "
				Button.Icon := A_ScriptDir "\Icons\Amazon.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Weather"
				Button.Query := "weather "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "File Search"
				Button.Query := "find "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Calculator"
				Button.Query := "="
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Notes"
				Button.Query := "note "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
				Button := new this.CAccessorButton()
				Button.Text := "Uninstall"
				Button.Query := "uninstall "
				Button.Icon := A_ScriptDir "\128.png"
				SavedSettings.Buttons.Insert(Button)
			}
			SavedPluginSettings := SavedSettings.Plugins
			SavedKeywords := SavedSettings.Keywords
		}
		;Create and load settings
		this.Settings := new this.CSettings(SavedSettings)
		
		;Init plugins
		for index, Plugin in this.Plugins
		{
			Plugin.Instance := this.Plugins[index] := new Plugin()
			SavedPlugin := IsObject(SavedPluginSettings[Plugin.Type]) ? SavedPluginSettings[Plugin.Type] : {}
			Plugin.Instance.Settings.Load(SavedPlugin)
			Plugin.Instance.Init(SavedPlugin.Settings)
		}
		
		;Init keywords
		;No keywords?
		if(!IsObject(SavedKeywords))
			SavedKeywords := []
		;Single keyword? (Only relevant for xml files)
		if(!SavedKeywords.MaxIndex())
			SavedKeywords := Array(SavedKeywords)

		for index, Keyword in SavedKeywords
			this.Keywords.Insert({Key : Keyword.Key, Command : Keyword.Command})
		
		;Init Accessor buttons
		Loop % 12
		{
			Button := new this.CAccessorButton()
			if(SavedSettings.Buttons.HasKey(A_Index))
				Button.Load(SavedSettings.Buttons[A_Index])
			this.Buttons.Insert(Button)
		}
		outputdebug % Exploreobj(this.Buttons)
		;Init result usage tracker
		this.ResultUsageTracker := new this.CResultUsageTracker()

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

	OnExit()
	{
		;Close an open instance
		if(this.GUI)
			this.Close()
		
		;Save Accessor related data
		this.ResultUsageTracker.OnExit()

		FileDelete, % Settings.ConfigPath "\Accessor.xml"
		SavedSettings := {Buttons : [], Plugins : {}}
		for index, Plugin in this.Plugins
		{
			SavedSettings.Plugins[Plugin.Type] := {}
			Plugin.Settings.Save(SavedSettings.Plugins[Plugin.Type])
			Plugin.OnExit(this)
		}
		SavedSettings.Keywords := this.Keywords

		;Save Accessor buttons
		Loop % 12
		{
			Button := {}
			this.Buttons[A_Index].Save(Button)
			SavedSettings.Buttons.Insert(Button)
		}

		this.Settings.Save(SavedSettings)
		;XML_Save(SavedSettings, Settings.ConfigPath "\Accessor.xml")
		FileDelete, % Settings.ConfigPath "\Accessor.json"
		FileAppend, % lson(SavedSettings), % Settings.ConfigPath "\Accessor.json"

		;Clean up
		DestroyIcon(this.GenericIcons.Application)
		DestroyIcon(this.GenericIcons.File)
		DestroyIcon(this.GenericIcons.Folder)
		DestroyIcon(this.GenericIcons.URL)
	}
	
	Show(Action, InitialQuery = "")
	{
		if(this.GUI)
			return
		
		;Show some tips
		TipIndex := 17
		while(TipIndex < 43 && (TipShown := ShowTip(TipIndex)) = false)
			TipIndex++

		;Active window for plugins that depend on the context
		this.PreviousWindow := WinExist("A")

		;Store current selection and selected file (if available) so they can be inserted into keyword queries
		this.CurrentSelection := GetSelectedText()
		this.SelectedFile := Navigation.GetSelectedFilepaths()[1]
		this.CurrentDirectory := Navigation.GetPath()
		this.Filter := ""
		this.FilterWithoutTimer := ""

		;Create and show GUI
		this.GUI := new CAccessorGUI()
		this.GUI.Show()

		;Redraw is needed because Aero can cause rendering issues without it
		this.GUI.Redraw()
		this.LauncherHotkey := Action.LauncherHotkey
		
		;Init History TODO: Is this correct when a plugin changes it?
		this.History.Index := 1
		this.History[1] := ""
		
		;The action can set a placeholder manually. All events should make sure that Filter is not set before adding their own results on startup
		if(InitialQuery)
			this.Filter := InitialQuery

		;Notify plugins. They can adjust their priorities or set a filter here.
		for index, Plugin in this.Plugins
		{
			Plugin.Priority := Plugin.Settings.BasePriority
			Plugin.OnOpen(this)
		}

		if(InitialQuery)
		{
			this.SetFilter(this.Filter)
			this.RefreshList()
		}

		;Check if a plugin set a custom filter
		if(!this.Filter)
			this.RefreshList()
		
		;Prevent WM_KEYDOWN messages
		this.OldKeyDown := OnMessage(0x100)
		OnMessage(0x100, "")
	}
	
	Close()
	{
		;Needs to be delayed because it is called from within a message handler which is critical.
		SetTimerF(new Delegate(this.GUI, "Close"), -10)
	}

	;Sets the filter and tries to wait (for max. 5 seconds) until results are there
	SetFilter(Text, SelectionStart = -1, SelectionEnd = -1)
	{
		;this.Filter := Text
		;this.IsRefreshing := true
		this.GUI.SetFilter(Text, SelectionStart, SelectionEnd)
		SetTimerF(this.WaitTimer := new Delegate(this, "WaitForRefresh"), -100)
	}
	WaitForRefresh()
	{
		static count := 0
		if(this.IsRefreshing && count < 50)
		{
			count++
			SetTimerF(this.WaitTimer, -100)
		}
		else
		{
			count := 0
			this.Remove(this.WaitTimer)
			;this.OnFilterChanged(this.Filter)
		}
	}
	OnFilterChanged(Filter)
	{
		if(Filter = this.Filter)
			return
		outputdebug filter changed to %filter%
		this.Filter := Filter
		;if(this.SuppressListViewUpdate)
		;{
		;	this.SuppressListViewUpdate := false
		;	return
		;}
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

		if(NeedsUpdate && !this.IsRefreshing)
			this.RefreshList()
		else if(this.IsRefreshing)
			this.RepeatRefresh := true
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
		outputdebug RefreshList()

		;Reset refreshing status
		this.IsRefreshing := true
		this.RepeatRefresh := false

		LastFilter := this.LastFilter
		Filter := this.Filter
		Parameters := this.ExpandFilter(Filter, LastFilter, Time)

		;Plugins which need to use the filter string without any preparsing should use this one which doesn't contain the timer at the end
		this.FilterWithoutTimer := Filter

		this.FetchResults(Filter, LastFilter, KeywordSet, Parameters, Time)
		if(!this.RepeatRefresh)
			this.UpdateGUIWithResults(Time)

		this.LastFilter := Filter
		this.LastParameters := Parameters

		this.IsRefreshing := false
		if(this.RepeatRefresh)
			this.RefreshList()
	}
	
	FetchResults(Filter, LastFilter, KeywordSet, Parameters, Time)
	{
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
		index := ""
		;If we aren't, let all plugins add the items we want according to their priorities
		if(!SingleContext)
		{
			this.SingleContext := false
			Pluginlist := ""
			for index, Plugin in this.Plugins
			{
				if(Plugin.Settings.Enabled && ((Time > 0 && Plugin.AllowDelayedExecution) || !Time) && !Plugin.Settings.KeywordOnly && StrLen(Filter) >= Plugin.Settings.MinChars)
				{
					Result := Plugin.RefreshList(this, Filter, LastFilter, False, Parameters)
					if(Result)
						this.List.Extend(Result)
				}
			}
			index := ""
		}

		;Calculate the weighting of the individual results as the average value of the single weighting indicators
		for index, ListEntry in this.List
		{
			Plugin := this.Plugins[ListEntry.Type]
			ListEntry.SortOrder := ListEntry.Priority + (ListEntry.MatchQuality - this.Settings.FuzzySearchThreshold) / (1 - this.Settings.FuzzySearchThreshold) + (ListEntry.ResultIndexingKey && this.ResultUsageTracker.Plugins[ListEntry.Type].HasKey(ListEntry[ListEntry.ResultIndexingKey]) ? this.ResultUsageTracker.Plugins[ListEntry.Type][ListEntry[ListEntry.ResultIndexingKey]] : 0)
		}

		;Sort the list by the weighting
		this.List := ArraySort(this.List, "SortOrder", "Down")
	}

	UpdateGUIWithResults(Time)
	{
		if(Time)
			FormattedTime := "in " Floor(Time/3600) ":" Floor(Mod(Time, 3600) / 60) ":" Floor(Mod(Time, 60))

		this.GUI.ListView.Redraw := false
		
		;Much less results than with previous search string, clear the list instead of refreshing it
		if(this.List.MaxIndex() < 5 && this.GUI.ListView.Items.MaxIndex() > 10)
		{
			this.GUI.ListView.Items.Clear()
			this.GUI.ListView.ImageListManager.Clear()
		}

		ListViewCount := this.GUI.ListView.Items.MaxIndex()
		;Now that items are available and sorted, add them to the listview
		for index3, ListEntry in this.List
		{
			if(Time > 0)
			{
				ListEntry.Time := Time
				ListEntry.Detail2 := FormattedTime
			}
			Plugin := this.Plugins[ListEntry.Type]
			Plugin.GetDisplayStrings(ListEntry, Title := ListEntry.Title, Path := ListEntry.Path, Detail1 := ListEntry.Detail1, Detail2 := ListEntry.Detail2)

			;To improve performance, the listview isn't simply cleared, instead the contents are updated.

			;If more items than currently in list, add a new item
			if(A_Index > ListViewCount)
			{
				if(!Settings.General.DebugEnabled)
					item := this.GUI.ListView.Items.Add("", Title, Path, Detail1, Detail2)
				else
					item := this.GUI.ListView.Items.Add("", Title, Path, Detail1, ListEntry.SortOrder)

				if(!ListEntry.HasKey("IconNumber"))
					item.Icon := ListEntry.Icon
				Else
					item.SetIcon(ListEntry.Icon, ListEntry.IconNumber)
			}
			else
			{
				;Check if the text of the current item was changed. If it was, readd it, otherwise just keep going.
				;This doesn't look at the icon yet, need to find out how to compare the hIcons
				LV_GetText(t, A_Index, 1)
				LV_GetText(p, A_Index, 2)
				LV_GetText(d1, A_Index, 3)
				LV_GetText(d2, A_Index, 4)
				;msgbox % "Old item: " t ", " p ", " d1 ", " d2 "`nNew Item: " Title ", " Path ", " Detail1 ", " (Settings.General.DebugEnabled ? ListEntry.SortOrder : Detail2)
				if(t != Title || p != Path || d1 != Detail1 || d2 != (Settings.General.DebugEnabled ? ListEntry.SortOrder : Detail2))
				{
					item := this.GUI.ListView.Items[A_Index]
					LV_Modify(A_Index, "", Title, Path, Detail1, (Settings.General.DebugEnabled ? ListEntry.SortOrder : Detail2))
					;_debug := true
					;this.GUI.ListView.Items.Delete(A_Index)
					;msgbox deleted
					;if(!Settings.General.DebugEnabled)
					;	item := this.GUI.ListView.Items.Insert(A_Index, "", Title, Path, Detail1, Detail2)
					;else
					;	item := this.GUI.ListView.Items.Insert(A_Index, "", Title, Path, Detail1, ListEntry.SortOrder)
					;msgbox added
					if(!ListEntry.HasKey("IconNumber"))
						item.Icon := ListEntry.Icon
					Else
						item.SetIcon(ListEntry.Icon, ListEntry.IconNumber ? ListEntry.IconNumber : 1, 1)
					;msgbox % "icon set: " ListENtry.Icon
				}
			}
		}
		ListViewCount := this.GUI.ListView.Items.MaxIndex()
		ListCount := this.List.MaxIndex()
		Loop % ListViewCount - ListCount
		{
			LV_Delete(ListCount + 1)
			this.GUI.ListView.Items._.Remove(ListCount + A_Index, "")
		}
		if(this.GUI.ListView.SelectedItems.MaxIndex() != 1)
			this.GUI.ListView.SelectedIndex := 1

		this.GUI.ListView.ModifyCol(1, Round(this.GUI.ListView.Width * 3 / 8)) ;Col_3_w) ; resize title column
		this.GUI.ListView.ModifyCol(2, Round(this.GUI.ListView.Width * 3.3 / 8)) ; resize path column
		this.GUI.ListView.ModifyCol(3, Round(this.GUI.ListView.Width * 0.8 / 8)) ; resize detail1 column
		this.GUI.ListView.ModifyCol(4, "AutoHdr") ; resize detail2 column

		this.GUI.ListView.Redraw := true

		this.UpdateButtonText()
	}

	;Registers an Accessor plugin with this class. This needs to be done.
	RegisterPlugin(Type, Plugin)
	{
		this.Plugins[Type] := Plugin
		return Type
	}

	OnSelectionChanged()
	{
		this.UpdateButtonText()
	}
	UpdateButtonText()
	{
		;Set default text when no results and set enabled state
		if(!(this.GUI.btnOK.Enabled := this.List.MaxIndex()))
			this.GUI.btnOK.Text := "Run"
		else if(IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]))
		{
			;Remove hotkey text after tab character
			ButtonText := (Pos := InStr(ListEntry.Actions.DefaultAction.Name, "`t")) ? SubStr(ListEntry.Actions.DefaultAction.Name, 1, Pos - 1) : ListEntry.Actions.DefaultAction.Name
			if(this.GUI.btnOK.Text != ButtonText)
				this.GUI.btnOK.Text := ButtonText
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
		this.FilterWithoutTimer := ""
		this.SelectedFile := ""
		this.CurrentDirectory := ""
		this.CurrentSelection := ""
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
		value := IsObject(ListEntry) || IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]) || (!this.HasKey("ClickedListEntry") && IsObject(ListEntry := this.Plugins[this.SingleContext].Result))
		this.Remove("ClickedListEntry") ;Not needed anymore
		
		if(value)
		{
			if(Action && !IsObject(Action))
				Action := ListEntry.Actions.DefaultAction.Name = Action ? ListEntry.Actions.DefaultAction : ListEntry.Actions.GetItemWithValue("Name", Action)
			if(!Action && ListEntry.Actions.DefaultAction)
				Action := ListEntry.Actions.DefaultAction
			else if(!Action)
			{
				Notify("Accessor Error", "No Action found for " ListEntry.Type "!", 5, NotifyIcons.Error)
				return
			}
			Plugin := this.Plugins.GetItemWithValue("Type", ListEntry.Type)
			if(Action && (IsFunc(Plugin[Action.Function]) || IsFunc(this[Action.Function])))
			{
				;Track the usage of this result for weighting
				this.ResultUsageTracker.TrackResultUsage(ListEntry, Plugin.Instance)

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

					;Call action function
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
		if(IsObject(ListEntry) || IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]) || IsObject(ListEntry := this.Plugins[this.SingleContext].Result))
		{
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
		SingleContextPlugin := this.Plugins[this.SingleContext]
		outputdebug % "has action " (IsObject(ListEntry := SingleContextPlugin.Result) && (ListEntry.Actions.DefaultAction.Function = Action.Function || ListEntry.Actions.FindKeyWithValue("Function", Action.Function)))
		return (IsObject(ListEntry := this.List[this.GUI.ListView.SelectedIndex]) && (ListEntry.Actions.DefaultAction.Function = Action.Function || ListEntry.Actions.FindKeyWithValue("Function", Action.Function)))
			|| (IsObject(ListEntry := SingleContextPlugin.Result)				  && (ListEntry.Actions.DefaultAction.Function = Action.Function || ListEntry.Actions.FindKeyWithValue("Function", Action.Function)))
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
			if(FileExist(ListEntry.Path))
				CProgramLauncherPlugin.Instance.AddToCache(ListEntry)
			
			RunAsUser("cmd.exe /c start """" " Quote(ListEntry.Path) (ListEntry.args ? " " ListEntry.args : ""), WorkingDir, "HIDE")
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
	Copy(ListEntry, Plugin, Action, Field = "Path")
	{
		Clipboard := ListEntry[Field]
	}
	
	OpenExplorer(ListEntry, Plugin)
	{
		if(type := FileExist(ListEntry.Path))
			Navigation.SetPath(ListEntry.Path, CAccessor.Instance.PreviousWindow)
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
	SelectProgram(ListEntry, Plugin)
	{
		this.TemporaryFile := ListEntry.Path
		this.SetFilter(CProgramLauncherPlugin.Instance.Settings.OpenWithKeyword " ")
	}

	SearchDir(ListEntry, Plugin)
	{
		this.SetFilter(CFileSearchPlugin.Instance.Settings.Keyword "  in " ListEntry.Path, strlen(CFileSearchPlugin.Instance.Settings.Keyword) + 1, strlen(CFileSearchPlugin.Instance.Settings.Keyword) + 1)
	}
}
AccessorContextMenu:
CAccessor.Instance.PerformAction(A_ThisMenuItem, CAccessor.Instance.ClickedListEntry) ;ClickedListEntry is only valid for clicks on empty parts of the window
return

Class CAccessorGUI extends CGUI
{
	s := this.SetStyle()
	Width := CAccessor.Instance.Settings.Width
	Height := CAccessor.Instance.Settings.Height
	EditControl := this.AddControl("Edit", "EditControl", "Section x40 w" this.Width - 114 " y20 -Multi cBlack -Background", "")
	Logo := this.AddControl("Picture", "picLogo", "x+-4 y+-32 w40 h40", A_ScriptDir "\128.png")
	;b := this.Color(0x404040, 0x404040)
	;f := this.Font("cWhite", "")
	btnOK := this.AddControl("Button", "btnOK", "y10 xs+120 w75 Default hidden", "&OK")
	ListView := this.AddControl("ListView", "ListView", "xs+0 ys+100 w" this.Width - 114 " h" (this.Height - 130) "cBlack Background0xededee AltSubmit -Multi NoSortHdr", "Title|Path| | |")
	;btnCancel := this.AddControl("Button", "btnCancel", "y+8 w75", "&Cancel")
	;btnConfigKeywords := this.AddControl("Button", "btnConfigKeywords", "xs+0 y" this.Height - 140 " w75", "&Keywords")
	;btnConfigPlugins := this.AddControl("Button", "btnConfigPlugins", "xs+0 y" this.Height - 112 " w75", "&Plugins")
	Footer := this.AddControl("Picture", "Footer", "xs+1 y+-1 w" this.Width - 116 " h20 +0xE")
	;Settings := this.AddControl("Picture", "picSettings", "x+-20 w20 h20 +0xE", A_ScriptDir "\Icons\AccessorSettings.png")
	Buttons := []
	ButtonLabels := []
	SetStyle()
	{
		this.Color(0x3E3D40, 0xFFFFFF)
		;Gui, % this.GUINum ":Font", cWhite
		GuiControl, % this.GUINum ": +Background0xFFFFFF", % this.EditControl.hwnd
	}
	__new()
	{
		Accessor := CAccessor.Instance

		;Use a 7plus image as background for the listview
		pBitmap := Gdip_CreateBitmapFromFile(A_ScriptDir "\128.png")
		Width := Gdip_GetImageWidth(pBitmap)
		Height := Gdip_GetImageHeight(pBitmap)
		ListViewWidth := this.ListView.Width
		ListViewHeight := this.ListView.Height
		pLogo := Gdip_CreateBitmap(ListViewWidth, ListViewHeight)
		pGraphics := Gdip_GraphicsFromImage(pLogo)
		Gdip_SetInterpolationMode(pGraphics, 7)
		pBrush := Gdip_BrushCreateSolid(0xFFededee)
		Gdip_FillRectangle(pGraphics, pBrush, 0, 0, ListViewWidth, ListViewHeight)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(pGraphics, pBitmap, ListViewWidth / 2 - Width / 2, ListViewHeight / 2 - Height / 2, Width, Height, "", "", "", "", 0.25)
		Gdip_DeleteGraphics(pGraphics)
		Gdip_DisposeImage(pBitmap)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pLogo)
		Gdip_DisposeImage(pLogo)
		VarSetCapacity(LVBKIMAGE, 12 + 3 * A_PtrSize, 0) ; <=== 32-bit
		NumPut(0x1 | 0x20000000 | 0x0100 | 0x10, LVBKIMAGE, 0, "UINT")  ; LVBKIF_TYPE_WATERMARK
		NumPut(hBitmap, LVBKIMAGE, A_PtrSize, "UINT")
		SendMessage, 0x1044, 0, &LVBKIMAGE, , % "ahk_id " this.ListView.hwnd  ; LVM_SETBKIMAGEA
		SendMessage, 0x1026, 0, -1,, % "ahk_id " this.ListView.hwnd  ; LVM_SETTEXTBKCOLOR,, CLR_NONE
		DeleteObject(hBitmap)

		pBitmap := Gdip_CreateBitmapFromFile(A_ScriptDir "\Icons\AccessorSettings.png")
		Width := Gdip_GetImageWidth(pBitmap)
		Height := Gdip_GetImageHeight(pBitmap)
		FooterWidth := this.Footer.Width
		FooterHeight := this.Footer.Height
		pFooter := Gdip_CreateBitmap(FooterWidth, FooterHeight)
		pGraphics := Gdip_GraphicsFromImage(pFooter)
		Gdip_SetInterpolationMode(pGraphics, 7)
		pBrush := Gdip_BrushCreateSolid(0xFFCCCCCC)
		Gdip_FillRectangle(pGraphics, pBrush, 0, 0, FooterWidth, FooterHeight)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(pGraphics, pBitmap, FooterWidth - Width, 0, Width, Height)
		Gdip_DeleteGraphics(pGraphics)
		Gdip_DisposeImage(pBitmap)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pFooter)
		this.Footer.SetImageFromHBitmap(hBitmap)
		Gdip_DisposeImage(pFooter)
		DeleteObject(hBitmap)

		ButtonY := "s+30"
		ButtonX := 40
		for index, Button in Accessor.Buttons
		{
			ButtonControl := this.AddControl("Picture", "Button" A_Index, "x" ButtonX + 8 " ys+30 w40 h40", Button.Icon)
			ButtonControl.Click.Handler := new Delegate(this, "OnButtonClick")
			ButtonControl.Tooltip := "F" index
			this.Buttons.Insert(ButtonControl)
			ButtonLabelControl := this.AddControl("Text", "ButtonLabel" A_Index, "x" ButtonX " ys+78 w56 R1 Center cWhite", Button.Text)
			this.ButtonLabels.Insert(ButtonLabelControl)
			ButtonX += 56
		}
		if(Accessor.Settings.OpenInMonitorOfMouseCursor)
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
		if(!Accessor.Settings.TitleBar && (Accessor.Settings.UseAero && WinVer >= WIN_Vista && DWMEnabled))
			this.SysMenu := false
		else if(!Accessor.Settings.TitleBar)
			this.Caption := false
			
		this.Border := true
		this.Title := "7Plus Accessor"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		if(Accessor.Settings.UseAero && WinVer >= WIN_Vista && DWMEnabled)
		{
			VarSetCapacity(margin, 16)
			NumPut(-1, &margin, 0, Uint)
			NumPut(-1, &margin, 4, Uint)
			NumPut(-1, &margin, 8, Uint)
			NumPut(-1, &margin, 12, Uint)
			Gui, % this.GUINum ":Color", 0x070809
			WinSet,TransColor,0x070809, % "ahk_id " this.hwnd 
			DllCall("Dwmapi.dll\DwmExtendFrameIntoClientArea", "Ptr", this.hwnd, "Ptr", &margin)
		}
		
		if(Accessor.Settings.Transparency)
			WinSet, Trans, % Accessor.Settings.Transparency, % "ahk_id " this.hwnd
		
		this.ListView.ExStyle := "+0x00010000"
		this.ListView.LargeIcons := Accessor.Settings.LargeIcons
		;this.ListView.IndependentSorting := true
		this.ListView.ModifyCol(1, Round(this.ListView.Width * 3 / 8)) ;Col_3_w) ; resize title column
		this.ListView.ModifyCol(2, Round(this.ListView.Width * 3.3 / 8)) ; resize path column
		this.ListView.ModifyCol(3, Round(this.ListView.Width * 0.8 / 8)) ; resize detail1 column
		this.ListView.ModifyCol(4, "AutoHdr") ; resize detail2 column
		this.OnMessage(0x06, "WM_ACTIVATE")
		WinSet, Region, 1-1 774-1 774-120 727-120 727-611 41-611 41-120 1-120, % "ahk_id " this.hwnd
		SendMessage, 0x7, 0, 0,, % "ahk_id " this.ListView.hwnd ;Make the listview believe it has focus
		this.Redraw()
	}

	OnButtonClick(Sender)
	{
		Slot := this.Buttons.IndexOf(Sender)
		CAccessor.Instance.Buttons[Slot].Execute()
	}

	SetFilter(Text, SelectionStart = -1, SelectionEnd = -1)
	{
		this.EditControl.Text := Text
		if(SelectionStart = -1)
			SelectionStart := StrLen(Text)
		Edit_Select(SelectionStart, SelectionEnd, "", "ahk_id " this.EditControl.hwnd)
		this.ActiveControl := this.EditControl
	}

	ShowButtonMenu()
	{
		Menu, Tray, UseErrorLevel
		Menu, AccessorButtonMenu, DeleteAll
		Menu, AccessorButtonMenu, Add, Use current Query, SettingsHandler  ; Creates a new menu item.
		Menu, AccessorButtonMenu, Add, Set icon, SettingsHandler
		Menu, AccessorButtonMenu, Show
	}

	EditControl_TextChanged()
	{
		;Logic is handled in CAccessor
		CAccessor.Instance.OnFilterChanged(this.EditControl.Text)
	}

	WM_ACTIVATE(msg, wParam, lParam, hwnd)
	{
		if(CAccessor.Instance.Settings.CloseWhenDeactivated && !(loword(wParam) & 0x3) && WinExist("A") != this.hwnd)
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
		if(!IsObject(ListEntry := CAccessor.Instance.List[this.ListView.SelectedIndex]) && IsObject(ListEntry := CAccessor.Instance.Plugins[CAccessor.Instance.SingleContext].Result))
			CAccessor.Instance.ClickedListEntry := ListEntry
		CAccessor.Instance.ShowActionMenu()
	}

	ListView_FocusLost()
	{
		SendMessage, 0x7, 0, 0,, % "ahk_id " this.ListView.hwnd ;Make the listview believe it has focus
	}

	ContextMenu()
	{
		if(IsObject(ListEntry := CAccessor.Instance.Plugins[CAccessor.Instance.SingleContext].Result))
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
	picLogo_Click()
	{
		CAccessor.Instance.PerformAction()
	}
	Footer_Click()
	{
		CoordMode, Mouse, Relative
		MouseGetPos, x, y
		if(IsInArea(x, y, this.Footer.x, this.Footer.y, this.Footer.Width, this.Footer.Height))
		{
			this.Close()
			SettingsWindow.Show("Accessor")
		}
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

#if CAccessor.Instance.GUI && IsWindowUnderCursor(CAccessor.Instance.GUI.hwnd) && IsAccessorButtonUnderCursor()
RButton::
CAccessor.Instance.GUI.ShowButtonMenu()
return
#if
IsAccessorButtonUnderCursor()
{
	MouseGetPos, , , , control
	Number := SubStr(control, 7)
	return Number >= 3 && Number <= 26
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


#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.OpenExplorer))
^e::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.OpenExplorer)
return
#if

#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.OpenPathWithAccessor))
^b::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.OpenPathWithAccessor)
return
#if

#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.OpenWith))
^o::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.OpenWith)
return
#if

#if (CAccessor.Instance.GUI && CAccessor.Instance.HasAction(CAccessorPlugin.CActions.SearchDir))
^f::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.SearchDir, CAccessor.Instance.List[CAccessor.Instance.GUI.ListView.SelectedIndex].Actions.GetItemWithValue("Function", CAccessorPlugin.CActions.SearchDir.Function) ? "" : CFileSystemPlugin.Instance.Result)
return
#if

#if CAccessor.Instance.GUI && !Edit_TextIsSelected("", "ahk_id " CAccessor.Instance.GUI.EditControl.hwnd)
^c::
CAccessor.Instance.PerformAction(CAccessorPlugin.CActions.Copy)
return
#if

Class CAccessorPluginSettingsWindow extends CGUI
{
	PluginGUI := object("x", 38,"y", 80)
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
		
		AddControl(Plugin.Settings, this.PluginGUI, "Edit", "BasePriority", "", "", "Base Priority:", "", "", "", "", "The priority of a plugin determines the order of its results in the Accessor window. Some plugins dynamically adjust their priority based on the current context. You should only modify this value if you know what you're doing :)`nReasonable values range from 0 to 1, higher values can be used to force the results from this plugin to the top of the list.")
		
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
		BasePriority := 0.5
		
		;If true, the results from this plugin are only shown when the keyword is entered in the query.
		;~ KeywordOnly := false
		
		;Minimum amount of characters required to show results from this plugin. Used for speed and cleaner result lists.
		MinChars := 2
		
		;Called when properties of this class are loaded. The plugin usually doesn't need to load the properties manually.
		Load(json)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base" && json.HasKey(key))
					this[key] := json[key]
		}
		Save(json)
		{
			for key, value in this
				if(!IsFunc(value) && key != "Base")
					json[key] := value
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
		static OpenPathWithAccessor := new CAccessor.CAction("Open path with Accessor`tCTRL + B", "OpenPathWithAccessor", "", false, false, false)
		static OpenWith := new CAccessor.CAction("Open with`tCTRL + O", "SelectProgram", "", false, false, true)
		static Cancel := new CAccessor.CAction("Cancel`tEscape", "Close", "", false, false, false)
		static SearchDir := new CAccessor.CAction("Search in this directory`tCTRL + F", "SearchDir", "", false, false, false)
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

		;The ranking of the results is calculated by the indicators below. Accessor takes the average value of these indicators and sorts all results by this value

		;The priority is determined by the plugin and the current context. Entries from the same plugin may have different priorities, this is up to the plugin.
		;This value should be between 0 and 1, where 1 is the highest priority.
		Priority := 0

		;The MatchQuality is an indicator for the similarity of the query to the name/path/whatever of this result. It is also calculated by each plugin individually
		;and ranges from ]0:1] (that means that values of 0 should be omitted by the plugins)
		MatchQuality := 0

		;This value is calculated by the Accessor and isn't used directly by the plugin. Accessor keeps a table of usage histories which is used to create an additional
		;ranking measure for results. It also goes from 0 (never used) to 1(always used). It does not use a linear scale because its impact would be too little then.
		;The addressing of the results is done through a table that is indexed by the plugin type, name and text of a single result. If this is undesirable and a plugin 
		;doesn't want to store a usage history it can disable this by TODO: Create Setting for this.
		UsageFrequency := 0
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
#include %A_ScriptDir%\Accessor\CControlPanelPlugin.ahk
#include %A_ScriptDir%\Accessor\CProgramLauncherPlugin.ahk
#include %A_ScriptDir%\Accessor\CFileSearchPlugin.ahk
#include %A_ScriptDir%\Accessor\CRecentFoldersPlugin.ahk
#include %A_ScriptDir%\Accessor\CClipboardPlugin.ahk
#include %A_ScriptDir%\Accessor\CCalculatorPlugin.ahk
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
trillian
winget

TODO:
Documentation of new Accessor features
keyboard hotkeys in settings window activate when other page is visible
icon in context menu
uninstall plugin not working (x64) -- Or is it?
random accessor crashes on x64


favorite buttons for Accessor?

clipboard clips: pasting doesn't work in Word
find in filenames doesn't search
infogui not working?
google plugin icon missing
open accessor in monitor of mouse not working
windows minimize animation setting in slide windows settings
explorer tabs in slide windows
message timer on clock not working
subevent controls not working properly

Ideas:
A slot should contain either a query or a result
-Selecting a query would just insert it as query in Accessor while keeping it open
-Selecting a result should execute its default action
Slots can be assigned by right clicking on them or on a result
F-keys are used to access the buttons as well
Buttons that use queries need a way to use a custom icon. This can probably be done through context menu


Using Accessor as a dock:
There should only be one setting that enables/disables this.
It needs to integrate with SlideWindows somehow:
	- Either register it as a regular slide window
	- Or write own slide routines and simply lock the screen side (up or down, depending on taskbar position) for slide windows
The latter method has the advantage that it doesn't need lots of exceptions in the SlideWindow code at the expense of some code duplication. SlideWindows code only needs some small adjustments.
The window would always stay visible outside of the screen (or maybe hidden...), instead of being created/destroyed like now.
This needs to be considered for the OnOpen/OnClose routines of the plugins. They probably just need to be called as well when the window slides in.
Window can be activated by either the hotkey or by moving the mouse to the screen border. Exceptions for this should be made for dragging windows (->LButton down or shell hook). In this case it should not get activated when the mouse is at the border.
*/