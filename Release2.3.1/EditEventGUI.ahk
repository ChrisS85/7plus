;Gets the event which is currently being edited by the GUI Name of the editor window
GetCurrentSubEvent()
{
	if(!IsObject(EventEditor := CGUI.GUIList[A_GUI]))
	{
		MsgBox Can't find the trigger/condition or action of the currently edited event because the event editor was not found!
		return
	}
	CurrentTab := EventEditor.Tab.SelectedItem.Text
	if(CurrentTab = "Trigger")
		return EventEditor.Event.Trigger
	else if(CurrentTab = "Conditions")
		return EventEditor.Event.Conditions[EventEditor.listConditions.SelectedIndex]
	else if(CurrentTab = "Actions")
		return EventEditor.Event.Actions[EventEditor.listActions.SelectedIndex]
	return 
}
Class CEventEditor extends CGUI
{
	;~ static Instance := new CEventEditor("")
	btnOK := this.AddControl("Button", "btnOK", "x729 y557 w70 h23", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "x809 y557 w80 h23", "&Cancel")
	Tab := this.AddControl("Tab", "Tab", "x17 y8 w872 h512", "Trigger|Conditions|Actions|Options")
	
	;Trigger controls
	txtTrigger := this.Tab.Tabs[1].AddControl("Text", "txtTrigger", "x31 y36", "Here you can define how this event gets triggered.")
	txtTriggerCategory := this.Tab.Tabs[1].AddControl("Text", "txtTriggerCategory", "x31 y60", "Category:")
	txtTriggerTrigger := this.Tab.Tabs[1].AddControl("Text", "txtTriggerTrigger", "x31 y90", "Trigger:")
	ddlTriggerCategory := this.Tab.Tabs[1].AddControl("DropDownList", "ddlTriggerCategory", "x101 y56 w300", "")
	ddlTriggerType := this.Tab.Tabs[1].AddControl("DropDownList", "ddlTriggerType", "x101 y86 w300", "")
	btnTriggerHelp := this.Tab.Tabs[1].AddControl("Button", "btnTriggerHelp", "x+10 y85", "Help")
	grpTriggerOptions := this.Tab.Tabs[1].AddControl("GroupBox", "grpTriggerOptions", "x31 y116 w846 h384", "Options")
	
	;Condition controls
	txtCondition := this.Tab.Tabs[2].AddControl("Text", "txtCondition", "x31 y36", "The conditions below must be fullfilled to allow this event to execute.")
	listConditions := this.Tab.Tabs[2].AddControl("ListView", "listConditions", "x31 y56 w270 h454 -Multi", "Conditions")
	btnAddCondition := this.Tab.Tabs[2].AddControl("Button", "btnAddCondition", "x311 y56 w90", "Add Condition")
	btnDeleteCondition := this.Tab.Tabs[2].AddControl("Button", "btnDeleteCondition", "x311 y86 w90", "Delete Condition")
	btnCopyCondition := this.Tab.Tabs[2].AddControl("Button", "btnCopyCondition", "x311 y116 w90", "Copy Condition")
	btnPasteCondition := this.Tab.Tabs[2].AddControl("Button", "btnPasteCondition", "x311 y146 w90", "Paste Condition")
	btnMoveConditionUp := this.Tab.Tabs[2].AddControl("Button", "btnMoveConditionUp", "x311 y176 w90", "Move Up")
	btnMoveConditionDown := this.Tab.Tabs[2].AddControl("Button", "btnMoveConditionDown", "x311 y206 w90", "Move Down")
	txtCondition2 := this.Tab.Tabs[2].AddControl("Text", "txtCondition2", "x431 y36", "Here you can define the selected condition.")
	chkNegateCondition := this.Tab.Tabs[2].AddControl("Checkbox", "chkNegateCondition", "x431 y56", "Negate Condition")
	txtConditionCategory := this.Tab.Tabs[2].AddControl("Text", "txtConditionCategory", "x431 y86", "Category:")
	txtConditionType := this.Tab.Tabs[2].AddControl("Text", "txtConditionType", "x431 y109", "Condition:")
	ddlConditionCategory := this.Tab.Tabs[2].AddControl("DropDownList", "ddlConditionCategory", "x501 y86 w300", "")
	btnConditionHelp := this.Tab.Tabs[2].AddControl("Button", "btnConditionHelp", "x+10 y114", "Help")
	ddlConditionType := this.Tab.Tabs[2].AddControl("DropDownList", "ddlConditionType", "x501 y116 w300", "")
	grpConditionOptions := this.Tab.Tabs[2].AddControl("GroupBox", "grpConditionOptions", "x431 y146 w446 h364", "Options")
	
	;Action controls
	txtAction := this.Tab.Tabs[3].AddControl("Text", "txtAction", "x31 y36", "These actions will be executed when the event gets triggered.")
	listActions := this.Tab.Tabs[3].AddControl("ListView", "listActions", "x31 y56 w270 h454 -Multi", "Actions")
	btnAddAction := this.Tab.Tabs[3].AddControl("Button", "btnAddAction", "x311 y56 w90", "Add Action")
	btnDeleteAction := this.Tab.Tabs[3].AddControl("Button", "btnDeleteAction", "x311 y86 w90", "Delete Action")
	btnCopyAction := this.Tab.Tabs[3].AddControl("Button", "btnCopyAction", "x311 y116 w90", "Copy Action")
	btnPasteAction := this.Tab.Tabs[3].AddControl("Button", "btnPasteAction", "x311 y146 w90", "Paste Action")
	btnMoveActionUp := this.Tab.Tabs[3].AddControl("Button", "btnMoveActionUp", "x311 y176 w90", "Move Up")
	btnMoveActionDown := this.Tab.Tabs[3].AddControl("Button", "btnMoveActionDown", "x311 y206 w90", "Move Down")
	txtAction2 := this.Tab.Tabs[3].AddControl("Text", "txtAction2", "x431 y36", "Here you can define what this action does.")
	txtActionCategory := this.Tab.Tabs[3].AddControl("Text", "txtActionCategory", "x431 y60", "Category:")
	txtActionType := this.Tab.Tabs[3].AddControl("Text", "txtActionType", "x431 y80", "Action:")
	ddlActionCategory := this.Tab.Tabs[3].AddControl("DropDownList", "ddlActionCategory", "x501 y56 w300", "")
	btnActionHelp := this.Tab.Tabs[3].AddControl("Button", "btnActionHelp", "x+10 y85", "Help")
	ddlActionType := this.Tab.Tabs[3].AddControl("DropDownList", "ddlActionType", "x501 y86 w300", "")
	grpActionOptions := this.Tab.Tabs[3].AddControl("GroupBox", "grpActionOptions", "x431 y116 w446 h364", "Options")
	
	;Option controls
	txtEventName := this.Tab.Tabs[4].AddControl("Text", "txtEventName", "x31 y48", "Event Name:")
	editEventName := this.Tab.Tabs[4].AddControl("Edit", "editEventName", "x131 y44 w300", "")
	txtEventDescription := this.Tab.Tabs[4].AddControl("Text", "txtEventDescription", "x31 y74", "Event Description:")
	editEventDescription := this.Tab.Tabs[4].AddControl("Edit", "editEventDescription", "x131 y70 w300 h60 Multi", "")
	txtEventCategory := this.Tab.Tabs[4].AddControl("Text", "txtEventCategory", "x31 y140", "Event Category:")
	comboEventCategory := this.Tab.Tabs[4].AddControl("ComboBox", "comboEventCategory", "x131 y139 w300", "")
	chkDisableEventAfterUse := this.Tab.Tabs[4].AddControl("CheckBox", "chkDisableEventAfterUse", "x31 y166", "Disable after use")
	chkDeleteEventAfterUse := this.Tab.Tabs[4].AddControl("CheckBox", "chkDeleteEventAfterUse", "x31 y196", "Delete after use")
	chkEventOneInstance := this.Tab.Tabs[4].AddControl("CheckBox", "chkEventOneInstance", "x31 y226", "Disallow this event from being run in parallel")
	chkComplexEvent := this.Tab.Tabs[4].AddControl("CheckBox", "chkComplexEvent", "x31 y256", "Advanced event (hidden from simple view)")
	
	;SubeventGUIs contain information about specific subparts of the GUI which are handled by the sub-events like triggers, conditions and actions
	TriggerGUI := ""
	ConditionGUI := ""
	ActionGUI := ""
	__New(Event, TemporaryEvent)
	{
		if(!Event)
			MsgBox Event Editor: Event not found!
		this.Event := Event
		this.TemporaryEvent := TemporaryEvent
		
		;Disable the settings window that opened this dialog if it exists
		SettingsWindow.Enabled := false
		
		;Setup control states
		
		;Initialize trigger tab (categories and types and trigger gui)
		IndexToSelect := 1
		for CategoryName, Category in CTrigger.Categories
		{
			this.ddlTriggerCategory.Items.Add(CategoryName)
			if(CategoryName = this.Event.Trigger.Category)
				IndexToSelect := A_Index
		}
		this.ddlTriggerCategory.SelectedIndex := IndexToSelect
		
		;Initilialize conditions tab (conditions, categories, types and condition gui)
		if(!IsObject(ConditionClipboard))
			this.btnPasteCondition.Enabled := false
		
		;Fill conditions list
		for index, Condition in this.Event.Conditions
			this.listConditions.Items.Add("", (Condition.Negate ? "NOT " : "" ) Condition.DisplayString())
		
		;Fill condition categories
		for CategoryName, Category in CCondition.Categories
			this.ddlConditionCategory.Items.Add(CategoryName)
		
		if(this.listConditions.Items.MaxIndex())
			this.listConditions.SelectedIndex := 1
		
		this.btnPasteCondition.Enabled := EventSystem.IsObject(ConditionClipboard)
		
		;Initilialize actions tab (actions, categories, types and action gui)
		if(!IsObject(ActionClipboard))
			this.btnPasteAction.Enabled := false
		
		;Fill actions list
		for index, Action in this.Event.Actions
			this.listActions.Items.Add("", Action.DisplayString())
		
		;Fill action categories
		for CategoryName, Category in CAction.Categories
			this.ddlActionCategory.Items.Add(CategoryName)
		
		if(this.listActions.Items.MaxIndex())
			this.listActions.SelectedIndex := 1
		
		this.btnPasteAction.Enabled := EventSystem.IsObject(ActionClipboard)
		
		;Initialize options tab
		this.editEventName.Text := this.Event.Name
		this.editEventDescription.Text := this.Event.Description
		for index, Category in SettingsWindow.Events.Categories
			this.comboEventCategory.Items.Add(Category)
		this.comboEventCategory.Text := Event.Category
		
		this.chkDisableEventAfterUse.Checked := Event.DisableAfterUse = 1
		this.chkDeleteEventAfterUse.Checked := Event.DeleteAfterUse = 1
		this.chkEventOneInstance.Checked := Event.OneInstance = 1
		this.chkComplexEvent.Checked := Event.EventComplexityLevel = 1
		
		
		;Setup some window options
		this.DestroyOnClose := true
		this.CloseOnEscape := true
		this.Title := "Event Editor"
		
		this.Show()
	}
	
	btnOK_Click()
	{
		this.SubmitTrigger()
		this.SubmitCondition()
		this.SubmitAction()
		this.Event.Name := this.editEventName.Text
		this.Event.Description := this.editEventDescription.Text
		this.Event.Category := this.comboEventCategory.Text ? this.comboEventCategory.Text : "Uncategorized"
		this.Event.DisableAfterUse := this.chkDisableEventAfterUse.Checked
		this.Event.DeleteAfterUse := this.chkDeleteEventAfterUse.Checked
		this.Event.OneInstance := this.chkEventOneInstance.Checked
		this.Event.EventComplexityLevel := this.chkComplexEvent.Checked
		this.Result := this.Event
		this.Close()
	}
	btnCancel_Click()
	{
		this.Result := ""
		this.Close()
	}
	
	PreClose()
	{
		;Enable the settings window that opened this dialog if it exists
		SettingsWindow.Enabled := true
		SettingsWindow.FinishEditing(this.Result, this.TemporaryEvent)
	}
	ddlTriggerCategory_SelectionChanged(Item)
	{
		if(this.TriggerGUI) ;if a trigger is already showing a gui, check if the new one is different
			if(this.Event.Trigger.Category = Item.Text) ;selecting same item, ignore
				return
		
		;Get all triggers of the new category
		category := CTrigger.Categories[Item.Text]
		
		this.ddlTriggerType.DisableNotifications := true
		this.ddlTriggerType.Items.Clear()
		IndexToSelect := 1
		for index, Trigger in CTrigger.Categories[Item.Text]
		{
			this.ddlTriggerType.Items.Add(Trigger.Type)
			if(this.Event.Trigger.Type = Trigger.Type)
				IndexToSelect := index
		}
		this.ddlTriggerType.DisableNotifications := false
		this.ddlTriggerType.SelectedIndex := IndexToSelect
		return
	}
	ddlTriggerType_SelectionChanged(Item)
	{
		Type := Item.Text
		Category := this.ddlTriggerCategory.SelectedItem.Text
		;At startup, TriggerGUI isn't set, and so the original Trigger doesn't get overriden
		;If it is set, the code below treats a change of type by destroying the previous window elements and creates a new trigger
		if(this.TriggerGUI)
		{
			if(this.Event.Trigger.Type = Type && this.Event.Trigger.Category = Category) ;selecting same item, ignore
				return
			this.SubmitTrigger()
			TriggerTemplate := EventSystem.Triggers[Type]
			this.Event.Trigger := new TriggerTemplate()
		}
		;Show trigger-specific part of the gui and store hwnds in TriggerGUI
		this.ShowTrigger()
		return
	}
	SubmitTrigger()
	{
		Gui, % this.GUINum ": Default"
		Gui, Tab, 1
		this.Event.Trigger.GuiSubmit(this.TriggerGUI)
		Gui, Tab
	}
	ShowTrigger()
	{
		this.TriggerGUI := {Type: this.Event.Trigger.Type}
		this.TriggerGUI.x := 38
		this.TriggerGUI.y := 148
		this.TriggerGUI.GUINum := this.GUINum
		this.TriggerBackup := this.Event.Trigger.DeepCopy()
		
		Gui, % this.GUINum ": Default"
		Gui, Tab, 1
		this.Event.Trigger.GuiShow(this.TriggerGUI)
		Gui, Tab
	}
	btnTriggerHelp_Click()
	{
		static OldTypes := {"On 7plus start" : "7plusStart", "Context menu" : "ContextMenu", "Double click on desktop" : "DoubleClickDesktop", "Double click on taskbar" : "DoubleClickTaskbar", "Explorer bar button" : "ExplorerButton", "Double click on empty space" : "ExplorerDoubleClickSpace", "Explorer path changed" : "ExplorerPathChanged", "Menu item clicked" : "MenuItem", "On window message" : "OnMessage", "Screen corner" : "ScreenCorner", "Triggered by an action" : "None", "Window activated" : "WindowActivated", "Window closed" : "WindowClosed", "Window created" : "WindowCreated", "Window state changed" : "WindowStateChange"}
		OpenWikiPage("docsTriggers" (OldTypes.HasKey(this.Event.Trigger.Type) ? OldTypes[this.Event.Trigger.Type] : this.Event.Trigger.Type))
	}
	listConditions_SelectionChanged(Item)
	{
		;A new item was selected
		if(Item && this.listConditions.SelectedIndices.MaxIndex() = 1 && this.listConditions.SelectedIndex != this.listConditions.PreviouslySelectedIndex && this.listConditions.SelectedItem = item)
		{
			if(this.Condition)
				this.SubmitCondition()
			this.ddlConditionCategory.Enabled := true
			this.ddlConditionType.Enabled := true
			this.chkNegateCondition.Enabled := true
			this.Condition :=  this.Event.Conditions[Item.Index]
			;Mark that the Condition stored under this.Condition should be used instead of creating a new one of the type set in the type dropdownlist.
			this.UseCondition := true
			if(this.Condition.Category != this.ddlConditionCategory.Text) ;The category of the new Condition is different from the old one
				this.ddlConditionCategory.Text := this.Condition.Category
			else if(this.Condition.Type != this.ddlConditionType.Text) ;The type of the new Condition is different from the old one
				this.ddlConditionType.Text := this.Condition.Type
			else ;The Condition is of the same type
				this.ddlConditionType_SelectionChanged(this.ddlConditionType.SelectedItem)
		}		
		else if(!this.listConditions.SelectedIndices.MaxIndex()) ;Item deselected
		{
			this.ddlConditionCategory.Enabled := false
			this.ddlConditionType.Enabled := false
			this.chkNegateCondition.Enabled := false
			this.SubmitCondition()
			this.chkNegateCondition.Checked := false
		}
	}
	ddlConditionCategory_SelectionChanged(Item)
	{
		this.ddlConditionType.DisableNotifications := true
		this.ddlConditionType.Items.Clear()
		IndexToSelect := 1
		for index, Condition in CCondition.Categories[Item.Text]
		{
			this.ddlConditionType.Items.Add(Condition.Type)
			if(this.Condition.Type = Condition.Type)
				IndexToSelect := index
		}
		this.ddlConditionType.DisableNotifications := false
		this.ddlConditionType.SelectedIndex := IndexToSelect
		return
	}
	ddlConditionType_SelectionChanged(Item)
	{
		if(!IsObject(Item)) ;Make sure not to do anything when type DropDownList is cleared
			return
		;Instantiate new condition if this value is set
		if(!this.UseCondition)
		{
			ConditionTemplate := EventSystem.Conditions[Item.Text]
			this.Event.Conditions[this.listConditions.SelectedIndex] := this.Condition := new ConditionTemplate()
		}
		this.UseCondition := false
		
		;Show Condition-specific part of the gui and store hwnds in ConditionGUI		
		this.ShowCondition()
		return
	}
	SubmitCondition()
	{
		Gui, % this.GUINum ": Default"
		Gui, Tab, 2
		this.Condition.GuiSubmit(this.ConditionGUI)
		this.listConditions.Items[this.Event.Conditions.IndexOf(this.Condition)].Text := (this.Condition.Negate ? "NOT " : "" ) this.Condition.DisplayString()
		Gui, Tab
		this.Remove("Condition")
		this.Remove("ConditionGUI")
	}
	ShowCondition()
	{
		this.chkNegateCondition.Checked := this.Condition.Negate
		this.ConditionGUI := {Type: this.Condition.Type}
		this.ConditionGUI.x := 438
		this.ConditionGUI.y := 178
		this.ConditionGUI.GUINum := this.GUINum
		this.ConditionBackup := this.Condition.DeepCopy()
		Gui, % this.GUINum ": Default"
		Gui, Tab, 2
		this.Condition.GuiShow(this.ConditionGUI)
		Gui, Tab		
		this.listConditions.Items[this.Event.Conditions.IndexOf(this.Condition)].Text := (this.Condition.Negate ? "NOT " : "" ) this.Condition.DisplayString()
	}
	chkNegateCondition_CheckedChanged()
	{
		if(this.HasKey("Condition"))
		{
			this.Condition.Negate := this.chkNegateCondition.Checked
			this.listConditions.SelectedItem.Text := (this.Condition.Negate ? "NOT " : "" ) this.Condition.DisplayString()
		}
	}
	btnAddCondition_Click()
	{
		this.Event.Conditions.Insert(Condition := new CWindowActiveCondition())
		this.listConditions.Items.Add("", (Condition.Negate ? "NOT " : "" ) Condition.DisplayString())
		this.UseCondition := true
		this.listConditions.SelectedIndex := this.listConditions.MaxIndex()
	}
	btnDeleteCondition_Click()
	{
		if(this.listConditions.SelectedIndices.MaxIndex() = 1)
		{
			this.Event.Conditions.Remove(this.listConditions.SelectedIndex)
			this.Remove("Condition")
			this.listConditions.Items.Delete(this.listConditions.SelectedIndex)
		}
	}
	
	btnCopyCondition_Click()
	{
		EventSystem.ConditionClipboard := this.Event.Conditions[this.listConditions.SelectedIndex].DeepCopy()
		this.btnPasteCondition.Enabled := true
	}
	btnPasteCondition_Click()
	{
		this.Event.Conditions.Insert(EventSystem.ConditionClipboard.DeepCopy())
		this.listConditions.Items.Add("Select", (EventSystem.ConditionClipboard.Negate ? "NOT " : "") EventSystem.ConditionClipboard.DisplayString())
	}
	btnMoveConditionUp_Click()
	{
		SelectedIndex := this.listConditions.SelectedIndex
		if(!(SelectedIndex > 1))
			return
		Text := this.listConditions.Items[SelectedIndex].Text
		this.Event.Conditions.swap(SelectedIndex, SelectedIndex - 1)
		this.listConditions.DisableNotifications := true
		this.listConditions.Items.Delete(SelectedIndex)
		this.listConditions.Items.Insert(SelectedIndex - 1, "Select", Text)
		this.listConditions.DisableNotifications := false
	}
	btnMoveConditionDown_Click()
	{
		SelectedIndex := this.listConditions.SelectedIndex
		if(SelectedIndex >= this.listConditions.Items.MaxIndex())
			return
		Text := this.listConditions.Items[SelectedIndex].Text
		this.Event.Conditions.swap(SelectedIndex, SelectedIndex + 1)
		this.listConditions.DisableNotifications := true
		this.listConditions.Items.Delete(SelectedIndex)
		this.listConditions.Items.Insert(SelectedIndex + 1, "Select", Text)
		this.listConditions.DisableNotifications := false
	}
	btnConditionHelp_Click()
	{
		static OldTypes := {"Context menu active" : "IsContextMenuActive", "Window is file dialog" : "IsDialog", "Window is dragable" : "IsDragable", "Fullscreen window active" : "IsFullScreen", "Explorer is renaming" : "IsRenaming", "Key is down" : "KeyIsDown", "Mouse over" : "MouseOver", "Mouse over file list" : "MouseOverFileList", "Mouse over tab button" : "MouseOverTabButton", "Mouse over taskbar list" : "MouseOverTaskList", "Window active" : "WindowActive", "Window exists" : "WindowExists"}
		OpenWikiPage("docsConditions" (OldTypes.HasKey(this.Condition.Type) ? OldTypes[this.Condition.Type] : this.Condition.Type))
	}
	
	listActions_SelectionChanged(Item)
	{
		;A new item was selected
		if(Item && this.listActions.SelectedIndices.MaxIndex() = 1 && this.listActions.SelectedIndex != this.listActions.PreviouslySelectedIndex && this.listActions.SelectedItem = item)
		{
			if(this.Action)
				this.SubmitAction()
			this.ddlActionCategory.Enabled := true
			this.ddlActionType.Enabled := true
			this.Action :=  this.Event.Actions[this.listActions.SelectedIndex]
			;Mark that the action stored under this.Action should be used instead of creating a new one of the type set in the type dropdownlist.
			this.UseAction := true
			if(this.Action.Category != this.ddlActionCategory.Text) ;The category of the new action is different from the old one
				this.ddlActionCategory.Text := this.Action.Category
			else if(this.Action.Type != this.ddlActionType.Text) ;The type of the new action is different from the old one
				this.ddlActionType.Text := this.Action.Type
			else ;The action is of the same type
				this.ddlActionType_SelectionChanged(this.ddlActionType.SelectedItem)
		}
		else if(!this.listActions.SelectedIndices.MaxIndex()) ;item deselected
		{
			this.ddlActionCategory.Enabled := false
			this.ddlActionType.Enabled := false
			this.SubmitAction()
		}
	}
	ddlActionCategory_SelectionChanged(Item)
	{
		this.ddlActionType.DisableNotifications := true
		this.ddlActionType.Items.Clear()
		IndexToSelect := 1
		for index, Action in CAction.Categories[Item.Text]
		{
			this.ddlActionType.Items.Add(Action.Type)
			if(this.Action.Type = Action.Type)
				IndexToSelect := index
		}
		this.ddlActionType.DisableNotifications := false
		this.ddlActionType.SelectedIndex := IndexToSelect
		return
	}
	ddlActionType_SelectionChanged(Item)
	{
		if(!IsObject(Item)) ;Make sure not to do anything when type DropDownList is cleared
			return
		;Instantiate new action if this value is set
		if(!this.UseAction)
		{
			this.SubmitAction()
			ActionTemplate := EventSystem.Actions[Item.Text]
			this.Event.Actions[this.listActions.SelectedIndex] := this.Action := new ActionTemplate()
		}
		this.UseAction := false
		;Show Action-specific part of the gui and store hwnds in ActionGUI
		this.ShowAction()
		return
	}
	SubmitAction()
	{
		Gui, % this.GUINum ": Default"
		Gui, Tab, 3
		this.Action.GuiSubmit(this.ActionGUI)
		Gui, Tab
		this.Remove("Action")
		this.Remove("ActionGUI")
	}
	ShowAction()
	{
		this.ActionGUI := {Type: this.Action.Type}
		this.ActionGUI.x := 438
		this.ActionGUI.y := 148
		this.ActionGUI.GUINum := this.GUINum
		this.ActionBackup := this.Action.DeepCopy()
		Gui, % this.GUINum ": Default"
		Gui, Tab, 3
		this.Action.GuiShow(this.ActionGUI)
		Gui, Tab
	}
	btnAddAction_Click()
	{
		this.Event.Actions.Insert(Action := new CRunAction())
		this.listActions.Items.Add("", Action.DisplayString())
		this.UseAction := true
		this.listActions.SelectedIndex := this.listActions.MaxIndex()
	}
	btnDeleteAction_Click()
	{
		if(this.listActions.SelectedIndices.MaxIndex() = 1)
		{
			this.Event.Actions.Remove(this.listActions.SelectedIndex)
			this.Remove("Action")
			this.listActions.Items.Delete(this.listActions.SelectedIndex)
		}
	}
	
	btnCopyAction_Click()
	{
		EventSystem.ActionClipboard := this.Event.Actions[this.listActions.SelectedIndex].DeepCopy()
		this.btnPasteAction.Enabled := true
	}
	btnPasteAction_Click()
	{
		this.Event.Actions.Insert(EventSystem.ActionClipboard.DeepCopy())
		this.listActions.Items.Add("Select", EventSystem.ActionClipboard.DisplayString())
	}
	btnMoveActionUp_Click()
	{
		SelectedIndex := this.listActions.SelectedIndex
		if(!(SelectedIndex > 1))
			return
		Text := this.listActions.Items[SelectedIndex].Text
		this.Event.Actions.swap(SelectedIndex, SelectedIndex - 1)
		this.listActions.DisableNotifications := true		
		this.listActions.Items.Delete(SelectedIndex)
		this.listActions.Items.Insert(SelectedIndex - 1, "Select", Text)
		this.listActions.DisableNotifications := false
	}
	btnMoveActionDown_Click()
	{
		SelectedIndex := this.listActions.SelectedIndex
		if(SelectedIndex >= this.listActions.Items.MaxIndex())
			return
		Text := this.listActions.Items[SelectedIndex].Text
		this.Event.Actions.swap(SelectedIndex, SelectedIndex + 1)
		this.listActions.DisableNotifications := true		
		this.listActions.Items.Delete(SelectedIndex)
		this.listActions.Items.Insert(SelectedIndex + 1, "Select", Text)
		this.listActions.DisableNotifications := false
	}
	btnActionHelp_Click()
	{
		static OldTypes := {"Show Accessor" : "Accessor", "Show Aero Flip" : "ShowAeroFlip", "Check for updates" : "AutoUpdate", "Write to clipboard" : "Clipboard", "Clipboard Manager menu" : "ClipMenu", "Paste clipboard entry" : "ClipPaste", "Control event" : "ControlEvent", "Control timer" : "ControlTimer", "Exit 7plus" : "Exit7plus", "Explorer replace dialog" : "ExplorerReplaceDialog", "Clear Fast Folder" : "FastFoldersClear", "Fast Folders menu" : "FastFoldersMenu", "Open Fast Folder" : "FastFoldersRecall", "Save Fast Folder" : "FastFoldersStore", "Copy file" : "Copy", "Delete file" : "Delete", "Move file" : "Move", "Write to file" : "Write", "Filter list" : "FilterList", "Flashing windows" : "FlashingWindows", "Show Explorer flat view" : "FlatView", "Focus a control" : "FocusControl", "Upload to FTP" : "Upload", "Show Image Converter" : "ImageConverter", "Ask for user input" : "Input", "Invert file selection" : "InvertSelection", "Show Explorer checksum dialog" : "MD5", "Merge Explorer windows" : "MergeTabs", "Mouse click" : "MouseClick", "Close tab under mouse" : "MouseCloseTab", "Drag window with mouse" : "MouseWindowDrag", "Resize window with mouse" : "MouseWindowResize", "Create new file" : "NewFile", "Create new folder" : "NewFolder", "Open folder in new window / tab" : "OpenInNewFolder", "Play a sound" : "PlaySound", "Restart 7plus" : "Restart7plus", "Restore file selection" : "RestoreSelection", "Run a program" : "Run", "Run a program or activate it" : "RunOrActivate", "Take a screenshot" : "Screenshot", "Select files" : "SelectFiles", "Send keyboard input" : "SendKeys", "Send a window message" : "SendMessage", "Set current directory" : "SetDirectory", "Set window title" : "SetWindowTitle", "Shorten a URL" : "ShortenURL", "Show menu" : "ShowMenu", "Show settings" : "ShowSettings", "Shutdown computer" : "Shutdown", "Move Slide Window out of screen" : "SlideWindowOut", "Close taskbar button under mouse" : "TaskButtonClose", "Change desktop wallpaper" : "ToggleWallpaper", "Show a tooltip" : "ToolTip", "Change explorer view mode" : "ViewMode", "Change sound volume" : "Volume", "Activate a window" : "WindowActivate", "Close a window" : "WindowClose", "Hide a window" : "WindowHide", "Move a window" : "WindowMove", "Resize a window" : "WindowResize", "Put window in background" : "WindowSendToBottom", "Show a window" : "WindowShow", "Change window state" : "WindowState"}
		OpenWikiPage("docsActions" (OldTypes.HasKey(this.Action.Type) ? OldTypes[this.Action.Type] : this.Action.Type))
	}
}
GUI_EditEvent(e,GoToLabel="", Parameter="")
{
	static Event, result, SubeventGUI,SubEventBackup, EditEventTab, EditEventTriggerCategory, EditEventTriggerType, EditEventConditions, EditEvent_EditCondition, EditEvent_RemoveCondition, EditEvent_AddCondition, EditEventActions, EditEvent_EditAction, EditEvent_RemoveAction, EditEvent_AddAction, EditEvent_Condition_MoveDown, EditEvent_Condition_MoveUp, EditEvent_Action_MoveUp, EditEvent_Action_MoveDown, EditEvent_Name, EditEvent_Description, EditEvent_DisableAfterUse, EditEvent_DeleteAfterUse, EditEvent_OneInstance, EditEvent_Category, EditEvent_CopyCondition, EditEvent_PasteCondition, EditEvent_CopyAction, EditEvent_PasteAction, ActionClipboard, ConditionClipboard,EditConditionNegate,EditEventConditionsType,EditEventConditionsCategory,EditEventActionsType,EditEventActionsCategory,EditEvent_ComplexEvent
	if(GoToLabel = "")
	{
		;Don't show more than once
		if(Event)
			return ""
		if(!e)
			MsgBox Edit Event: Event not found!
		Event := e
		result := ""
		SubeventGUI := ""
		Gui CSettingsWindow1:+LastFoundExist
		IfWinExist		
			Gui, CSettingsWindow1:+Disabled
		GUIName := 4
		Gui, %GUIName%:Default
		
		;Add the event to the list of events that are currently being edited so it can be found by a subevent label
		EventSystem.CurrentlyEditingEvents[GUIName] := Event
		
		Gui, +LabelEditEvent +OwnerCSettingsWindow1 +ToolWindow +OwnDialogs
		width := 900
		height := 570
		;Gui, 4:Add, Button, ,OK
		x := Width - 174
		y := Height - 34
		Gui, Add, Button, gEditEventOK x%x% y%y% w70 h23, &OK
		x := Width - 94
		Gui, Add, Button, gEditEventCancel x%x% y%y% w80 h23, &Cancel
		x := 14
		y := 14
		w := width - 28
		h := height - 58
		Gui, Add, Tab2, vEditEventTab x%x% y%y% w%w% h%h% gEditEventTab,Trigger||Conditions|Actions|Options
		
		;Fill tabs
		x := 28
		y := 40
		
		Gui, Add, Text, x%x% y%y%, Here you can define how this event gets triggered.
		
		y += 20 + 4
		Gui, Add, Text, x%x% y%y%, Category:
		y += 30
		Gui, Add, Text, x%x% y%y%, Trigger:
		x += 70
		y -= 4
		Gui, Add, DropDownList, vEditEventTriggerType gEditSubeventType x%x% y%y% w300
		y -= 1
		Gui, Add, Button, gSubeventHelp x+10 y%y%, Help
		y -= 29
		Gui, Add, DropDownList, vEditEventTriggerCategory gEditSubeventCategory x%x% y%y% w300
		x := 28
		y += 60
		w := width - 54
		h := height - 158 - 28 
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
		
		Gui, Tab, Conditions
		x := 28
		y := 40
		Gui, Add, Text, x%x% y%y%, The conditions below must be fullfilled to allow this event to execute.
		y := 60
		w := 270
		h := height - 28 - 88
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventConditions gEditSubeventList Grid -LV0x10 NoSortHdr -Multi AltSubmit, Conditions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddCondition gAddSubevent, Add Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveCondition gRemoveSubevent Disabled, Delete Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_CopyCondition gCopySubevent Disabled, Copy Condition
		y += 30		
		Disable := !IsObject(ConditionClipboard)
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_PasteCondition gPasteSubevent Disabled%Disable%, Paste Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Condition_MoveUp gSubevent_MoveUp Disabled, Move Up
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Condition_MoveDown gSubevent_MoveDown Disabled, Move Down
		
		
		x := Width - 472
		y := Height - 530
		Gui, Add, Text, x%x% y%y%, Here you can define the selected condition.
		y += 20
		Gui, Add, Checkbox, x%x% y%y% vEditConditionNegate Disabled, Negate Condition
		y += 10
			
		y += 20 + 4
		Gui, Add, Text, x%x% y%y%, Category:
		y += 30
		Gui, Add, Text, x%x% y%y%, Condition:
		x += 70
		y -= 4
		Gui, Add, DropDownList, vEditEventConditionsType gEditSubEventType x%x% y%y% w300 Disabled
		y -= 1
		Gui, Add, Button, gSubEventHelp x+10 y%y%, Help
		y -= 29
		Gui, Add, DropDownList, vEditEventConditionsCategory gEditSubEventCategory x%x% y%y% w300 Disabled
		x := Width - 472
		y += 60
		w := width - 454
		h := height - 158 - 28 - 20
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
				
		Gui, Tab, Actions
		x := 28
		y := 40
		Gui, Add, Text, x%x% y%y%, These actions will be executed when the event gets triggered.
		y := 60
		w := 270
		h := height - 28 - 88
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventActions gEditSubeventList Grid -LV0x10 NoSortHdr -Multi AltSubmit, Actions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddAction gAddSubevent, Add Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveAction gRemoveSubevent Disabled, Delete Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_CopyAction gCopySubevent Disabled, Copy Action
		y += 30
		Disable := !IsObject(ActionClipboard)
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_PasteAction gPasteSubevent Disabled%Disable%, Paste Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Action_MoveUp gSubevent_MoveUp Disabled, Move Up
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Action_MoveDown gSubevent_MoveDown Disabled, Move Down
		
		x := width - 472
		y := height - 530
		
		Gui, Add, Text, x%x% y%y%, Here you can define what this action does.		
		
		y += 20 + 4
		Gui, Add, Text, x%x% y%y%, Category:
		y += 30
		Gui, Add, Text, x%x% y%y%, Action:
		x += 70
		y -= 4
		Gui, Add, DropDownList, vEditEventActionsType gEditSubEventType x%x% y%y% w300 Disabled
		y -= 1
		Gui, Add, Button, gSubEventHelp x+10 y%y%, Help
		y -= 29
		Gui, Add, DropDownList, vEditEventActionsCategory gEditSubEventCategory x%x% y%y% w300 Disabled
		x := width - 472
		y += 60
		w := width - 454
		
		h := height - 158 - 28
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
				
		Gui, Tab, Options
		x := 28
		y := 52
		Gui, Add, Text, x%x% y%y%, Event Name:
		x += 100
		y -= 4
		w := 300
		Gui, Add, Edit, x%x% y%y% w%w% r1 vEditEvent_Name, % Event.Name
		x := 28
		y += 30
		Gui, Add, Text, x%x% y%y%, Event Description:
		y -= 4
		x += 100
		Gui, Add, Edit, x%x% y%y% w%w% r4 vEditEvent_Description, % Event.Description
		y += 70
		x := 28
		Gui, Add, Text, x%x% y%y%, Event Category:
		x += 100
		y -= 4
		w := 300
		Category := Event.Category
		Categories := "|" ArrayToList(SettingsWindow.Events.Categories, "|") "|"
		StringReplace, Categories, Categories, |%Category%|, |%Category%||
		Categories := strTrimLeft(Categories, "|")
		if(!strEndsWith(Categories, "||"))
			Categories := strTrimRight(Categories, "|")
		Gui, Add, ComboBox, x%x% y%y% w%w% vEditEvent_Category, %Categories%
		x := 28
		y += 30
		w := 200
		DisableAfterUse := Event.DisableAfterUse = 1 ? 1 : 0
		Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DisableAfterUse Checked%DisableAfterUse%, Disable after use
			
		y += 30
		DeleteAfterUse := Event.DeleteAfterUse = 1 ? 1 : 0
		Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DeleteAfterUse Checked%DeleteAfterUse%, Delete after use
		
		y += 30
		OneInstance := Event.OneInstance = 1 ? 1 : 0
		Gui, Add, Checkbox, x%x% y%y% vEditEvent_OneInstance Checked%OneInstance%, Disallow this event from being run in parallel
		
		y += 30
		ComplexEvent := Event.EventComplexityLevel = 1 ? 1 : 0
		Gui, Add, Checkbox, x%x% y%y% vEditEvent_ComplexEvent Checked%ComplexEvent%, Advanced event (hidden from simple view)
		
		GuiControlGet, EditEventTab ;Get it the first time manually
		GoSub FillCategories
		GoSub EditSubeventCategory
		GoSub UpdateSubevent
		Gui, Show, w%width% h%height%, Edit Event
		
		Gui, +LastFound
		WinGet, EditEvent_hWnd,ID
		DetectHiddenWindows, Off
		loop
		{
			sleep 250
			IfWinNotExist ahk_id %EditEvent_hWnd% 
				break
		}
		EventSystem.CurrentlyEditingEvents.Remove(GUIName, "")
		Event := ""
		Gui CSettingsWindow1:+LastFoundExist
		IfWinExist
			Gui, CSettingsWindow1:Default
		return result
	}
	else if(GoToLabel = "EditEventTab")
	{
		GUI_EditEvent("","SaveTab", EditEventTab)
		GuiControlGet,EditEventTab
		SubEventGUI := ""
		if(EditEventTab != "Options")
			GUI_EditEvent("","UpdateSubEvent")
		if(EditEventTab = "Trigger")
			GUI_EditEvent("", "EditSubeventType")
	}
	else if(GoToLabel = "SaveTab")
	{
		if(Parameter = "Trigger") ;EditEventTab holds the name of the previously selected tab
		{
			SetControlDelay, 0
			if(Event.Trigger.GuiSubmit(SubeventGUI))
				Event.Trigger := SubEventBackup ;Restore unmodified version if validation failed
		}
		else if(Parameter = "Conditions" || Parameter = "Actions")
		{
			Gui, ListView, EditEvent%Parameter%
			if(LV_GetCount("Selected") != 1)
				return
			i:=LV_GetNext("")
			if(Parameter = "Conditions")
			{		
				GuiControlGet, EditConditionNegate
				Event[Parameter][i].Negate := EditConditionNegate
			}
			SetControlDelay, 0
			if(Event[Parameter][i].GuiSubmit(SubeventGUI))
				Event[Parameter][i] := SubEventBackup ;Restore unmodified version if validation failed
		}
		SubEventBackup := ""
	}
	else if(GoToLabel = "EditEventOK")
	{
		GUI_EditEvent("","SaveTab", EditEventTab)
		Gui, Submit, NoHide
		Event.Name := EditEvent_Name
		Event.Description := EditEvent_Description
		StringReplace, EditEvent_Category, EditEvent_Category, |,%A_Space%
		if(EditEvent_Category = "Events")
			EditEvent_Category := "Events1"
		Event.Category := EditEvent_Category
		Event.DisableAfterUse := EditEvent_DisableAfterUse
		Event.DeleteAfterUse := EditEvent_DeleteAfterUse
		Event.OneInstance := EditEvent_OneInstance
		Event.EventComplexityLevel := EditEvent_ComplexEvent
		result := Event
		Gui CSettingsWindow1:+LastFoundExist
		IfWinExist		
			Gui, CSettingsWindow1:-Disabled
		Gui, Destroy
		return
	}
	else if(GoToLabel = "EditEventClose")
	{
		Gui CSettingsWindow1:+LastFoundExist
		IfWinExist		
			Gui, CSettingsWindow1:-Disabled
		Gui, Cancel
		Gui, destroy
		Gui CSettingsWindow1:+LastFoundExist
		IfWinExist		
			Gui, CSettingsWindow1:Default
		result := ""
		return
	}
	else if(GoToLabel = "UpdateSubevent") ;Fill ListViews with subevents from event
	{
		if(EditEventTab = "Trigger") ;First call
			Subevents := "Conditions|Actions"
		else if(EditEventTab = "Conditions" || EditEventTab = "Actions")
			Subevents := EditEventTab
		Loop, Parse, Subevents,|
		{
			Gui, ListView, EditEvent%A_LoopField%
			i:=LV_GetNext("")
			LV_Delete()
			Loop % Event[A_LoopField].MaxIndex()
				LV_Add(A_Index = i || (!i && A_Index = 1) ? "Select" : "", (EditEventTab = "Conditions" && Event[A_LoopField][A_Index].Negate ? "NOT " : "") Event[A_LoopField][A_Index].DisplayString())
			GuiControl, focus, EditEvent%A_LoopField%
		}
		return
	}
	else if(GoToLabel = "FillCategories") ;Updates the categories of the currently active tab
	{
		;~ if(EditEventTab = "Actions" || EditEventTab = "Conditions")
		;~ {
			;~ Gui, ListView, EditEvent%EditEventTab%
			;~ i:=LV_GetNext("")
		;~ }
		Subevents := "Trigger|Conditions|Actions"
		
		Loop, Parse, Subevents,|
		{
			if(A_LoopField = "Trigger")
				Categories := CTrigger.Categories
			else if(A_LoopField = "Conditions")
				Categories := CCondition.Categories
			else if(A_LoopField = "Actions")
				Categories := CAction.Categories
			for key, value in Categories
			{
				if(A_LoopField = "Trigger" && key = Event.Trigger.Category)
					GuiControl,,EditEvent%A_LoopField%Category,% key "||"
				else
					GuiControl,,EditEvent%A_LoopField%Category,% key
			}
		}
		return
	}
	else if(GoToLabel = "EditSubeventCategory")
	{
		GuiControlGet, EditEvent%EditEventTab%Category
		outputdebug % "new category: " EditEvent%EditEventTab%Category
		;SubeventGUI contains all control hwnds for the Subevent-specific part of the gui (i.e. Triggers, Conditions, Actions). If it exists, a Subevent is currently visible.
		if(SubeventGUI) ;Refresh the category of the selected subevent
		{
			outputdebug switching to new Subevent category
			if(EditEventTab = "Trigger")
				if(Event.Trigger.Category = EditEventTriggerCategory) ;selecting same item, ignore
					return
			if(EditEventTab = "Conditions" || EditEventTab = "Actions")
			{
				Gui, ListView, EditEvent%EditEventTab%
				i:=LV_GetNext("")
				if(!Parameter && i && Event[EditEventTab][i].Category = EditEvent%EditEventTab%Category) ;selecting same item, ignore
						return
			}
		}
		;Set the subevent to the currently selected one
		SingularName := strTrimRight(EditEventTab, "s")
		if(EditEventTab = "Trigger")
		{
			category := CTrigger.Categories[EditEvent%EditEventTab%Category]
			Subevent := Event.Trigger
		}
		else if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			category := EditEventTab = "Conditions" ? CCondition.Categories[EditEvent%EditEventTab%Category] : CAction.Categories[EditEvent%EditEventTab%Category]
			Gui, ListView, EditEvent%EditEventTab%
			i:=LV_GetNext("")
			Subevent := Event[EditEventTab][i]
		}
		GuiControl,,EditEvent%EditEventTab%Type,|
		found := false
		Loop % category.MaxIndex() ;Find current type of subevent, select it and trigger the selectionchange label
		{
			type := category[A_Index].Type
			if(Subevent.type = type)
			{
				GuiControl,,EditEvent%EditEventTab%Type,%type%||
				found := true
			}
			else
				GuiControl,,EditEvent%EditEventTab%Type,%type%
		}
		outputdebug % "found " found " type " EditEvent%EditEventTab%Type
		if(!found)
			GuiControl, Choose, EditEvent%EditEventTab%Type, 1
		GUI_EditEvent("", "EditSubeventType", Parameter)
		return
	}
	else if(GoToLabel = "EditSubeventType")
	{
		GuiControlGet, type,,EditEvent%EditEventTab%Type
		GuiControlGet, category,,EditEvent%EditEventTab%Category
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%
			i:=LV_GetNext("")
		}
		;At startup, SubeventGUI isn't set, and so the original Subevent doesn't get overriden
		;If it is set, the code below treats a change of type by destroying the previous window elements and creates a new Subevent
		if(SubeventGUI)
		{	
			Gui, Tab, %EditEventTab%
			if(EditEventTab = "Trigger")
			{
				;SubeventGUI contains all control hwnds for the trigger-specific part of the gui
				if(Event.Trigger.Type = type && Event.Trigger.Category = category) ;selecting same item, ignore
					return
				SetControlDelay, 0
				Event.Trigger.GuiSubmit(SubeventGUI)
				TriggerTemplate := EventSystem.Triggers[Type]
				Event.Trigger := new TriggerTemplate()
			}
			else if(EditEventTab = "Conditions" || EditEventTab = "Actions")
			{
				;SubeventGUI contains all control hwnds for the trigger-specific part of the gui
				if(i && !Parameter)
				{
					if(!Parameter && Event[EditEventTab][i].Type = type && Event[EditEventTab][i].Category = category) ;selecting same item, ignore
						return
					SetControlDelay, 0
					Event[EditEventTab][i].GuiSubmit(SubeventGUI)
					SubEventTemplate := EventSystem[EditEventTab = "Conditions" ? "Conditions" : "Actions"][type]
					Event[EditEventTab][i] := new SubEventTemplate()
				}
			}
		}
		;Show subevent-specific part of the gui and store hwnds in TriggerGUI
		SubeventGUI := object("Type", type)
		SubeventGUI.x := 38 + (EditEventTab != "Trigger" ? 400 : 0)
		SubeventGUI.y := 148 + (EditEventTab = "Conditions" ? 30 : 0)
		SubeventGUI.w := width - 74 - (EditEventTab != "Trigger" ? 400 : 0)
		SubeventGUI.h := height - 168 - 28
		SubeventGUI.GUINum := 4
		Gui, Tab, %EditEventTab%
		if(EditEventTab = "Trigger")
		{			
			SubEventBackup := Event.Trigger.DeepCopy()			
			SetControlDelay, 0
			MsgBox % "Trigger: " SubEventGUI.x "/" SubEventGUI.y "/" SubEventGUI.width "/" SubEventGUI.height
			Event.Trigger.GuiShow(SubeventGUI)
		}
		else if(i && (EditEventTab = "Conditions" || EditEventTab = "Actions"))
		{
			SubEventBackup := Event[EditEventTab][i].DeepCopy()
			SetControlDelay, 0
			MsgBox % EditEventTab ": " SubEventGUI.x "/" SubEventGUI.y "/" SubEventGUI.width "/" SubEventGUI.height
			Event[EditEventTab][i].GuiShow(SubeventGUI)
			LV_Modify(i, "", (EditEventTab = "Conditions" && Event[EditEventTab][i].Negate ? "NOT " : "") Event[EditEventTab][i].DisplayString())
		}
		return
	}
	else if(GoToLabel = "EditSubeventList")
	{
		Critical
		ListEvent := ErrorLevel
		Gui, ListView, EditEvent%EditEventTab%
		SingularName := strTrimRight(EditEventTab, "s")
		if(A_GuiEvent="I" && InStr(ListEvent, "S", true))
		{
			GuiControl, enable, EditEvent_Edit%SingularName%
			GuiControl, enable, EditEvent_Remove%SingularName%
			GuiControl, enable, EditEvent_Copy%SingularName%
			i:=LV_GetNext("")
			if(i>1)
				GuiControl, enable, EditEvent_%SingularName%_MoveUp
			else
				GuiControl, disable, EditEvent_%SingularName%_MoveUp
			if(i<LV_GetCount())
				GuiControl, enable, EditEvent_%SingularName%_MoveDown
			else
				GuiControl, disable, EditEvent_%SingularName%_MoveDown
			GuiControl, enable, EditEvent%EditEventTab%Category
			GuiControl, enable, EditEvent%EditEventTab%Type
			if(IsObject(Event[EditEventTab][A_EventInfo]))
				GuiControl, ChooseString, EditEvent%EditEventTab%Category, % Event[EditEventTab][A_EventInfo].Category
			if(EditEventTab = "Conditions")
				GuiControl, enable, EditConditionNegate
			if(EditEventTab = "Conditions")
				GuiControl, , EditConditionNegate, % Event[EditEventTab][A_EventInfo].Negate ? 1 : 0
			GUI_EditEvent("", "EditSubEventCategory", 1)
		}
		else if(A_GuiEvent="I" && InStr(ListEvent, "s", true))
		{
			if(LV_GetCount("Selected") = 0)
			{
				GuiControl, disable, EditEvent_Edit%SingularName%
				GuiControl, disable, EditEvent_Remove%SingularName%
				GuiControl, disable, EditEvent_Copy%SingularName%
				GuiControl, disable, EditEvent_%SingularName%_MoveDown
				GuiControl, disable, EditEvent_%SingularName%_MoveUp			
				GuiControl, disable, EditEvent%EditEventTab%Category
				GuiControl, disable, EditEvent%EditEventTab%Type
				if(EditEventTab = "Conditions")
					GuiControl, disable, EditConditionNegate
			}
			if(EditEventTab = "Conditions")
			{
				GuiControlGet, EditConditionNegate
				Event[EditEventTab][A_EventInfo].Negate := EditConditionNegate
			}
			SetControlDelay, 0
			if(Event[EditEventTab][A_EventInfo].GuiSubmit(SubeventGUI)) ;Restore unmodified version if validation failed
				Event[EditEventTab][A_EventInfo] := SubEventBackup
			
			SubEventBackup := ""
			SubEventGUI := ""
			LV_Modify(A_EventInfo, "", (EditEventTab = "Conditions" && Event[EditEventTab][A_EventInfo].Negate ? "NOT " : "") Event[EditEventTab][A_EventInfo].DisplayString())
		}
		Critical, Off
		return
	}
	else if(GoToLabel = "RemoveSubEvent")
	{
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%
			i:=LV_GetNext("")
			Event[EditEventTab].Delete(i)
			LV_Delete(i)
		}
		return
	}
	else if(GoToLabel = "AddSubevent")
	{
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%
			EventTemplate := EventSystem[EditEventTab = "Conditions" ? "Conditions" : "Actions"][EditEventTab = "Conditions" ? "If" : "Message"]
			Subevent := new EventTemplate()
			Event[EditEventTab].Insert(Subevent)
			LV_Add("Select", Subevent.DisplayString())
		}
		return
	}
	else if(GoToLabel = "CopySubevent")
	{
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%
			i:=LV_GetNext("")
			SingularName := strTrimRight(EditEventTab, "s")
			%SingularName%Clipboard := Event[EditEventTab][i].DeepCopy()
			GuiControl, enable, EditEvent_Paste%SingularName%
		}
		return
	}
	else if(GoToLabel = "PasteSubevent")
	{
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%("")
			SingularName := strTrimRight(EditEventTab, "s")
			Event[EditEventTab].Insert(%SingularName%Clipboard.DeepCopy())
			LV_Add("Select", (EditEventTab = "Conditions" && %SingularName%Clipboard.Negate ? "NOT " : "") %SingularName%Clipboard.DisplayString())
		}
		return
	}
	else if(GoToLabel = "MoveSubevent")
	{
		if(EditEventTab = "Conditions" || EditEventTab = "Actions")
		{
			Gui, ListView, EditEvent%EditEventTab%
			i:=LV_GetNext("")
			Event[EditEventTab].swap(i,i+Parameter)
			LV_Modify(i+Parameter,"Select")
			GUI_EditEvent("","UpdateSubevent") ;Refresh listview
		}
	}
	else if(GoToLabel = "SubEventHelp")
	{
		GuiControlGet, type,,EditEvent%EditEventTab%Type
		if(EditEventTab = "Trigger")
			OpenWikiPage("docsTriggers" type)
		else
			OpenWikiPage("docs" EditEventTab type)
		return
	}
}
SubEventHelp:
GUI_EditEvent("","SubEventHelp")
return
EditEventOK:
GUI_EditEvent("","EditEventOK")
return
EditEventClose:
EditEventEscape:
EditEventCancel:
GUI_EditEvent("","EditEventClose")
return
EditEventTab:
GUI_EditEvent("", "EditEventTab")
return
UpdateSubevent:
GUI_EditEvent("","UpdateSubevent")
return
FillCategories:
GUI_EditEvent("","FillCategories")
return
EditSubeventCategory:
GUI_EditEvent("","EditSubeventCategory")
return
EditSubeventType:
GUI_EditEvent("","EditSubeventType")
return
EditSubeventList:
GUI_EditEvent("","EditSubeventList")
return
RemoveSubevent:
GUI_EditEvent("","RemoveSubevent")
return
CopySubevent:
GUI_EditEvent("","CopySubevent")
return
PasteSubevent:
GUI_EditEvent("","PasteSubevent")
return
AddSubevent:
GUI_EditEvent("","AddSubevent")
return
Subevent_MoveUp:
GUI_EditEvent("","MoveSubevent", -1)
return
Subevent_MoveDown:
GUI_EditEvent("","MoveSubevent", 1)
return