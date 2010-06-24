GUI_EditEvent(e,GoToLabel="")
{
	static Event, result, TriggerGUI, EditEventTab, EditEventTriggerCategory, EditEventTriggerType, EditEventConditions, EditEvent_EditCondition, EditEvent_RemoveCondition, EditEvent_AddCondition, EditEventActions, EditEvent_EditAction, EditEvent_RemoveAction, EditEvent_AddAction
	global Trigger_Categories
	if(GoToLabel = "")
	{
		Event := e
		result := ""
		TriggerGUI := ""
		Gui, 1:+Disabled
		Gui, 4:Default
		Gui, +LabelEditEvent +Owner1 +ToolWindow
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
		y -= 30
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
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventConditions gEditEventConditions Grid -LV0x10 -Multi AltSubmit, Conditions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddCondition gEditEvent_AddCondition, Add Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveCondition gEditEvent_RemoveCondition, Delete Condition
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_EditCondition gEditEvent_EditCondition, Edit Condition
		
		
		Gui, Tab, Actions
		x := 28
		y := 48
		Gui, Add, Text, x%x1% y%yIt%, Here you can define a list of actions.
		y := 60
		w := width -54 - 100
		h := height - 28 - 88
		Gui, Add, ListView, x%x% y%y% w%w% h%h% vEditEventActions gEditEventActions Grid -LV0x10 -Multi AltSubmit, Actions
		
		x += w + 10
		w := 90
		h := 23
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_AddAction gEditEvent_AddAction, Add Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_RemoveAction gEditEvent_RemoveAction, Delete Action
		y += 30
		Gui, Add, Button, x%x% y%y% w%w% h%h% vEditEvent_EditAction gEditEvent_EditAction, Edit Action
		
		gosub FillCategories
		gosub UpdateConditions
		gosub UpdateActions
		/*
		OnMessage(0x100, "WM_KEYDOWN")
		Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsList_Add gGUI_EventsList_Add, Add Event
		yIt += textboxstep
		Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsList_Remove gGUI_EventsList_Remove, Delete Event
		yIt += textboxstep
		Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsLisit_Edit gGUI_EventsList_Edit, Edit Event
		yIt += 208 - textboxstep -4
		Gui, 1:Add, Button, x%x2% y%yIt% w80 gGUI_EventsLisit_Help, Help
		yIt += textboxstep + 4
		y := yIt + TextBoxTextOffset
		*/
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
		
		return result	
	}
	else if(GoToLabel = "EditEventOK")
	{		
		Event.Trigger.GuiSubmit(TriggerGUI)
		outputdebug(Event.Trigger.WindowMatchType)
		Gui, Submit, NoHide
		result := Event
		Gui, 1:-Disabled
		Gui, Destroy
		return
	}
	else if(GoToLabel = "EditEventClose")
	{
		Gui, 1:-Disabled
		Gui, Cancel
		Gui, destroy
		Gui, 1:Default
		result := ""
		return
	}
	else if(GoToLabel = "UpdateConditions")
	{
		Gui, ListView, EditEventConditions
		LV_Delete()
		Loop % Event.Conditions.len()
		{
			LV_Add(A_Index = 1 ? "Select" : "", Event.Conditions[A_Index].DisplayString())
		}
		return
	}
	else if(GoToLabel = "UpdateActions")
	{		
		Gui, ListView, EditEventActions
		LV_Delete()
		Loop % Event.Actions.len()
		{
			LV_Add(A_Index = 1 ? "Select" : "", Event.Actions[A_Index].DisplayString())
		}
		return
	}
	else if(GoToLabel = "FillCategories")
	{
		outputdebug("Fill categories, selected event: " Event.Trigger.type)
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
		outputdebug Category changed to %EditEventTriggerCategory%
		;TriggerGUI contains all control hwnds for the trigger-specific part of the gui
		if(TriggerGUI)
		{
			if(TriggerGUI.Type = EditEventTriggerCategory) ;selecting same item, ignore
				return
			Gui, Tab, Trigger
			Event.Trigger.GuiSubmit(TriggerGUI)
		}
		category := Trigger_Categories[EditEventTriggerCategory]
		GuiControl,,EditEventTriggerType,|
		found := false
		Loop % category.len()
		{
			type := category[A_Index]
			outputdebug loop %type%
			if(Event.Trigger.type = type)
			{
				GuiControl,,EditEventTriggerType,%type%||
				found := true
				outputdebug found trigger
			}
			else
				GuiControl,,EditEventTriggerType,%type%
			
		}
		if(!found)
		{
			outputdebug didn't find trigger
			;Select first event, and create a trigger of that type (latter should maybe be done in selection label EditEventTriggerType)
			GuiControl, Choose, EditEventTriggerType, 1
		}	
		gosub EditEventTriggerType	
		return
	}
	else if(GoToLabel = "EditEventTriggerType")
	{
		GuiControlGet, type,,EditEventTriggerType
		;At startup, TriggerGUI isn't set, and so the original trigger doesn't get overriden
		if(TriggerGUI)
			Event.Trigger := EventSystem_CreateSubEvent("Trigger",type)
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
	else if(GoToLabel = "EditEvent_EditCondition")
	{
		return
	}
	else if(GoToLabel = "EditEvent_RemoveCondition")
	{
		return
	}
	else if(GoToLabel = "EditEvent_AddCondition")
	{
		return
	}
	else if(GoToLabel = "EditEventActions")
	{
		return
	}
	else if(GoToLabel = "EditEvent_EditAction")
	{
		return
	}
	else if(GoToLabel = "EditEvent_RemoveAction")
	{
		return
	}
	else if(GoToLabel = "EditEvent_AddAction")
	{
		return
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