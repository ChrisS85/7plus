SettingsActive()
{
	return IsObject(SettingsWindow) && IsObject(SettingsWindow.Events) 
}
SettingsHandler:
ShowSettings()
return
ShowSettings(Page = "Events")
{
	global SettingsWindow
	;Settings window is created in AutoExecute to save some time when this function is called the first time.
	while(!IsObject(SettingsWindow))
		Sleep 10
	SettingsWindow.Show(Page)
}
Class CSettingsWindow Extends CGUI
{	
	treePages := this.AddControl("TreeView", "treePages", "x19 y12 w140 h413", "")
	btnApply := this.AddControl("Button", "btnApply", "x757 y431 w73 h23", "Apply")
	btnCancel := this.AddControl("Button", "btnCancel", "x678 y431 w73 h23", "Cancel")
	btnOK := this.AddControl("Button", "btnOK", "x599 y431 w73 h23", "OK")
	txtVideoHint := this.AddControl("Text", "txtVideoHint", "x16 y436 w175 h13", "Click on ? to see video tutorial help!")
	grpPage := this.AddControl("GroupBox", "grpPage", "x176 y12 w654 h413", "Events")
	PageNames := "Introduction|Events|Accessor Keywords|Accessor Plugins|Explorer|Explorer Tabs|Fast Folders|FTP Profiles|HotStrings|Windows|Windows Settings|Misc|About"
	__New()
	{
		this.treePages.RegisterEvent("ItemSelected", "PageSelected")
		this.Pages := {}
		PageNames := this.PageNames
		Loop, Parse, PageNames, |
		{
			Item := this.treePages.Items.Add(A_LoopField = "Events" ? "All Events" : A_LoopField, A_LoopField = "Events" ? "Expand" : "")
			if(A_LoopField = "Events")
				Item.IsEvents := true
			Name := StringReplace(A_LoopField, " ", "")
			Page := this.Pages[Name] := Item.AddControl("Tab", Name, "x176 y14 w460 h350", "bla")
			this["Create" Name]()
			Page.Hide()
		}
		
		this.OnMessage(0x100, "WM_KEYDOWN")
		this.OnMessage(0x101, "WM_KEYUP")
		
		this.CloseOnEscape := true
		this.Title := "7plus Settings"
	}
	
	;Shows the settings window, optionally specifying a page to show
	Show(Page="Events")
	{
		;On first run of 7plus, start with Introduction page
		if(!Page)
			Page := Settings.General.FirstRun ? "Introduction" : "Events"
		
		PageNames := this.PageNames
		
		;Initialize the pages when the window was hidden
		if(!this.Visible)
		{
			Loop, Parse, PageNames, |
			{
				Name := StringReplace(A_LoopField, " ", "")
				this["Init"  Name]()			
			}
		}
		
		;Select the appropriate page
		if(this.treePages.SelectedItem.Text != Page && !((Page = "Events" && this.treePages.SelectedItem.Text = "All Events")))
		{
			for index, item in this.treePages.Items
				if(item.Text = Page || (Page = "Events" && item.Text = "All Events"))
					this.treePages.SelectedItem := Item
		}
		else
			this.RecreateTreeView()
		base.Show()
	}
	btnApply_Click()
	{
		this.ApplySettings(0)
	}
	btnCancel_Click()
	{
		this.CancelSettings()
	}
	btnOK_Click()
	{
		this.ApplySettings(1)
	}
	PreClose()
	{
		this.Events := ""
	}
	ApplySettings(Close=0)
	{		
		PageNames := this.PageNames
		Loop, Parse, PageNames, |
		{
			Name := StringReplace(A_LoopField, " ", "")
			this["Apply" Name]()
		}
		Settings.Save()
		if(Close)
			this.Close()
	}
	CancelSettings()
	{		
		this.Close()
	}
	
	;Called when a settings page gets selected
	PageSelected(Item)
	{
		if(PreviousText := StringReplace(this.treePages.PreviouslySelectedItem.Text, " ", ""))
			this["Hide" PreviousText]()
		;This property is stored specifically for this routine to speed things up! It helps at least 500ms to do this than to check for item parent and item text like this: if(Item.Parent.ID != 0 || Item.Text = "All Events")
		if(Item.IsEvents)
			this.FillEventsList()
		this.grpPage.Text := Item.Text
		GuiControl, % this.GUINum ":MoveDraw", % this.treePages.hwnd
		GuiControl, % this.GUINum ":MoveDraw", % this.grpPage.hwnd
		GuiControl, % this.GUINum ":MoveDraw", % this.BtnOK.hwnd
		GuiControl, % this.GUINum ":MoveDraw", % this.BtnCancel.hwnd
		GuiControl, % this.GUINum ":MoveDraw", % this.BtnApply.hwnd
		GuiControl, % this.GUINum ":MoveDraw", % thisTutLabel.hwnd
		;~ GuiControl, % this.GUINum ":MoveDraw", % this.Wait.hwnd
	}
	
	
	;Introduction
	CreateIntroduction()
	{
		Page := this.Pages.Introduction.Tabs[1]
		Page.AddControl("Text", "txtLanguage", "x197 y328 w129 h13", "Documentation language:")
		Page.AddControl("DropDownList", "ddlLanguage", "x379 y325 w160", "")
		Page.AddControl("Text", "txtRunAsAdmin", "x197 y301 w75 h13", "Run as admin:")
		Page.AddControl("DropDownList", "ddlRunAsAdmin", "x379 y298 w160", "Always/Ask|Never")
		Page.Controls.txtRunAsAdmin.ToolTip := "Required for explorer buttons, Autoupdate and for accessing programs which are running as admin. Also make sure that 7plus has write access to its config files when not running as admin."
		Page.Controls.ddlRunAsAdmin.ToolTip := "Required for explorer buttons, Autoupdate and for accessing programs which are running as admin. Also make sure that 7plus has write access to its config files when not running as admin."
		Page.AddControl("CheckBox", "chkAutoUpdate", "x200 y275 w219 h17", "Automatically look for updates on startup")
		Page.AddControl("CheckBox", "chkHideTrayIcon", "x200 y252 w339 h17", "Hide Tray Icon (press WIN + H (default settings) to show settings!)")
		Page.AddControl("CheckBox", "chkAutoRun", "x200 y229 w187 h17", "Autorun 7plus on windows startup")
		Text = 
		(
		Welcome to 7plus! If you are new to this program, here are some tips:

 - Be sure to check out the events settings page (or more specifically, the subpages for specific categories).
   The event system allows to create all kinds of functions (hotkeys, timers, context menu entries...).
   If you look for a specific feature, use the search field on that page. To edit an event, just double-click it.
   Use the help buttons in the "Edit Event" and "Edit Subevent" windows for help on specific triggers/conditions/actions.

 - You should also check out the Accessor settings. The Accessor is a launcher program that can be used
   to launch programs with the keyboard (and much more!).

 - For explorer features, check out the Explorer, Fast Folders and Explorer Tabs pages,
   in addition to the explorer-related events.

Finally, here are some settings that you're likely to change at the beginning:
)
		Page.AddControl("Text", "textIntroduction", "x197 y28 w574 h182", Text)
	}	
	InitIntroduction()
	{
		global Languages
		Page := this.Pages.Introduction.Tabs[1].Controls
		Page.chkAutoUpdate.Checked := Settings.General.AutoUpdate
		Page.chkHideTrayIcon.Checked := Settings.Misc.HideTrayIcon
		if(!IsPortable)
			Page.chkAutoRun.Checked := IsAutoRunEnabled()
		Page.ddlRunAsAdmin.Text := Settings.Misc.RunAsAdmin
		Page.ddlLanguage.Items.Clear()
		for key, Language in Languages.Languages
			Page.ddlLanguage.Items.Add(Language.FullName, -1, Language.ShortName = Settings.General.Language)
	}
	ApplyIntroduction()
	{
		global Languages
		Page := this.Pages.Introduction.Tabs[1].Controls
		
		Settings.General.AutoUpdate := Page.chkAutoUpdate.Checked
		
		if(!Settings.Misc.HideTrayIcon && Settings.Misc.HideTrayIcon != Page.chkHideTrayIcon.Checked)
		{
			MsgBox You have chosen to hide the tray icon. This means that you will only be able to access the settings dialog by pressing WIN + H (Default settings). Also, the program can only be ended by using the task manager then.
			Menu, Tray, NoIcon
		}
		else
			Menu, Tray, Icon		
		Settings.Misc.HideTrayIcon := Page.chkHideTrayIcon.Checked
		
		if(!IsPortable &&  IsAutoRunEnabled() != Page.chkAutoRun.Checked)
		{
			if(Page.chkAutoRun.Checked)
				EnableAutorun()
			else
				DisableAutorun()
		}
		
		Settings.Misc.RunAsAdmin := Page.ddlRunAsAdmin.Text
		
		for index, Language in Languages.Languages
			if(Language.FullName = Page.ddlLanguage.Text)
			{
				Settings.General.Language := Language.ShortName
				break
			}
	}
	
	;Events
	CreateEvents()
	{
		Page := this.Pages.Events.Tabs[1]
		Page.AddControl("CheckBox", "chkShowAdvancedEvents", "x197 y65 w141 h17", "Show advanced events")
		Page.AddControl("Button", "btnEventHelp", "x743 y336 w75 h23", "Help")
		Page.AddControl("Button", "btnExportEvents", "x743 y307 w75 h23", "Export")
		Page.AddControl("Button", "btnImportEvents", "x743 y278 w75 h23", "Import")
		Page.AddControl("Button", "btnPasteEvent", "x743 y204 w75 h23", "Paste Event")
		Page.AddControl("Button", "btnCopyEvent", "x743 y175 w75 h23", "Copy Event")
		Page.AddControl("Button", "btnEditEvent", "x743 y146 w75 h23", "Edit Event")
		Page.AddControl("Button", "btnDeleteEvents", "x743 y117 w75 h23", "Delete Events")
		Page.AddControl("Button", "btnAddEvent", "x743 y88 w75 h23", "Add Event")
		Page.AddControl("Edit", "editEventDescription", "x197 y365 w536 h50 ReadOnly", "")
		Page.AddControl("Edit", "editEventFilter", "x589 y62 w144 h20", "")
		Page.AddControl("Text", "txtEventSearch", "x508 y65 w75 h13", "Event Search:")
		;ListView uses indices that are independent of the listview sorting so it can access the array with the data more easily
		Page.AddControl("ListView", "listEvents", "x197 y88 w536 h271 Grid Checked -LV0x10 Count300", "Enabled|ID|Trigger|Name")
		Page.listEvents.IndependentSorting := true
		Page.AddControl("Text", "txtEventDescription", "x194 y28 w606 h26", "You can add events here that are triggered under certain conditions. When triggered, the event can launch a series of actions.`n This is a very powerful tool to add all kinds of features, and many features from 7plus are now implemented with this system.")
		Page.Controls.editEventDescription.Multi := 1
	}	
	InitEvents()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		this.SupressFillEventsList := true
		Page.chkShowAdvancedEvents.Checked := Settings.General.ShowAdvancedEvents
		if(!this.Events)
		{
			for index, Event in EventSystem.Events
				Event.Trigger.PrepareCopy(Event)
			
			this.Events := EventSystem.Events.DeepCopy()
			Page.editEventFilter.Text := ""
		}
		this.RecreateTreeView()
		Page.listEvents.ModifyCol(2, 40)
		Page.listEvents.ModifyCol(3, 195)
		Page.listEvents.ModifyCol(4, 230)
		this.ActiveControl := Page.listEvents
		this.Remove("SupressFillEventsList")
	}
	ApplyEvents()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		Settings.General.ShowAdvancedEvents := Page.chkShowAdvancedEvents.Checked
		
		;TODO: Improve code quality here.
		;Remove events that were deleted in settings window and refresh the settings copies to consider recent changes in the original events (such as timer state)
		pos := 1
		Loop % EventSystem.Events.MaxIndex()
		{
			OldEvent := EventSystem.Events[pos]
			NewEvent := this.Events.GetItemWithValue("ID", OldEvent.id)
			
			;Disable all events first (without setting enabled to false, so triggers can decide what they want to do themselves)
			OldEvent.Trigger.Disable(OldEvent)
			
			;separate destroy routine instead of simple disable is needed for removed events because of hotkey/timer discrepancy
			if(!NewEvent)
			{
				EventSystem.Events.Delete(OldEvent, false)
				continue
			}
			
			OldEvent.Trigger.PrepareReplacement(OldEvent, NewEvent)
			pos++
		}
		;Replace the original events with the copies
		EventSystem.Events := this.Events.DeepCopy()
		
		;Update enabled state
		for index, Event in EventSystem.Events
		{
			if(Event.Enabled)
				Event.Trigger.Enable(Event)
			else
				Event.Trigger.Disable(Event)
		}
	}
	RecreateTreeView()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		SelectedCategory := this.GetSelectedCategory()
		this.treePages.DisableNotifications := true
		Page.listEvents.DisableNotifications := true
		ShowAdvancedEvents := Page.chkShowAdvancedEvents.Checked
		while(item := this.treePages.Items[2][1])
			this.treePages.Items.Remove(item)
		for index, Category in this.Events.Categories
		{
			for index2, Event in this.Events
			{
				if(ShowAdvancedEvents || (Event.Category = Category && !Event.EventComplexityLevel))
				{
					item := this.treePages.Items[2].Add(Category, "Sort" (SelectedCategory = Category ? " Select Vis" : ""))
					item.Controls.Insert(this.treePages.Items[2].Controls.Events)
					item.IsEvents := true
					break
				}
			}
		}
		this.FillEventsList()
		if(this.treePages.SelectedItem.IsEvents)
			this.ActiveControl := Page.listEvents
		this.treePages.DisableNotifications := false
		Page.listEvents.DisableNotifications := false
	}
	
	;This function needs to use speed optimizations
	FillEventsList()
	{
		;Used to suppress a redundant call to this function on init since it takes up 200-500ms on my PC.
		if(this.SupressFillEventsList)
			return
		Page := this.Pages.Events.Tabs[1].Controls
		SelectedCategory := this.GetSelectedCategory()
		SelectedID := Page.listEvents.SelectedItem[2]
		Filter := Page.editEventFilter.Text
		ShowAdvancedEvents := Page.chkShowAdvancedEvents.Checked
		Items := Page.listEvents.Items
		Items.Clear()
		;~ GuiControl, % this.GUINum ":-Redraw", % Page.listEvents.ClassNN
		;Add all matching events
		for index, Event in this.Events
		{
			ID := Event.ID
			DisplayString := Event.Trigger.DisplayString()
			Name := Event.Name
			;Show events that match the entered filter or the selected category and the selected complexity level
			if((!Filter || InStr(ID, Filter) || InStr(DisplayString, Filter) || InStr(Name, filter) || InStr(Event.Description, Filter)) && (filter || !SelectedCategory || SelectedCategory = Event.Category)
			&& (ShowAdvancedEvents || !Event.EventComplexityLevel))
			{
				item := Items.Add((Event.Enabled ? " Check": " "), "", ID, DisplayString, Name)
				if(SelectedID && ID = SelectedID)
					item.Modify("Select Focus Vis")
			}
		}
		
		if(!Page.listEvents.SelectedItems.MaxIndex() && Page.listEvents.Items.MaxIndex())
			Page.listEvents.SelectedIndex := 1
		if(Page.listEvents.SelectedItems.MaxIndex() = 1)
			Page.editEventDescription.Text := this.Events.GetItemWithValue("ID", Page.listEvents.SelectedItem[2]).Description
		this.listEvents_SelectionChanged("")
	}
	
	chkShowAdvancedEvents_CheckedChanged()
	{
		this.FillEventsList()
	}
	editEventFilter_TextChanged()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		pos := 1
		Loop % CGUI.EventQueue.MaxIndex()
		{
			GuiControlGet, ControlHWND, % this.GUINum ":hwnd", % CGUI.EventQueue[pos].GuiControl
			if(ControlHWND = Page.editEventFilter.hwnd)
				CGUI.EventQueue.Remove(pos)
			else
				pos++
		}
		this.FillEventsList()
	}
	listEvents_SelectionChanged(Row)
	{
		Page := this.Pages.Events.Tabs[1].Controls
		items := Page.listEvents.SelectedItems.MaxIndex()
		if(!items)
		{
			Page.btnDeleteEvents.Enabled := false
			Page.btnCopyEvent.Enabled := false
		}
		else if(Items >= 1)
		{
			Page.btnDeleteEvents.Enabled := true
			Page.btnCopyEvent.Enabled := true
		}
		if(items = 1)
		{
			Page.editEventDescription.Text := this.Events.GetItemWithValue("ID", Page.listEvents.SelectedItem[2]).Description
			Page.btnEditEvent.Enabled := true
		}
		else
		{
			Page.editEventDescription.Text := ""
			Page.btnEditEvent.Enabled := false
		}
	}
	listEvents_DoubleClick(Row)
	{
		this.EditEvent(0)
	}
	listEvents_CheckedChanged(Row)
	{
		this.Events[Row._.RowNumber].Enabled := Row.Checked
	}
	btnAddEvent_Click()
	{
		this.AddEvent()
	}
	btnEditEvent_Click()
	{
		this.EditEvent(0)
	}
	btnDeleteEvents_Click()
	{
		this.DeleteEvents()
	}
	btnCopyEvent_Click()
	{
		this.CopyEvent()
	}
	btnPasteEvent_Click()
	{
		this.PasteEvent()
	}
	btnImportEvents_Click()
	{
		this.ImportEvents()
	}
	btnExportEvents_Click()
	{
		this.ExportEvents()
	}
	btnEventHelp_Click()
	{
		OpenWikiPage("EventsOverview")
	}
	
	AddEvent()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		;Event is added to this.Events here and an ID is assigned
		Event := this.Events.RegisterEvent()
		ListItem := Page.listEvents.Items.Add("Select Vis", "", Event.ID, Event.Trigger.DisplayString(), Event.Name)
		Page.listEvents.SelectedItem := ListItem
		SelectedCategory := this.GetSelectedCategory(true)
		Event.Category := SelectedCategory
		this.EditEvent(1)
	}
	
	EditEvent(TemporaryEvent)
	{
		Page := this.Pages.Events.Tabs[1].Controls
		if(Page.listEvents.SelectedItems.MaxIndex() != 1)
			return
		ID := Page.listEvents.SelectedItem[2]
		OriginalEvent := this.Events.GetItemWithValue("ID", ID)
		if((Settings.IsPortable || !A_IsAdmin) && OriginalEvent.Trigger.Type = "ExplorerButton")
		{
			Msgbox ExplorerButton trigger events may not be modified in portable or non-admin mode, as this might cause inconsistencies with the registry.
			return
		}
		Suspend, On
		NewEvent:=GUI_EditEvent(OriginalEvent.DeepCopy())
		Suspend, Off
		if(NewEvent && (Settings.IsPortable || !A_IsAdmin) && NewEvent.Trigger.Type = "ExplorerButton") ;Explorer buttons may not be added in portable/non-admin mode
		{
			Msgbox ExplorerButton trigger events may not be modified in portable or non-admin mode, as this might cause inconsistencies with the registry.
			if(TemporaryEvent)
				this.DeleteEvents()
			return
		}
		if(NewEvent)
		{
			this.editEventFilter.Text := ""
			this.Events[this.Events.FindKeyWithValue("ID", ID)] := NewEvent ;overwrite edited event
			if(NewEvent.Category = "")
				NewEvent.Category := "Uncategorized"
			if(!this.Events.Categories.indexOf(NewEvent.Category))
				this.Events.Categories.Insert(NewEvent.Category)
			this.RecreateTreeView() ;Refresh Event display
		}
		else if(TemporaryEvent)
			this.DeleteEvents()
	}
	DeleteEvents()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		Page.ListEvents.DisableNotifications := true
		ListPos := 1
		SelectedEvents := Page.listEvents.SelectedIndices
		Loop % SelectedEvents.MaxIndex()
		{
			Index := SelectedEvents[SelectedEvents.MaxIndex() - A_Index + 1]
			Event := this.Events.GetItemWithValue("ID", Page.listEvents.Items[Index][2])
			if((!Settings.IsPortable && A_IsAdmin) || Event.Trigger.Type != "ExplorerButton" && Event.Trigger.Type != "ContextMenu")
			{
				;Events object notifies its trigger about deletion
				CategoryDeleted += this.Events.Delete(Event, false)
				ListPos := Index
				Page.listEvents.Items.Delete(Index)
			}
		}
		count :=  Page.listEvents.Items.MaxIndex()
		if(count)
			Page.listEvents.SelectedIndex := min(max(ListPos, 1), count)
		Page.ListEvents.DisableNotifications := false
		if(CategoryDeleted) ;If a category was deleted
			this.RecreateTreeView()
		else
			this.ActiveControl := Page.listEvents
	}
	CopyEvent()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		count := Page.listEvents.SelectedItems.MaxIndex()
		if(!count)
			return
		ClipboardEvents := new CEvents()
		for index, item in Page.listEvents.SelectedItems
		{	
			Event := this.Events.GetItemWithValue("ID", item[2])
			Copy := Event.DeepCopy()
			Copy.Remove("OfficialEvent") ;Make sure that pasted events don't patch existing events
			if((!Settings.IsPortable && A_IsAdmin) || Event.Trigger.Type != "ExplorerButton")
				ClipboardEvents.Insert(copy)
		}
		ClipboardEvents.WriteEventsFile(A_Temp "/7plus/EventsClipboard.xml")	
		Page.btnPasteEvent.Enabled := true
	}
	PasteEvent()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		if(FileExist(A_Temp "/7plus/EventsClipboard.xml"))
		{
			SelectedCategory := this.GetSelectedCategory(true)
			this.Events.ReadEventsFile(A_Temp "/7plus/EventsClipboard.xml", SelectedCategory)
			this.FillEventsList()
		}
	}
	ImportEvents()
	{
		Page := this.Pages.Events.Tabs[1].Controls
		FileDialog := new CFileDialog("Open")
		FileDialog.Filter := "Event files (*.xml)"
		FileDialog.Title := "Import Events file"
		FileDialog.FileMustExist := true
		FileDialog.PathMustExist := true
		oldlen := this.Events.MaxIndex()
		if(FileDialog.Show())
		{
			this.Events.ReadEventsFile(FileDialog.Filename)
			this.RecreateTreeView()
			
			;Figure out if FTP events were added and notify the user to set the FTP profile assignments
			Loop % this.Events.MaxIndex() - oldlen
			{
				pos := A_Index + oldlen
				if(this.Events[pos].Actions.FindKeyWithValue("Type", "Upload"))
				{
					found := true
					break
				}
			}
			if(found)
				Notify("Note", "Make sure to assign the FTP profiles of all imported FTP actions!", 2, "GC=555555 TC=White MC=White", NotifyIcons.Info)
		}
	}
	ExportEvents()
	{
		global MajorVersion, MinorVersion, BugFixVersion
		Page := this.Pages.Events.Tabs[1].Controls	
	
		;Uncomment the following lines to export all events separated by category to Events\Category.xml instead	
		;~ Loop % this.Events.Categories.MaxIndex()
		;~ {
			;~ Category := this.Events.Categories[A_Index]
			;~ ExportEvents := Array()
			;~ Loop % this.Events.MaxIndex()
			;~ {
				;~ if(this.Events[A_Index].Category = Category)
					;~ ExportEvents.Insert(this.Events[A_Index])
			;~ }
			;~ if(ExportEvents.MaxIndex())
				;~ WriteEventsFile(ExportEvents, A_ScriptDir "\Events\" Category ".xml")
		;~ }
		;~ WriteEventsFile(this.Events, A_ScriptDir "\Events\All Events.xml")
		;~ run % """" A_ScriptDir "\CreateEventPatch.ahk""" " """ A_ScriptDir "\Events\Old Versions\" MajorVersion "." (MinorVersion-1) "." BugFixVersion "\All Events.xml"" """ A_ScriptDir "\Events\All Events.xml"" 0" ;Create event patch, assumes that last minor version was incremented by one since last release
		;~ return
		
		if(Page.listEvents.SelectedItems.MaxIndex())
		{
			FileDialog := new CFileDialog("Save")
			FileDialog.Filter := "Event files (*.xml)"
			FileDialog.Title := "Export Events file"
			FileDialog.FileMustExist := true
			FileDialog.PathMustExist := true
			FileDialog.OverwriteFilePrompt := true
			if(FileDialog.Show())
			{
				File := FileDialog.Filename
				if(!strEndsWith(File, ".xml"))
					File .= ".xml"
				ExportEvents := new CEvents()
				for index, Item in Page.listEvents.SelectedItems
				{
						Event := this.Events.GetItemWithValue("ID", Item[2])
						ExportEvents.Insert(Event)
						if(!FTP && Event.Actions.FindKeyWithValue("Type", "Upload"))
							FTP := true
				}
				ExportEvents.WriteEventsFile(File)
				if(FTP)
					Notify("Note", "FTP profiles won't be exported by this function. To save them, create a backup of FTPProfiles.xml. This file is only updated at program exit!", 2, "GC=555555 TC=White MC=White", NotifyIcons.Info)
			}
		}
	}
		
	
	;Accessor Plugins
	CreateAccessorPlugins()
	{
		Page := this.Pages.AccessorPlugins.Tabs[1]
		Page.AddControl("Text", "txtAccessorText", "x197 y373 w431 h39", "Accessor is a versatile tool that is used to perform many commands through the keyboard, `nlike launching programs, switching windows, open URLs, browsing the filesystem,...`nPress the assigned hotkey (Default: ALT+Space) and start typing!")
		Page.AddControl("Button", "btnAccessorHelp", "x730 y60 w90 h23", "Help")
		Page.AddControl("Button", "btnAccessorSettings", "x730 y31 w90 h23", "Plugin Settings")
		Page.AddControl("ListView", "listAccessorPlugins", "x197 y31 w525 h332 Checked", "Enabled|Plugin Name")
		Page.listAccessorPlugins.IndependentSorting := true
	}
	InitAccessorPlugins()
	{
		global AccessorPlugins
		Page := this.Pages.AccessorPlugins.Tabs[1].Controls
		this.AccessorPlugins := Array() ;We don't copy the whole AccessorPlugins structure here to save some memory (program launcher might take some for example)
		Page.listAccessorPlugins.Items.Clear()
		Loop % AccessorPlugins.MaxIndex()
		{
			AccessorPlugin := AccessorPlugins[A_Index]
			PluginCopy := RichObject()
			PluginCopy.Enabled := AccessorPlugin.Enabled
			; PluginCopy.Keyword := AccessorPlugins[A_Index].Keyword
			PluginCopy.Type := AccessorPlugin.Type
			PluginCopy.Settings := AccessorPlugin.Settings.DeepCopy()
			PluginCopy.HasSettings := AccessorPlugin.HasSettings
			;~ PluginCopy.Description := AccessorPlugin.Description
			this.AccessorPlugins.Insert(PluginCopy)
			Page.listAccessorPlugins.Items.Add(PluginCopy.Enabled ? "Check" : "", "", PluginCopy.Type)
		}	
		Page.listAccessorPlugins.ModifyCol(1, 60)
		Page.listAccessorPlugins.ModifyCol(2, "AutoHdr")
	}
	ApplyAccessorPlugins()
	{
		global AccessorPlugins	
		Page := this.Pages.AccessorPlugins.Tabs[1].Controls
		Loop % AccessorPlugins.MaxIndex()
		{
			AccessorPlugin := AccessorPlugins[A_Index]
			SettingsPlugin := this.AccessorPlugins[A_Index]
			AccessorPlugin.Enabled := SettingsPlugin.Enabled
			AccessorPlugin.Settings := SettingsPlugin.Settings.DeepCopy()
		}
	}
	btnAccessorHelp_Click()
	{
		OpenWikiPage("docsAccessor")
	}
	btnAccessorSettings_Click()
	{
		this.ShowAccessorSettings()
	}
	ShowAccessorSettings()
	{
		global AccessorPlugins
		Page := this.Pages.AccessorPlugins.Tabs[1].Controls
		if(Page.listAccessorPlugins.SelectedItems.MaxIndex() != 1)
			return
		
		AccessorPlugin := this.AccessorPlugins[Page.listAccessorPlugins.SelectedIndex]
		if(!AccessorPlugin.HasSettings)
			return
		PluginSettings:=GUI_EditAccessorPlugin(AccessorPlugin)
		
		if(PluginSettings)
			this.AccessorPlugins[Page.listAccessorPlugins.SelectedIndex] := PluginSettings
	}
	listAccessorPlugins_SelectionChanged(Row)
	{
		global AccessorPlugins
		Page := this.Pages.AccessorPlugins.Tabs[1].Controls
		if(Page.listAccessorPlugins.SelectedItems.MaxIndex() = 1)
		{
			if(AccessorPlugins[Page.listAccessorPlugins.SelectedIndex].HasSettings)
				Page.btnAccessorSettings.Enabled := true
			else
				Page.btnAccessorSettings.Enabled := false
		}
		else
			Page.btnAccessorSettings.Enabled := false
	}
	listAccessorPlugins_CheckedChanged(Row)
	{
		this.AccessorPlugins[Row._.RowNumber].Enabled := Row.Checked
	}
	listAccessorPlugins_DoubleClick(Row)
	{
		this.ShowAccessorSettings()
	}


	;Accessor Keywords
	CreateAccessorKeywords()
	{
		Page := this.Pages.AccessorKeywords.Tabs[1]
		Page.AddControl("Text", "txtAccessorKeyword", "x197 y372 w51 h13", "Keyword:")
		Page.AddControl("Edit", "editAccessorKeyword", "x260 y369 w462 h20", "")
		Page.Controls.editAccessorKeyword.ToolTip := "The keyword which is typed into accessor at the start of the query, i.e. ""Google"""
		Page.AddControl("Text", "txtAccessorCommand", "x197 y398 w57 h13", "Command:")
		Page.AddControl("Edit", "editAccessorCommand", "x260 y395 w462 h20", "")
		Page.Controls.editAccessorCommand.ToolTip := "You can use parameters here which are inserted into the command at specific places. This is currently only supported by the URL plugin. Example: Keyword: ""google"" Command: ""www.google.com/search?q=${1}"" Entered Text: ""google 7plus"" result: ""www.google.com/search?q=7plus"""
		
		Page.AddControl("Button", "btnDeleteAccessorKeyword", "x730 y60 w90 h23", "Delete Keyword")
		Page.AddControl("Button", "btnAddAccessorKeyword", "x730 y31 w90 h23", "Add Keyword")
		Page.AddControl("ListView", "listAccessorKeywords", "x197 y31 w525 h332", "Keyword|Command")
		Page.listAccessorKeywords.IndependentSorting := true
	}
	InitAccessorKeywords()
	{
		global Accessor
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		this.AccessorKeywords := Accessor.Keywords.DeepCopy()
		Page.listAccessorKeywords.Items.Clear()
		Page.listAccessorKeywords.ModifyCol(1, 100)
		Page.listAccessorKeywords.ModifyCol(2, "AutoHdr")
		Loop % this.AccessorKeywords.MaxIndex()
			Page.listAccessorKeywords.Items.Add(A_Index = 1 ? "Select" : "", this.AccessorKeywords[A_Index].Key, this.AccessorKeywords[A_Index].Command)
		this.listAccessorKeywords_SelectionChanged("")
	}
	ApplyAccessorKeywords()
	{
		global Accessor
		Page := this.Pages.listAccessorKeywords.Tabs[1].Controls
		;Find duplicates
		pos := 1
		len := this.AccessorKeywords.MaxIndex()
		Loop % len
		{
			AccessorKeyword := this.AccessorKeywords[A_Index]
			Loop % this.AccessorKeywords.MaxIndex()
			{
				if(pos != A_Index && this.AccessorKeywords[A_Index].Key = AccessorKeyword.Key)
				{
					this.AccessorKeywords.Remove(pos)
					AccessorKeyword := ""
					break
				}
			}
			if(IsObject(AccessorKeyword))
				pos++
		}
		Accessor.Keywords := this.AccessorKeywords.DeepCopy()
	}
	btnAddAccessorKeyword_Click()
	{
		this.AddAccessorKeyword()
	}
	AddAccessorKeyword()
	{
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		this.AccessorKeywords.Insert(Object("Key", "Key", "Command", "Command"))
		Item := Page.listAccessorKeywords.Items.Add("Select", "Key", "Command")
		Page.listAccessorKeywords.SelectedItem := Item
		this.ActiveControl := Page.listAccessorKeywords
	}
	btnDeleteAccessorKeyword_Click()
	{
		this.DeleteAccessorKeyword()
	}
	DeleteAccessorKeyword()
	{
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		if(Page.listAccessorKeywords.SelectedItems.MaxIndex() != 1)
			return
		SelectedIndex := Page.listAccessorKeywords.SelectedIndex
		this.AccessorKeywords.Remove(SelectedIndex)
		Page.listAccessorKeywords.Items.Delete(SelectedIndex)
		if(SelectedIndex > Page.listAccessorKeywords.Items.MaxIndex())
			SelectedIndex := Page.listAccessorKeywords.Items.MaxIndex()
		Page.listAccessorKeywords.SelectedIndex := SelectedIndex
		this.ActiveControl := Page.listAccessorKeywords
	}
	listAccessorKeywords_SelectionChanged(Row)
	{
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		SingleSelection := Page.listAccessorKeywords.SelectedItems.MaxIndex() = 1
		Page.EditAccessorKeyword.Text := SingleSelection ? Page.listAccessorKeywords.SelectedItem[1] : ""
		Page.EditAccessorCommand.Text := SingleSelection ? Page.listAccessorKeywords.SelectedItem[2] : ""
		Page.EditAccessorKeyword.Enabled := SingleSelection
		Page.EditAccessorCommand.Enabled := SingleSelection
		Page.btnDeleteAccessorKeyword.Enabled := SingleSelection
	}
	EditAccessorKeyword_TextChanged()
	{
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		if(Page.listAccessorKeywords.SelectedItems.MaxIndex() != 1)
			return
		
		Page.listAccessorKeywords.SelectedItem[1] := Page.EditAccessorKeyword.Text
		this.AccessorKeywords[Page.listAccessorKeywords.SelectedIndex].key := Page.EditAccessorKeyword.Text
	}
	EditAccessorCommand_TextChanged()
	{		
		Page := this.Pages.AccessorKeywords.Tabs[1].Controls
		if(Page.listAccessorKeywords.SelectedItems.MaxIndex() != 1)
			return
		
		Page.listAccessorKeywords.SelectedItem[2] := Page.EditAccessorCommand.Text
		this.AccessorKeywords[Page.listAccessorKeywords.SelectedIndex].Command := Page.EditAccessorCommand.Text
	}
	
	
	;Explorer
	CreateExplorer()
	{
		Page := this.Pages.Explorer.Tabs[1]
		Page.AddControl("CheckBox", "chkAutoCheckApplyToAllFiles", "x216 y146 w477 h17", "Automatically check ""Apply to all further operations"" checkboxes in file operations")
		;~ Page.AddControl("SysLink", "linkAutoCheckApplyToAllFiles", "x197 y147 w13 h13", "?")
		Page.AddControl("CheckBox", "chkAdvancedStatusBarInfo", "x216 y123 w370 h17", "Show free space and size of selected files in status bar like in XP (7 only)")
		;~ Page.AddControl("SysLink", "linkAdvancedStatusBarInfo", "x197 y124 w13 h13", "?")
		Page.AddControl("CheckBox", "chkScrollTreeUnderMouse", "x216 y100 w247 h17", "Scroll explorer scrollbars with mouse over them")
		;~ Page.AddControl("SysLink", "linkScrollTreeUnderMouse", "x197 y101 w13 h13", "?")
		Page.Controls.chkScrollTreeUnderMouse.ToolTip := "This makes it possible to scroll the file tree or the file list when another part of the explorer window is focused."
		Page.AddControl("CheckBox", "chkImproveEnter", "x216 y77 w411 h17", "Files which are only focussed but not selected can be executed by pressing enter")
		;~ Page.AddControl("SysLink", "linkImproveEnter", "x197 y78 w13 h13", "?")
		Page.AddControl("CheckBox", "chkAutoSelectFirstFile", "x216 y54 w347 h17", "Explorer automatically selects the first file when you enter a directory")
		;~ Page.AddControl("SysLink", "linkAutoSelectFirstFile", "x197 y55 w13 h13", "?")
		Page.AddControl("CheckBox", "chkMouseGestures", "x216 y31 w454 h17", "Hold right mouse button and click left: Go back, hold left mouse and click right:")
		;~ Page.AddControl("SysLink", "linkMouseGestures", "x197 y32 w13 h13", "?")
		Page.AddControl("CheckBox", "chkRememberPath", "x216 y169 w237 h17", "Win+E: Open explorer in last active directory")
		Page.AddControl("CheckBox", "chkAlignNewExplorer", "x216 y192 w408 h17", "Win+E + explorer window active: Open new explorer and align them left and right")
		
		
		Page.AddControl("Text", "txtPasteAsFile", "x213 y238 w396 h13", "Text and images from clipboard can be pasted as file in explorer with these settings")
		chkPasteImageAsFileName := Page.AddControl("CheckBox", "chkPasteImageAsFileName", "x216 y286 w116 h17", "Paste image as file")
		;~ Page.AddControl("SysLink", "linkPasteImageAsFileName", "x197 y287 w13 h13", "?")
		chkPasteTextAsFileName := Page.AddControl("CheckBox", "chkPasteTextAsFileName", "x216 y260 w105 h17", "Paste text as file")
		;~ Page.AddControl("SysLink", "linkPasteTextAsFileName", "x197 y261 w13 h13", "?")
		Page.AddControl("Text", "txtPasteImageAsFileName", "x448 y287 w52 h13", "Filename:")
		Page.AddControl("Text", "txtPasteTextAsFileName", "x448 y261 w52 h13", "Filename:")
		Page.Controls.editPasteImageAsFileName := chkPasteImageAsFileName.AddControl("Edit", "editPasteImageAsFileName", "x506 y284 w150 h20", "", 1)
		Page.Controls.editPasteTextAsFileName := chkPasteTextAsFileName.AddControl("Edit", "editPasteTextAsFileName", "x506 y258 w150 h20", "", 1)
	}
	InitExplorer()
	{
		Page := this.Pages.Explorer.Tabs[1].Controls
		Page.chkAutoCheckApplyToAllFiles.Checked := Settings.Explorer.AutoCheckApplyToAllFiles
		Page.chkAdvancedStatusBarInfo.Checked := Settings.Explorer.AdvancedStatusBarInfo
		Page.chkScrollTreeUnderMouse.Checked := Settings.Explorer.ScrollTreeUnderMouse
		Page.chkImproveEnter.Checked := Settings.Explorer.ImproveEnter
		Page.chkAutoSelectFirstFile.Checked := Settings.Explorer.AutoSelectFirstFile
		Page.chkMouseGestures.Checked := Settings.Explorer.MouseGestures
		Page.chkRememberPath.Checked := Settings.Explorer.RememberPath
		Page.chkAlignNewExplorer.Checked := Settings.Explorer.AlignNewExplorer
		Page.chkPasteImageAsFileName.Checked := Settings.Explorer.PasteImageAsFileName != ""
		Page.chkPasteTextAsFileName.Checked := Settings.Explorer.PasteTextAsFileName != ""
		Page.editPasteImageAsFileName.Text := Settings.Explorer.PasteImageAsFileName
		Page.editPasteTextAsFileName.Text := Settings.Explorer.PasteTextAsFileName
	}
	ApplyExplorer()
	{
		Page := this.Pages.Explorer.Tabs[1].Controls
		Settings.Explorer.AutoCheckApplyToAllFiles := Page.chkAutoCheckApplyToAllFiles.Checked
		Settings.Explorer.AdvancedStatusBarInfo := Page.chkAdvancedStatusBarInfo.Checked
		Settings.Explorer.ScrollTreeUnderMouse := Page.chkScrollTreeUnderMouse.Checked
		Settings.Explorer.ImproveEnter := Page.chkImproveEnter.Checked
		Settings.Explorer.AutoSelectFirstFile := Page.chkAutoSelectFirstFile.Checked
		Settings.Explorer.MouseGestures := Page.chkMouseGestures.Checked
		Settings.Explorer.RememberPath := Page.chkRememberPath.Checked
		Settings.Explorer.AlignNewExplorer := Page.chkAlignNewExplorer.Checked
		
		Settings.Explorer.PasteImageAsFileName := Page.editPasteImageAsFileName.Text
		Settings.Explorer.PasteTextAsFileName := Page.editPasteTextAsFileName.Text
	}
	
	;Explorer Tabs
	CreateExplorerTabs()
	{
		Page := this.Pages.ExplorerTabs.Tabs[1]
		chkUseTabs := Page.AddControl("CheckBox", "chkUseTabs", "x216 y74 w126 h17", "Use Tabs in Explorer")
		Page.AddControl("Text", "txtOnTabClose", "x232 y199 w70 h13", "On tab close:")
		Page.AddControl("Text", "txtTabStartupPath", "x232 y127 w190 h13", "Tab startup path (empty for current dir):")
		Page.Controls.editTabStartupPath := chkUseTabs.AddControl("Edit", "editTabStartupPath", "x484 y124 w159 h20", "", 1)
		Page.Controls.btnTabStartupPath := chkUseTabs.AddControl("Button", "btnTabStartupPath", "x649 y122 w33 h23", "...", 1)
		Page.AddControl("Text", "txtNewTabPosition", "x232 y100 w64 h13", "Create tabs:")
		Page.Controls.ddlOnTabClose := chkUseTabs.AddControl("DropDownList", "ddlOnTabClose", "x484 y196 w159", "Next to current tab|At the end", 1)
		Page.Controls.ddlNewTabPosition := chkUseTabs.AddControl("DropDownList", "ddlNewTabPosition", "x484 y97 w159", "Activate left tab|Activate right tab", 1)
		Page.AddControl("Text", "txtTabDescription", "x216 y32 w469 h39", "7plus makes it possible to use tabs in explorer. New tabs are opened with the middle mouse button`n,and with CTRL+T, Tabs are cycled by clicking the Tabs or pressing CTRL+(SHIFT)+TAB,`nand closed by middle clicking a tab and with CTRL+W")
		Page.Controls.chkTabWindowClose := chkUseTabs.AddControl("CheckBox", "chkTabWindowClose", "x229 y173 w202 h17", "Close all tabs when window is closed", 1)
		Page.Controls.chkActivateTab := chkUseTabs.AddControl("CheckBox", "chkActivateTab", "x229 y150 w159 h17", "Activate tab on tab creation", 1)
		;~ Page.AddControl("SysLink", "linkUseTabs", "x19 y75 w13 h13", "?")
	}
	InitExplorerTabs()
	{
		Page := this.Pages.ExplorerTabs.Tabs[1].Controls
		Page.chkUseTabs.Checked := Settings.Explorer.Tabs.UseTabs
		Page.ddlNewTabPosition.SelectedIndex := Settings.Explorer.Tabs.NewTabPosition
		Page.editTabStartupPath.Text := Settings.Explorer.Tabs.TabStartupPath
		Page.chkActivateTab.Checked := Settings.Explorer.Tabs.ActivateTab
		Page.chkTabWindowClose.Checked := Settings.Explorer.Tabs.TabWindowClose
		Page.ddlOnTabClose.SelectedIndex := Settings.Explorer.Tabs.OnTabClose
	}
	ApplyExplorerTabs()
	{
		Page := this.Pages.ExplorerTabs.Tabs[1].Controls
		Settings.Explorer.Tabs.UseTabs := Page.chkUseTabs.Checked
		Settings.Explorer.Tabs.NewTabPosition := Page.ddlNewTabPosition.SelectedIndex
		Settings.Explorer.Tabs.TabStartupPath := Page.editTabStartupPath.Text
		Settings.Explorer.Tabs.ActivateTab := Page.chkActivateTab.Checked
		Settings.Explorer.Tabs.TabWindowClose := Page.chkTabWindowClose.Checked
		Settings.Explorer.Tabs.OnTabClose := Page.ddlOnTabClose.SelectedIndex
	}
	btnTabStartupPath_Click()
	{
		FolderDialog := new CFolderDialog()
		FolderDialog.Folder := this.Page.ExplorerTabs.Tabs[1].Controls.editTabStartupPath.Text
		if(FolderDialog.Show())
			this.Page.ExplorerTabs.Tabs[1].Controls.editTabStartupPath.Text := FolderDialog.Folder
	}
	
	
	;Fast Folders
	CreateFastFolders()
	{
		Page := this.Pages.FastFolders.Tabs[1]
		Page.AddControl("Text", "txtFastFoldersDescription", "x213 y32 w482 h26", "In explorer and file dialogs you can store a path in one of ten slots by pressing CTRL`nand a numpad number key (default settings), and restore it by pressing the numpad number key again")
		Page.AddControl("CheckBox", "chkShowInFolderBand", "x216 y63 w329 h17", "Integrate Fast Folders into explorer folder band bar (Vista/7 only)")
		;~ Page.AddControl("SysLink", "linkShowInFolderBand", "x19 y64 w13 h13", "?")
		Page.AddControl("CheckBox", "chkCleanFolderBand", "x216 y86 w271 h17", "Remove windows folder band buttons (Vista/7 only)")
		;~ Page.AddControl("SysLink", "linkCleanFolderBand", "x197 y87 w13 h13", "?")
		Page.Controls.chkCleanFolderBand.ToolTip := "If you use the folder band as a favorites bar like in browsers, it is recommended that you get rid of the buttons predefined by windows whereever possible (such as Slideshow, Add to Library,...)"
		Page.AddControl("CheckBox", "chkShowInPlacesBar", "x216 y109 w360 h17", "Integrate Fast Folders into open/save dialog places bar (First 5 Entries)")
		;~ Page.AddControl("SysLink", "linkShowInPlacesBar", "x197 y110 w13 h13", "?")
		Page.AddControl("Button", "btnRemoveCustomButtons", "x216 y132 w179 h23", "Remove custom Explorer buttons")
		Page.Controls.btnRemoveCustomButtons.ToolTip := "By doing this all custom buttons in the explorer folder band bar will be removed. This is useful if an error occurred and some buttons get duplicated. Once you press OK or Apply in this dialog, the buttons created with an ExplorerButton trigger will reappear. To make the FastFolder buttons reappear, save a directory to a FastFolder slot by pressing CTRL+Numpad[0-9] (Default keys)"
	}
	InitFastFolders()
	{
		Page := this.Pages.FastFolders.Tabs[1].Controls
		Page.chkShowInFolderBand.Checked := Settings.Explorer.FastFolders.ShowInFolderBand
		Page.chkCleanFolderBand.Checked := Settings.Explorer.FastFolders.CleanFolderBand
		Page.chkShowInPlacesBar.Checked := Settings.Explorer.FastFolders.ShowInPlacesBar
	}
	ApplyFastFolders()
	{
		Page := this.Pages.FastFolders.Tabs[1].Controls
		
		;Folder band settings are only usable when running non-portable as admin
		if(!Settings.IsPortable || !A_IsAdmin)
		{
			if(Page.chkShowInFolderBand.Checked != Settings.Explorer.FastFolders.ShowInFolderBand)
			{
				if(!Settings.Explorer.FastFolders.ShowInFolderBand) ;Was off, enable
					PrepareFolderBand()
				else
					RestoreFolderBand()
			}
			Settings.Explorer.FastFolders.ShowInFolderBand := Page.chkShowInFolderBand.Checked
			
			if(Page.chkCleanFolderBand.Checked != Settings.Explorer.FastFolders.CleanFolderBand)
			{
				if(!Settings.Explorer.FastFolders.CleanFolderBand) ;Was off, enable
					BackupAndRemoveFolderBandButtons()
				else
					RestoreFolderBandButtons()
			}
			Settings.Explorer.FastFolders.CleanFolderBand := Page.chkCleanFolderBand.Checked
			
			if(Page.chkShowInPlacesBar.Checked != Settings.Explorer.FastFolders.ShowInPlacesBar)
			{
				if(!Settings.Explorer.FastFolders.ShowInPlacesBar) ;Was off, enable
					BackupPlacesBar()
				else
					RestorePlacesBar()
			}
			Settings.Explorer.FastFolders.ShowInPlacesBar := Page.chkShowInPlacesBar.Checked			
		}
	}
	btnRemoveCustomButtons_Click()
	{
		RemoveAllExplorerButtons()
		MsgBox If you have defined any custom explorer buttons (or use FastFolder buttons) and you press OK or Apply now, they will reappear!
	}
	
	
	;FTP Profiles
	CreateFTPProfiles()
	{
		Page := this.Pages.FTPProfiles.Tabs[1]
		Page.AddControl("Text", "txtFTPDescription", "x213 y32 w307 h13", "You can define FTP profiles for use with the upload action here.")
		Page.AddControl("DropDownList", "ddlFTPProfile", "x216 y50 w297", "")
		Page.AddControl("Button", "btnAddFTPProfile", "x519 y48 w79 h23", "Add profile")
		Page.AddControl("Button", "btnDeleteFTPProfile", "x604 y48 w79 h23", "Delete profile")
		Page.AddControl("Text", "txtFTPHostname", "x213 y93 w58 h13", "Hostname:")
		Page.AddControl("Edit", "editFTPHostname", "x434 y90 w249 h20", "")
		Page.AddControl("Text", "txtFTPPort", "x213 y119 w29 h13", "Port:")
		Page.AddControl("Edit", "editFTPPort", "x434 y116 w45 h20", "")
		Page.AddControl("Text", "txtFTPUser", "x213 y145 w32 h13", "User:")
		Page.AddControl("Edit", "editFTPUser", "x434 y142 w249 h20", "")
		Page.AddControl("Text", "txtFTPPassword", "x213 y171 w56 h13", "Password:")
		Page.AddControl("Edit", "editFTPPassword", "x434 y168 w249 h20 Password", "")
		Page.AddControl("Text", "txtFTPURL", "x213 y195 w32 h13", "URL:")
		Page.AddControl("Edit", "editFTPURL", "x434 y192 w249 h20", "")
		Page.AddControl("Text", "txtFTPDescription2", "x213 y227 w454 h26", "Target folder and filename are set separately for each event that uses the FTP upload function on the Events page.")
	}
	InitFTPProfiles()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		this.FTPProfiles := CFTPUploadAction.FTPProfiles.DeepCopy()
		Page.ddlFTPProfile.Items.Clear()
		Loop % this.FTPProfiles.MaxIndex()
			Page.ddlFTPProfile.Items.Add(A_Index ": " this.FTPProfiles[A_Index].Hostname)
		Page.ddlFTPProfile.SelectedIndex := 1
		Page.ddlFTPProfile.Enabled := this.FTPProfiles.MaxIndex() > 0
		this.ddlFTPProfile_SelectionChanged()
	}
	ApplyFTPProfiles()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		this.StoreCurrentFTPProfile(this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
		CFTPUploadAction.FTPProfiles := this.FTPProfiles
	}
	HideFTPProfiles()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		this.StoreCurrentFTPProfile(this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
	}
	StoreCurrentFTPProfile(CurrentProfile)
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		if(CurrentProfile)
		{
			CurrentProfile.Hostname := strTrimRight(Page.editFTPHostname.Text, "/")
			CurrentProfile.Port := Page.editFTPPort.Text
			CurrentProfile.User := Page.editFTPUser.Text
			CurrentProfile.Password := Encrypt(Page.editFTPPassword.Text)
			CurrentProfile.URL := strTrimRight(Page.editFTPURL.Text, "/")
		}
	}
	btnAddFTPProfile_Click()
	{
		this.AddFTPProfile()
	}
	AddFTPProfile()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		this.FTPProfiles.Insert(Object("Hostname", "Hostname.com", "Port", 21, "User", "SomeUser", "Password", "", "URL", "http://somehost.com"))
		len := this.FTPProfiles.MaxIndex()
		Page.ddlFTPProfile.Items.Add(len ": " this.FTPProfiles[len].Hostname)
		Page.ddlFTPProfile.SelectedIndex := len
		Page.ddlFTPProfile.Enabled := true
	}
	btnDeleteFTPProfile_Click()
	{
		this.DeleteFTPProfile()
	}	
	DeleteFTPProfile()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		if(!this.FTPProfiles.MaxIndex())
			return
		this.FTPProfiles.Remove(Page.ddlFTPProfile.SelectedIndex)
		Page.ddlFTPProfile.Items.Delete(Page.ddlFTPProfile.SelectedIndex)
		if(!this.FTPProfiles.MaxIndex())
			Page.ddlFTPProfile.Enabled := false
		Notify("Info", "Make sure to update any FTP event profile assignments that pointed to the deleted profile!", 2, "GC=555555 TC=White MC=White", NotifyIcons.Info)
	}
	ddlFTPProfile_SelectionChanged()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		this.StoreCurrentFTPProfile(this.FTPProfiles[Page.ddlFTPProfile.PreviouslySelectedItem._.Index])
		SelectedIndex := Page.ddlFTPProfile.SelectedIndex
		FTPProfile := this.FTPProfiles[SelectedIndex]
		Page.editFTPHostname.Text := FTPProfile ? FTPProfile.Hostname : ""
		Page.editFTPPort.Text := FTPProfile ? FTPProfile.Port : ""
		Page.editFTPUser.Text := FTPProfile ? FTPProfile.User : ""
		Page.editFTPPassword.Text := FTPProfile ? Decrypt(FTPProfile.Password) : ""
		Page.editFTPURL.Text := FTPProfile ? FTPProfile.URL : ""
		Page.editFTPHostname.Enabled := IsObject(FTPProfile)
		Page.editFTPPort.Enabled := IsObject(FTPProfile)
		Page.editFTPUser.Enabled := IsObject(FTPProfile)
		Page.editFTPPassword.Enabled := IsObject(FTPProfile)
		Page.editFTPURL.Enabled := IsObject(FTPProfile)
	}
	editFTPHostname_TextChanged()
	{
		Page := this.Pages.FTPProfiles.Tabs[1].Controls
		if(FTPProfile := this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
		{
			Page.ddlFTPProfile.SelectedItem.Text := Page.ddlFTPProfile.SelectedIndex ": " Page.editFTPHostname.Text
			;~ FTPProfile.Hostname := Page.editFTPHostname.Text
		}
	}
	;~ editFTPPort_TextChanged()
	;~ {
		;~ Page := this.Pages.FTPProfiles.Tabs[1].Controls
		;~ if(FTPProfile := this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
			;~ FTPProfile.Port := Page.editFTPPort.Text
	;~ }
	;~ editFTPUser_TextChanged()
	;~ {
		;~ Page := this.Pages.FTPProfiles.Tabs[1].Controls
		;~ if(FTPProfile := this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
			;~ FTPProfile.User := Page.editFTPUser.Text
	;~ }
	;~ editFTPPassword_TextChanged()
	;~ {
		;~ Page := this.Pages.FTPProfiles.Tabs[1].Controls
		;~ if(FTPProfile := this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
			;~ FTPProfile.Password := Encrypt(Page.editFTPPassword.Text)
	;~ }
	;~ editFTPURL_TextChanged()
	;~ {
		;~ Page := this.Pages.FTPProfiles.Tabs[1].Controls
		;~ if(FTPProfile := this.FTPProfiles[Page.ddlFTPProfile.SelectedIndex])
			;~ FTPProfile.URL := Page.editFTPURL.Text
	;~ }
	
	
	;HotStrings
	CreateHotStrings()
	{
		Page := this.Pages.HotStrings.Tabs[1]
		Page.AddControl("Text", "txtHotStringDescription", "x197 y376", "HotStrings are used to expand abbreviations and acronyms, such as ""btw"" -> ""by the way"". They support regular`nexpressions in PCRE format. If you want a HotString to trigger only when typed as a seperate word, prepend \b`nand append \s.  For case-insensitive HotStrings, put i) at the start. You can also use keys like {Enter}.")
		Page.AddControl("ListView", "listHotStrings", "x197 y31 w525 h282", "HotString|Output")
		Page.listHotStrings.IndependentSorting := true
		Page.AddControl("Button", "btnAddHotString", "x730 y31 w90 h23", "Add HotString")
		Page.AddControl("Button", "btnDeleteHotString", "x730 y60 w90 h23", "Delete HotString")
		Page.AddControl("Text", "txtHotStringInput", "x197 y322 w50 h13", "HotString:")
		Page.AddControl("Edit", "editHotStringInput", "x260 y319 w462 h20", "")
		Page.AddControl("Text", "txtHotStringOutput", "x197 y348 w42 h13", "Output:")
		Page.AddControl("Edit", "editHotStringOutput", "x260 y345 w462 h20", "")
		Page.AddControl("Button", "btnHotStringRegExHelp", "x730 y89 w90 h23", "RegEx Help")
	}
	InitHotStrings()
	{
		global HotStrings
		Page := this.Pages.HotStrings.Tabs[1].Controls
		HotStringsCopy := HotStrings.DeepCopy()
		Page.listHotStrings.Items.Clear()
		Page.listHotStrings.ModifyCol(1, 150)
		Page.listHotStrings.ModifyCol(2, "AutoHdr")
		Loop % HotStringsCopy.MaxIndex()
			Page.listHotStrings.Items.Add(A_Index = 1 ? "Select" : "", HotStringsCopy[A_Index].Key, HotStringsCopy[A_Index].Value)
		this.HotStrings := HotStringsCopy
		this.listHotStrings_SelectionChanged("")
	}
	ApplyHotStrings()
	{
		global HotStrings
		Page := this.Pages.HotStrings.Tabs[1].Controls
		;Find duplicates
		pos := 1
		len := this.HotStrings.MaxIndex()
		Loop % len
		{
			HotString := this.HotStrings[A_Index]
			Loop % this.HotStrings.MaxIndex()
			{
				if(pos != A_Index && this.HotStrings[A_Index].Key = HotString.Key)
				{
					this.HotStrings.Remove(pos)
					HotString := ""
					break
				}
			}
			if(IsObject(HotString))
				pos++
		}
		HotStrings := this.HotStrings
	}
	btnAddHotString_Click()
	{
		this.AddHotString()
	}
	AddHotString()
	{
		Page := this.Pages.HotStrings.Tabs[1].Controls
		this.HotStrings.Insert(Object("Key", "HotString", "Value", "Output"))
		Item := Page.listHotStrings.Items.Add("Select", "HotString", "Output")
		Page.listHotStrings.SelectedItem := Item
		this.ActiveControl := Page.listAccessorKeywords
	}	
	btnDeleteHotString_Click()
	{
		this.DeleteHotString()
	}
	DeleteHotString()
	{
		Page := this.Pages.HotStrings.Tabs[1].Controls
		if(Page.listHotStrings.SelectedItems.MaxIndex() != 1)
			return
		SelectedIndex := Page.listHotStrings.SelectedIndex
		this.HotStrings.Remove(SelectedIndex)
		Page.listHotStrings.Items.Delete(SelectedIndex)		
		if(SelectedIndex > Page.listHotStrings.Items.MaxIndex())
			SelectedIndex := Page.listHotStrings.Items.MaxIndex()
		Page.listHotStrings.SelectedIndex := SelectedIndex
		this.ActiveControl := Page.listHotStrings
	}	
	listHotStrings_SelectionChanged(Row)
	{
		Page := this.Pages.HotStrings.Tabs[1].Controls
		SingleSelection := Page.listHotStrings.SelectedItems.MaxIndex() = 1
		Page.editHotStringInput.Text := SingleSelection ? Page.listHotStrings.SelectedItem[1] : ""
		Page.editHotStringOutput.Text := SingleSelection ? Page.listHotStrings.SelectedItem[2] : ""
		Page.editHotStringInput.Enabled := SingleSelection
		Page.editHotStringOutput.Enabled := SingleSelection
		Page.btnDeleteHotString.Enabled := SingleSelection
	}
	EditHotStringInput_TextChanged()
	{
		Page := this.Pages.HotStrings.Tabs[1].Controls
		if(Page.listHotStrings.SelectedItems.MaxIndex() != 1)
			return
		
		Page.listHotStrings.SelectedItem[1] := Page.editHotStringInput.Text
		this.HotStrings[Page.listHotStrings.SelectedIndex].key := Page.editHotStringInput.Text
	}
	editHotStringOutput_TextChanged()
	{		
		Page := this.Pages.HotStrings.Tabs[1].Controls
		if(Page.listHotStrings.SelectedItems.MaxIndex() != 1)
			return
		
		Page.listHotStrings.SelectedItem[2] := Page.editHotStringOutput.Text
		this.HotStrings[Page.listHotStrings.SelectedIndex].Value := Page.editHotStringOutput.Text
	}
	btnHotStringRegExHelp_Click()
	{
		run http://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm
	}
	
	
	;Windows
	CreateWindows()
	{
		Page := this.Pages.Windows.Tabs[1]
		Page.AddControl("Text", "txtSlideWindows", "x218 y34 w269 h17", "WIN + SHIFT + Arrow keys: Slide Window function")
		Page.Controls.txtSlideWindows.ToolTip := "A Slide Window is moved off screen and will not be shown until you activate it through task bar / ALT + TAB or move the mouse to the border where it was hidden. It will then slide into the screen, and slide out again when the mouse leaves the window or when another window gets activated. Deactivate this mode by moving the window or pressing WIN+SHIFT+Arrow key in another direction."
		Page.AddControl("CheckBox", "chkHideSlideWindows", "x235 y57 w272 h17", "Hide Slide Windows in taskbar and from ALT + TAB")
		Page.AddControl("CheckBox", "chkLimitToOnePerSide", "x235 y80 w239 h17", "Allow only one Slide Window per screen side")
		Page.AddControl("CheckBox", "chkBorderActivationRequiresMouseUp", "x235 y103 w387 h17", "Require left mouse button to be up to activate slide window at screen border")
		Page.Controls.chkBorderActivationRequiresMouseUp.ToolTip := "This feature is used to prevent accidently activating a slide window while dragging with the mouse. It's still possible to drag something to the slide window by holding the modifier key which is set below."
		Page.AddControl("Text", "txtModifierKey", "x235 y129 w139 h13", "Slide Windows modifier key:")
		Page.AddControl("DropDownList", "ddlModifierKey", "x421 y126 w111", "Control|Alt|Shift|Win")
		Page.Controls.ddlModifierKey.ToolTip := "If this key is pressed, the mouse may be moved out of the currently active slide window without sliding it out. This is useful if the slide window has child windows that don't overlap with the main window. If the option above is enabled, it may also be used to drag something into a hidden slide window by moving the mouse to the screen border and holding this key."
		Page.AddControl("CheckBox", "chkAutoCloseWindowsUpdate", "x218 y196 w321 h17", "Automatically close Windows Update reboot notification dialog")
		Page.Controls.chkAutoCloseWindowsUpdate.ToolTip :=  "If you enable this setting you will not be able to open this dialog anymore. You can simply reboot windows though..."
		Page.AddControl("CheckBox", "chkShowResizeTooltip", "x218 y173 w225 h17", "Show window size as tooltip while resizing")
		;~ Page.AddControl("SysLink", "linkUseSlideWindows", "x200 y35 w13 h13", "?")
	}
	InitWindows()
	{
		Page := this.Pages.Windows.Tabs[1].Controls
		Page.chkHideSlideWindows.Checked := Settings.Windows.SlideWindows.HideSlideWindows
		Page.chkLimitToOnePerSide.Checked := Settings.Windows.SlideWindows.LimitToOnePerSide
		Page.chkBorderActivationRequiresMouseUp.Checked := Settings.Windows.SlideWindows.chkBorderActivationRequiresMouseUp
		Page.ddlModifierKey.Text := Settings.Windows.SlideWindows.ModifierKey
		
		Page.chkAutoCloseWindowsUpdate.Checked := Settings.Windows.AutoCloseWindowsUpdate
		Page.Controls.chkShowResizeTooltip.Checked := Settings.Windows.ShowResizeToolTip
	}
	ApplyWindows()
	{
		Page := this.Pages.Windows.Tabs[1].Controls
		
		Settings.Windows.SlideWindows.HideSlideWindows := Page.chkHideSlideWindows.Checked
		Settings.Windows.SlideWindows.LimitToOnePerSide := Page.chkLimitToOnePerSide.Checked
		Settings.Windows.SlideWindows.chkBorderActivationRequiresMouseUp := Page.chkBorderActivationRequiresMouseUp.Checked
		Settings.Windows.SlideWindows.ModifierKey := Page.ddlModifierKey.Text
		
		Settings.Windows.AutoCloseWindowsUpdate := Page.chkAutoCloseWindowsUpdate.Checked
		Settings.Windows.ShowResizeToolTip := Page.chkShowResizeTooltip.Checked
	}
	
	
	;WindowsSettings
	CreateWindowsSettings()
	{
		Page := this.Pages.WindowsSettings.Tabs[1]
		Page.AddControl("Text", "txtExplorer", "x197 y31", "Explorer:")
		Page.AddControl("CheckBox", "chkRemoveUserDir", "x197 y47", "Remove user directory from directory tree")
		Page.AddControl("CheckBox", "chkRemoveWMP", "x197 y70", "Remove Windows Media Player context menu entries (Play, Add to playlist, Buy music")
		Page.AddControl("CheckBox", "chkRemoveOpenWith", "x197 y93", "Remove ""Open With Webservice or choose program"" dialogs for unknown file extensions")
		Page.AddControl("CheckBox", "chkShowExtensions", "x197 y116", "Always show file extensions")
		Page.AddControl("CheckBox", "chkShowHiddenFiles", "x197 y139", "Show hidden files")
		Page.AddControl("CheckBox", "chkShowSystemFiles", "x197 y162", "Show system files")
		Page.AddControl("CheckBox", "chkRemoveExplorerLibraries", "x197 y185", "Remove explorer libraries (from directory tree and context menus) (WIN7 or later)")
		Page.AddControl("CheckBox", "chkClassicExplorerView", "x197 y208", "Use classic explorer view (XP only)")
		Page.AddControl("Text", "txtWindows", "x197 y247 w54 h13", "Windows:")
		Page.AddControl("CheckBox", "chkCycleThroughTaskbarGroup", "x197 y263", "Left click on task group button: cycle through windows (7 or later)")
		Page.AddControl("CheckBox", "chkShowAllNotifications", "x197 y286", "Show all tray notification icons")
		Page.AddControl("CheckBox", "chkRemoveCrashReporting", "x197 y309", "Remove crash reporting dialog")
		Page.AddControl("CheckBox", "chkDisableUAC", "x197 y332", "Disable UAC (Vista or later)")
		Page.AddControl("Text", "txtThumbnailHoverTime", "x197 y358", "Taskbar thumbnail hover time [ms] (WIN7 or later):")
		Page.AddControl("Edit", "editThumbnailHoverTime", "x434 y355", "")
	}
	InitWindowsSettings()
	{
		Page := this.Pages.WindowsSettings.Tabs[1].Controls
		for Name, Control in Page
			if(Control.Type = "CheckBox")
			{
				Property := WindowsSettings["Get" SubStr(Name, 4)]()
				if(Property = -1)
					Control.Disable()
				else
					Control.Checked := Control.OrigChecked := Property
			}
		Property := WindowsSettings.GetThumbnailHoverTime()
		if(Property = -1)
			Page.editThumbnailHoverTime.Disable()
		else
			Page.editThumbnailHoverTime.Text := Page.editThumbnailHoverTime.OrigText := Property
	}
	ApplyWindowsSettings()
	{
		Page := this.Pages.WindowsSettings.Tabs[1].Controls
		RequiredAction := 0
		for Name, Control in Page
			if(Control.Type = "CheckBox" && Control.Checked != Control.OrigChecked)
				RequiredAction |= WindowsSettings["Set" SubStr(Name, 4)](Control.Checked)
		if(Page.editThumbnailHoverTime.Text != Page.editThumbnailHoverTime.OrigText)
			RequiredAction |= WindowsSettings.SetThumbnailHoverTime(Page.editThumbnailHoverTime.Text)
	}
	
	;Misc
	CreateMisc()
	{
		Page := this.Pages.Misc.Tabs[1]
		;~ Page.AddControl("SysLink", "linkFixEditControlWordDelete", "x197 y58 w13 h13", "?")
		Page.AddControl("CheckBox", "chkFixEditControlWordDelete", "x216 y57 w333 h17", "Make CTRL+Backspace and CTRL+Delete work in all textboxes")
		Page.Controls.chkFixEditControlWordDelete.ToolTip := "Many text boxes in windows have the problem that it's not possible to use CTRL+Backspace to delete a word. Instead, it will write a square character. Enabling this will fix it."
		;~ Page.AddControl("SysLink", "linkGamepadRemoteControl", "x19 y35 w13 h13", "?")
		Page.AddControl("CheckBox", "chkGamepadRemoteControl", "x216 y34 w489 h17", "Use joystick/gamepad as remote control when not in fullscreen (optimized for XBOX")
		
		Page.AddControl("Text", "txtImageQuality", "x213 y92 w134 h13", "Image compression quality:")
		Page.AddControl("Edit", "editImageQuality", "x404 y89 w52 h20", "")
		Page.AddControl("Text", "txtDefaultImageExtension", "x213 y118 w123 h13", "Default image extension:")
		Page.AddControl("Edit", "editDefaultImageExtension", "x404 y115 w52 h20", "")
		Page.AddControl("Text", "txtFullScreenDescription", "x213 y152 w511 h26", "Many features of 7plus check if there is a fullscreen window active. You can add window class names to include and exclude filters here to influence the fullscreen recognition.")
		Page.AddControl("Text", "txtFullscreenInclude", "x213 y184 w157 h13", "Fullscreen detection include list:")
		Page.AddControl("Edit", "editFullscreenInclude", "x404 y181 w261 h20", "")
		Page.AddControl("Text", "txtFullscreenExclude", "x213 y210 w160 h13", "Fullscreen detection exclude list:")
		Page.AddControl("Edit", "editFullscreenExclude", "x404 y207 w261 h20", "")
	}
	InitMisc()
	{
		Page := this.Pages.Misc.Tabs[1].Controls
		
		Page.chkFixEditControlWordDelete.Checked := Settings.Misc.FixEditControlWordDelete
		Page.chkGamepadRemoteControl.Checked := Settings.Misc.GamepadRemoteControl		
		
		Page.editImageQuality.Text := Settings.Misc.ImageQuality
		Page.editDefaultImageExtension.Text := Settings.Misc.DefaultImageExtension
		Page.editFullscreenInclude.Text := Settings.Misc.FullscreenInclude
		Page.editFullscreenExclude.Text := Settings.Misc.FullscreenExclude		
	}
	ApplyMisc()
	{
		Page := this.Pages.Misc.Tabs[1].Controls
		
		Settings.Misc.FixEditControlWordDelete := Page.chkFixEditControlWordDelete.Checked
		Settings.Misc.GamepadRemoteControl := Page.chkGamepadRemoteControl.Checked
		if(Settings.Misc.GamepadRemoteControl)
			JoystickStart()
		else
			JoystickStop()
		
		Settings.Misc.ImageQuality := Page.editImageQuality.Text
		Settings.Misc.DefaultImageExtension := Page.editDefaultImageExtension.Text
		Settings.Misc.FullscreenInclude := Page.editFullscreenInclude.Text
		Settings.Misc.FullscreenExclude := Page.editFullscreenExclude.Text
	}
	; Doesn't work :(
	/*
	editImageQuality_Validate(Text)
	{
		if(!(Text >= 5 && Text <= 100))
			return 95
	}
	*/
	
	; About	
	CreateAbout()
	{
		Page := this.Pages.About.Tabs[1]
		txt7plusVersion := Page.AddControl("Text", "txt7plusVersion", "x197 y31 w300 h40", "7plus Version " VersionString(1))
		txt7plusVersion.Font.Size := 20
		Page.AddControl("Picture", "img7plus", "x506 y31 w128 h128", A_ScriptDir "\128.png")
		Page.AddControl("Picture", "imgDonate", "x200 y182", A_ScriptDir "\Donate.png")
		;~ Page.AddControl("SysLink", "linkLicense", "x392 y264 w158 h13", "<A HREF=""http://www.gnu.org/licenses/gpl.html"">GNU General Public License v3</A>")
		;~ Page.AddControl("SysLink", "linkAHK", "x197 y229 w110 h13", "<A HREF=""www.autohotkey.com"">www.autohotkey.com</A>")
		;~ Page.AddControl("SysLink", "linkTwitter", "x392 y133 w38 h13", "<A HREF=""http://www.twitter.com/7_plus"">7_plus</A>")
		;~ Page.AddControl("SysLink", "linkEmail", "x392 y117 w103 h13", "<A HREF=""mailto://fragman@gmail.com"">fragman@gmail.com</A>")
		;~ Page.AddControl("SysLink", "linkBugs", "x392 y85 w212 h13", "<A HREF=""http://code.google.com/p/7plus/issues/list"">http://code.google.com/p/7plus/issues/list</A>")
		;~ Page.AddControl("SysLink", "linkHomepage", "x392 y69 w166 h13", "<A HREF=""http://code.google.com/p/7plus/"">http://code.google.com/p/7plus/</A>")
		;~ Page.AddControl("SysLink", "linkAutoupdater", "x221 y213 w306 h13", "The Autoudater uses <A HREF=""http://www.7-zip.org"">7-Zip</A>, which is licensed under the <A HREF=""http://www.gnu.org/licenses/lgpl.html"">LGPL</A>")
		Page.AddControl("Text", "txtCredits", "x197 y297 w392 h39", "Credits for lots of code samples and help go out to:`nSean, HotKeyIt, majkinetor, polyethene, Lexikos, tic, fincs, TheGood, PhiLho, Temp01, Laszlo, jballi, Shrinker,`nM@x and the other guys and gals on #ahk and the forums.")
		Page.AddControl("Text", "txtLicense", "x197 y264 w80 h13", "Licensed under")
		Page.AddControl("Text", "txtLanguage", "x197 y213 w146 h13", "Proudly written in AutoHotkey")
		Page.AddControl("Text", "txtDonate", "x197 y166 w282 h13", "To support the development of this project, please donate:")
		Page.AddControl("Text", "txtTwitter", "x197 y133 w39 h13", "Twitter")
		Page.AddControl("Text", "txtEmail", "x197 y117 w36 h13", "E-Mail")
		Page.AddControl("Text", "txtAuthor2", "x392 y101 w84 h13", "Christian Sander")
		Page.AddControl("Text", "txtAuthor", "x197 y101 w38 h13", "Author")
		Page.AddControl("Text", "txtBugs", "x197 y85 w65 h13", "Report bugs")
		Page.AddControl("Text", "txtHomepage", "x197 y69 w70 h13", "Project page:")
	}
	
	;Placeholder function, nothing to do yet
	InitAbout()
	{
		;~ Page := this.Pages.About.Tabs[1].Controls
	}
	;Placeholder function, nothing to do yet
	ApplyAbout()
	{
		;~ Page := this.Pages.About.Tabs[1].Controls
	}
	img7plus_Click()
	{
		MsgBox You found an easteregg, go get yourself a cookie!
	}
	imgDonate_Click()
	{
		run https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CCDPER7Z2CHZW
	}
	
	
	
	WM_KEYDOWN(Message, wParam, lParam, hwnd)
	{
		static VK_DELETE := 46, VK_A := 65
		PageEvents := this.Pages.Events.Tabs[1].Controls
		PageAccessorKeywords := this.Pages.AccessorKeywords.Tabs[1].Controls
		PageHotStrings := this.Pages.HotStrings.Tabs[1].Controls
		;VK_DELETE = 46, a=65
		if(hwnd = PageEvents.listEvents.hwnd)
		{
			if(wParam = VK_DELETE)
			{
				this.DeleteEvents()
				return true
			}
			else if(wParam = VK_A && GetKeyState("Control", "P"))
			{
				PageEvents.listEvents.SelectedItems := PageEvents.listEvents.Items
				return true
			}
			;Forward regular keys to event filter edit control
			else if(wParam != 17 && (wParam <= 32 || wParam >= 41) && !GetKeyState("Control", "P"))
			{
				PostMessage, Message, %wParam%, %lParam%,, % "ahk_id " PageEvents.editEventFilter.hwnd
				return true
			}
		}
		else if(hwnd = PageAccessorKeywords.listAccessorKeywords.hwnd)
		{
			if(wParam = VK_DELETE)
			{
				this.DeleteAccessorKeyword()
				return true
			}
		}
		else if(hwnd = PageHotStrings.listHotStrings.hwnd)
		{
			if(wParam = VK_DELETE)
			{
				this.DeleteHotString()
				return true
			}
		}
	}
	WM_KEYUP(Message, wParam, lParam, hwnd)
	{
		Page := this.Pages.Events.Tabs[1].Controls
		if(hwnd = Page.listEvents.hwnd)
		{
			;Forward regular keys to event filter edit control
			if(wParam != 17 && (wParam <= 32 || wParam >= 41) && !GetKeyState("Control", "P"))
			{
				PostMessage, 0x101, %wParam%, %lParam%,, % "ahk_id " Page.editEventFilter.hwnd
				return true
			}
		}
	}
	
	
	;Helper functions
	GetSelectedCategory(DefaultToUncategorized = false)
	{
		return this.treePages.SelectedItem.Parent = this.treePages.Items[2] ? this.treePages.SelectedItem.Text : (DefaultToUncategorized ? "Uncategorized" : "")
	}
}