;Gets the event which is currently being edited by the GUI Name of the editor window
GetCurrentSubEvent()
{
	Event := EventSystem.CurrentlyEditingEvents[A_GUI]
	GuiControlGet,CurrentTab,,SysTabControl321
	if(CurrentTab = "Trigger")
		return Event.Trigger
	else if(CurrentTab = "Conditions")
	{
		Gui, ListView, SysListView321
		return Event.Conditions[LV_GetNext()]
	}
	else if(CurrentTab = "Actions")
	{
		Gui, ListView, SysListView322
		return Event.Actions[LV_GetNext()]
	}
	return 
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
			Event.Trigger.GuiShow(SubeventGUI)
		}
		else if(i && (EditEventTab = "Conditions" || EditEventTab = "Actions"))
		{
			SubEventBackup := Event[EditEventTab][i].DeepCopy()
			SetControlDelay, 0
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
			; }
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