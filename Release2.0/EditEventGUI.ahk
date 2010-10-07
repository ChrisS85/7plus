GUI_EditEvent(e,GoToLabel="")
{
	static Event, result, TriggerGUI, EditEventTab, EditEventTriggerCategory, EditEventTriggerType, EditEventConditions, EditEvent_EditCondition, EditEvent_RemoveCondition, EditEvent_AddCondition, EditEventActions, EditEvent_EditAction, EditEvent_RemoveAction, EditEvent_AddAction, EditEvent_Condition_MoveDown, EditEvent_Condition_MoveUp, EditEvent_Action_MoveUp, EditEvent_Action_MoveDown, EditEvent_Name, EditEvent_DisableAfterUse, EditEvent_DeleteAfterUse, EditEvent_OneInstance, EditEvent_Category
	global Trigger_Categories, Settings_Events
	if(GoToLabel = "")
	{
		;Don't show more than once
		if(Event)
			return ""
		Event := e
		result := ""
		TriggerGUI := ""
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:+Disabled
		Gui, 4:Default
		Gui, +LabelEditEvent +Owner1 +ToolWindow +OwnDialogs
		width := 500
		height := 500
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
		Gui, Add, Tab2, vEditEventTab x%x% y%y% w%w% h%h% AltSubmit,Trigger||Conditions|Actions|Options
		
		;Fill tabs
		x := 28
		y := 48
		
		Gui, Add, Text, x%x% y%y%, Here you can define how this event gets triggered.
		
		y += 20 + 4
		Gui, Add, Text, x%x% y%y%, Category:
		y += 30
		Gui, Add, Text, x%x% y%y%, Trigger:
		x += 70
		y -= 4
		Gui, Add, DropDownList, vEditEventTriggerType gEditEventTriggerType x%x% y%y% w300
		y -= 1
		Gui, Add, Button, gTriggerHelp x+10 y%y%, Help
		y -= 29
		Gui, Add, DropDownList, vEditEventTriggerCategory gEditEventTriggerCategory x%x% y%y% w300
		x := 28
		y += 60
		w := width - 54
		h := height - 158 - 28 
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
		
		Gui, Tab, Conditions
		x := 28
		y := 48
		Gui, Add, Text, x%x1% y%yIt%, Here you can add additional conditions for the actions.
		y := 60
		w := width -54 - 100
		h := height - 28 - 88
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventConditions gEditEventConditions Grid -LV0x10 NoSortHdr -Multi AltSubmit, Conditions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddCondition gEditEvent_AddCondition, Add Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveCondition gEditEvent_RemoveCondition, Delete Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_EditCondition gEditEvent_EditCondition, Edit Condition
		y += 30*2
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Condition_MoveUp gEditEvent_Condition_MoveUp, Move Up
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Condition_MoveDown gEditEvent_Condition_MoveDown, Move Down
		
		
		Gui, Tab, Actions
		x := 28
		y := 48
		Gui, Add, Text, x%x1% y%yIt%, Here you can define a list of actions.
		y := 60
		w := width -54 - 100
		h := height - 28 - 88
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventActions gEditEventActions Grid -LV0x10 NoSortHdr -Multi AltSubmit, Actions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddAction gEditEvent_AddAction, Add Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveAction gEditEvent_RemoveAction, Delete Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_EditAction gEditEvent_EditAction, Edit Action
		y += 30*2
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Action_MoveUp gEditEvent_Action_MoveUp, Move Up
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% vEditEvent_Action_MoveDown gEditEvent_Action_MoveDown, Move Down
		
		Gui, Tab, Options
		x := 28
		y := 52
		Gui, Add, Text, x%x% y%y%, Event Name:
		x += 80
		y -= 4
		w := 300
		name := Event.Name
		Gui, Add, Edit, x%x% y%y% w%w% r1 vEditEvent_Name, %name%
		x := 28
		y += 30
		Gui, Add, Text, x%x% y%y%, Event Category:
		x += 80
		y -= 4
		w := 300
		Category := Event.Category
		outputdebug category %category%
		Categories := "|" ArrayToList(Settings_Events.Categories, "|") "|"
		outputdebug Categories %Categories%
		StringReplace, Categories, Categories, |%Category%|, |%Category%||
		Categories := strTrimLeft(Categories, "|")
		if(!strEndsWith(Categories, "||"))
			Categories := strTrimRight(Categories, "|")
		outputdebug Categories %Categories%
		Gui, Add, ComboBox, x%x% y%y% w%w% vEditEvent_Category, %Categories%
		x := 28
		y += 30
		w := 200
		if(Event.DisableAfterUse)
			Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DisableAfterUse Checked, Disable after use
		else
			Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DisableAfterUse, Disable after use
			
		y += 30
		if(Event.DeleteAfterUse)
			Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DeleteAfterUse Checked, Delete after use
		else
			Gui, Add, Checkbox, x%x% y%y% w%w% vEditEvent_DeleteAfterUse, Delete after use
		
		y += 30
		if(Event.OneInstance)
			Gui, Add, Checkbox, x%x% y%y% vEditEvent_OneInstance Checked, Disallow this event from being run in parallel
		else
			Gui, Add, Checkbox, x%x% y%y% vEditEvent_OneInstance, Disallow this event from being run in parallel
			
		gosub FillCategories
		gosub UpdateConditions
		gosub UpdateActions
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
		Event := ""
		Gui 1:+LastFoundExist
		IfWinExist
			Gui, 1:Default
		return result	
	}
	else if(GoToLabel = "EditEventOK")
	{
		Event.Trigger.GuiSubmit(TriggerGUI)
		Gui, Submit, NoHide
		Event.Name := EditEvent_Name
		StringReplace, EditEvent_Category, EditEvent_Category, |,%A_Space%
		if(EditEvent_Category = "Events")
			EditEvent_Category := "Events1"
		Event.Category := EditEvent_Category
		Event.DisableAfterUse := EditEvent_DisableAfterUse
		Event.DeleteAfterUse := EditEvent_DeleteAfterUse
		Event.OneInstance := EditEvent_OneInstance
		result := Event
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:-Disabled
		Gui, Destroy
		return
	}
	else if(GoToLabel = "EditEventClose")
	{
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:-Disabled
		Gui, Cancel
		Gui, destroy
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:Default
		result := ""
		return
	}
	else if(GoToLabel = "UpdateConditions")
	{
		Gui, ListView, EditEventConditions
		i:=LV_GetNext("")
		LV_Delete()
		Loop % Event.Conditions.len()
		{
			LV_Add(A_Index = i ? "Select" : "", (Event.Conditions[A_Index].Negate ? "NOT " : "") Event.Conditions[A_Index].DisplayString())
		}
		GuiControl, focus, EditEventConditions
		return
	}
	else if(GoToLabel = "UpdateActions")
	{		
		Gui, ListView, EditEventActions
		i:=LV_GetNext("")
		LV_Delete()
		Loop % Event.Actions.len()
		{
			LV_Add(A_Index = i ? "Select" : "", Event.Actions[A_Index].DisplayString())
		}
		GuiControl, focus, EditEventActions
		return
	}
	else if(GoToLabel = "FillCategories")
	{
		enum := Trigger_Categories._newEnum()
		while enum[key,value]
		{
			if(key = Event.Trigger.Category)
				GuiControl,,EditEventTriggerCategory,%key%||
			else
				GuiControl,,EditEventTriggerCategory,%key%
		}
		gosub EditEventTriggerCategory
		return
	}
	else if(GoToLabel = "EditEventTriggerCategory")
	{
		GuiControlGet, EditEventTriggerCategory
		;TriggerGUI contains all control hwnds for the trigger-specific part of the gui
		if(TriggerGUI)
		{
			if(Event.Trigger.Category = EditEventTriggerCategory) ;selecting same item, ignore
				return
		}
		category := Trigger_Categories[EditEventTriggerCategory]
		GuiControl,,EditEventTriggerType,|
		found := false
		Loop % category.len()
		{
			type := category[A_Index]
			if(Event.Trigger.type = type)
			{
				GuiControl,,EditEventTriggerType,%type%||
				found := true
			}
			else
				GuiControl,,EditEventTriggerType,%type%			
		}
		if(!found)
		{
			;Select first event, and create a trigger of that type (latter should maybe be done in selection label EditEventTriggerType)
			GuiControl, Choose, EditEventTriggerType, 1
		}	
		gosub EditEventTriggerType	
		return
	}
	else if(GoToLabel = "EditEventTriggerType")
	{
		GuiControlGet, type,,EditEventTriggerType
		GuiControlGet, category,,EditEventTriggerCategory
		;At startup, TriggerGUI isn't set, and so the original trigger doesn't get overriden
		if(TriggerGUI)
		{
			;TriggerGUI contains all control hwnds for the trigger-specific part of the gui
			if(Event.Trigger.Type = type && Event.Trigger.Category = category) ;selecting same item, ignore
				return
			t := Event.Trigger.Type
			c := Event.Trigger.Category
			Gui, Tab, Trigger
			Event.Trigger.GuiSubmit(TriggerGUI)
			Event.Trigger := EventSystem_CreateSubEvent("Trigger",type)
		}
		;Show trigger-specific part of the gui and store hwnds in TriggerGUI
		TriggerGUI := object("Type", type)
		TriggerGUI.x := 38
		TriggerGUI.y := 148
		TriggerGUI.w := width - 74
		TriggerGUI.h := height - 168 - 28 
		Gui, Tab, Trigger
		Event.Trigger.GuiShow(TriggerGUI)
		return
	}
	else if(GoToLabel = "EditEventConditions")
	{
		Gui, ListView, EditEventConditions
		if(A_GuiEvent="I" && InStr(ErrorLevel, "S", true))
		{
			GuiControl, enable, EditEvent_EditCondition
			GuiControl, enable, EditEvent_RemoveCondition
			i:=LV_GetNext("")
			if(i>1)
				GuiControl, enable, EditEvent_Condition_MoveUp
			else
				GuiControl, disable, EditEvent_Condition_MoveUp
			if(i<LV_GetCount())
				GuiControl, enable, EditEvent_Condition_MoveDown
			else
				GuiControl, disable, EditEvent_Condition_MoveDown
		}
		else if(A_GuiEvent="I" && InStr(ErrorLevel, "s", true))
		{
			GuiControl, disable, EditEvent_EditCondition
			GuiControl, disable, EditEvent_RemoveCondition
			GuiControl, disable, EditEvent_Condition_MoveDown
			GuiControl, disable, EditEvent_Condition_MoveUp
		}
		else if(A_GuiEvent="DoubleClick")
			GUI_EditEvent("","EditEvent_EditCondition")
		return
	}
	else if(GoToLabel = "EditEvent_EditCondition")
	{
		Gui, ListView, EditEvent_EditCondition
		if(LV_GetCount("Selected") != 1)
			return
		i:=LV_GetNext("")
		Critical, Off
		condition:=GUI_EditSubEvent(Event.Conditions[i].DeepCopy(),0)
		if(condition)
		{
			condition.tmpTemporary := false
			Event.Conditions[i] := condition ;overwrite edited condition
			GUI_EditEvent("","UpdateConditions") ;Refresh listview
		}
		else if(Event.Conditions[i].tmpTemporary)
			GUI_EditEvent("","EditEvent_RemoveCondition")
		return
	}
	else if(GoToLabel = "EditEvent_RemoveCondition")
	{
		Gui, ListView, EditEvent_EditCondition
		i:=LV_GetNext("")
		Event.Conditions.Delete(i)
		LV_Delete(i)
		return
	}
	else if(GoToLabel = "EditEvent_AddCondition")
	{
		Gui, ListView, EditEvent_EditCondition
		Condition := EventSystem_CreateSubEvent("Condition","If")
		Condition.tmpTemporary := true
		Event.Conditions.append(Condition)
		LV_Add("Select", Condition.DisplayString())
		GUI_EditEvent("","EditEvent_EditCondition")
		return
	}
	else if(GoToLabel = "EditEvent_Condition_MoveDown")
	{
		Gui, ListView, EditEvent_EditCondition
		i:=LV_GetNext("")
		Event.Conditions.swap(i,i+1)
		LV_Modify(i+1,"Select")
		GUI_EditEvent("","UpdateConditions") ;Refresh listview
	}
	else if(GoToLabel = "EditEvent_Condition_MoveUp")
	{
		Gui, ListView, EditEvent_EditCondition
		i:=LV_GetNext("")
		Event.Conditions.swap(i,i-1)
		LV_Modify(i-1,"Select")
		GUI_EditEvent("","UpdateConditions") ;Refresh listview
	}
	else if(GoToLabel = "EditEventActions")
	{
		Gui, ListView, EditEventActions
		if(A_GuiEvent="I" && InStr(ErrorLevel, "S", true))
		{
			GuiControl, enable, EditEvent_EditAction
			GuiControl, enable, EditEvent_RemoveAction		
			i:=LV_GetNext("")
			if(i>1)
				GuiControl, enable, EditEvent_Action_MoveUp
			else
				GuiControl, disable, EditEvent_Action_MoveUp
			if(i<LV_GetCount())
				GuiControl, enable, EditEvent_Action_MoveDown
			else
				GuiControl, disable, EditEvent_Action_MoveDown
		}
		else if(A_GuiEvent="I" && InStr(ErrorLevel, "s", true))
		{
			GuiControl, disable, EditEvent_EditAction
			GuiControl, disable, EditEvent_RemoveAction
			GuiControl, disable, EditEvent_Action_MoveDown
			GuiControl, disable, EditEvent_Action_MoveUp
		}
		else if(A_GuiEvent="DoubleClick")
			GUI_EditEvent("","EditEvent_EditAction")
		return
	}
	else if(GoToLabel = "EditEvent_EditAction")
	{
		Gui, ListView, EditEvent_EditAction
		if(LV_GetCount("Selected") != 1)
			return
		i:=LV_GetNext("")
		Critical, Off
		action:=GUI_EditSubEvent(Event.Actions[i].DeepCopy(),1)
		if(action)
		{
			outputdebug("Store " Event.Actions[i].WaitForFinish)
			action.tmpTemporary := false
			Event.Actions[i] := action ;overwrite edited action
			GUI_EditEvent("","UpdateActions") ;Refresh listview
		}
		else if(Event.Actions[i].tmpTemporary)
			GUI_EditEvent("","EditEvent_RemoveAction") 
		return
	}
	else if(GoToLabel = "EditEvent_RemoveAction")
	{
		Gui, ListView, EditEvent_EditAction
		i:=LV_GetNext("")
		Event.Actions.Delete(i)
		LV_Delete(i)
		return
	}
	else if(GoToLabel = "EditEvent_AddAction")
	{
		Gui, ListView, EditEvent_EditAction
		Action := EventSystem_CreateSubEvent("Action","Run")
		Action.tmpTemporary := true
		Event.Actions.append(Action)
		LV_Add("Select", Action.DisplayString())
		GUI_EditEvent("","EditEvent_EditAction")
		return
	}
	else if(GoToLabel = "EditEvent_Action_MoveDown")
	{
		Gui, ListView, EditEvent_EditAction
		i:=LV_GetNext("")
		Event.Actions.swap(i,i+1)
		LV_Modify(i+1,"Select")
		GUI_EditEvent("","UpdateActions") ;Refresh listview
	}
	else if(GoToLabel = "EditEvent_Action_MoveUp")
	{
		Gui, ListView, EditEvent_EditAction
		i:=LV_GetNext("")
		Event.Actions.swap(i,i-1)
		LV_Modify(i-1,"Select")
		GUI_EditEvent("","UpdateActions") ;Refresh listview
	}
	else if(GoToLabel = "TriggerHelp")
	{
		GuiControlGet, type,,EditEventTriggerType
		Run http://code.google.com/p/7plus/wiki/docsTriggers%type%
	}
} 
EditEventOK:
GUI_EditEvent("","EditEventOK")
return

EditEventClose:
EditEventEscape:
EditEventCancel:
GUI_EditEvent("","EditEventClose")
return

UpdateConditions:
GUI_EditEvent("","UpdateConditions")
return

UpdateActions:	
GUI_EditEvent("","UpdateActions")
return

FillCategories:
GUI_EditEvent("","FillCategories")
return

TriggerHelp:
GUI_EditEvent("","TriggerHelp")
;Called when a trigger category gets selected
EditEventTriggerCategory:
GUI_EditEvent("","EditEventTriggerCategory")
return

EditEventTriggerType:
GUI_EditEvent("","EditEventTriggerType")
return

EditEventConditions:
GUI_EditEvent("","EditEventConditions")
return
EditEvent_EditCondition:
GUI_EditEvent("","EditEvent_EditCondition")
return
EditEvent_RemoveCondition:
GUI_EditEvent("","EditEvent_RemoveCondition")
return
EditEvent_AddCondition:
GUI_EditEvent("","EditEvent_AddCondition")
return
EditEvent_Condition_MoveUp:
GUI_EditEvent("","EditEvent_Condition_MoveUp")
return
EditEvent_Condition_MoveDown:
GUI_EditEvent("","EditEvent_Condition_MoveDown")
return
EditEventActions:
GUI_EditEvent("","EditEventActions")
return
EditEvent_EditAction:
GUI_EditEvent("","EditEvent_EditAction")
return
EditEvent_RemoveAction:
GUI_EditEvent("","EditEvent_RemoveAction")
return
EditEvent_AddAction:
GUI_EditEvent("","EditEvent_AddAction")
return
EditEvent_Action_MoveUp:
GUI_EditEvent("","EditEvent_Action_MoveUp")
return
EditEvent_Action_MoveDown:
GUI_EditEvent("","EditEvent_Action_MoveDown")
return