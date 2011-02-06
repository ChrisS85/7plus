GUI_EditSubEvent(se, ia=0, GoToLabel="")
{
	static SubEvent, IsAction, result, SubEventGUI, EditSubEventCategory, EditSubEventType, EditSubEventNegate
	global Condition_Categories, Action_Categories
	if(GoToLabel = "")
	{
		SubEvent := se
		IsAction := ia
		result := ""
		SubEventGUI := ""
		Gui, 4:+Disabled
		Gui, 5:Default
		Gui, +LabelEditSubEvent +Owner1 +ToolWindow
		width := 500
		height := 500
		x := Width - 184
		y := Height - 34
		Gui, Add, Button, gEditSubEventOK x%x% y%y% w70 h23, &OK
		x := Width - 104
		Gui, Add, Button, gEditSubEventCancel x%x% y%y% w80 h23, &Cancel
		
		x := 28
		y := 48
		
		if(IsAction)
			Gui, Add, Text, x%x% y%y%, Here you can define what this action does.
		else
		{
			Gui, Add, Text, x%x% y%y%, Here you can define the condition.
			y += 20
			if(SubEvent.Negate)
				Gui, Add, Checkbox, x%x% y%y% Checked vEditSubEventNegate, Negate Condition
			else
				Gui, Add, Checkbox, x%x% y%y% vEditSubEventNegate, Negate Condition
			y += 10
		}
			
		y += 20 + 4
		Gui, Add, Text, x%x% y%y%, Category:
		y += 30
		if(IsAction)
			Gui, Add, Text, x%x% y%y%, Action:
		else
			Gui, Add, Text, x%x% y%y%, Condition:
		x += 70
		y -= 4
		Gui, Add, DropDownList, vEditSubEventType gEditSubEventType x%x% y%y% w300
		y -= 1
		Gui, Add, Button, gSubEventHelp x+10 y%y%, Help
		y -= 29
		Gui, Add, DropDownList, vEditSubEventCategory gEditSubEventCategory x%x% y%y% w300
		x := 28
		y += 60
		w := width - 54
		
		if(IsAction)
			h := height - 158 - 28 
		else
			h := height - 158 - 28 - 20
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
		
		gosub FillSubEventCategories
		if(IsAction)
			Gui, Show, w%width% h%height%, Edit Action
		else
			Gui, Show, w%width% h%height%, Edit Condition
			
		Gui, +LastFound
		WinGet, EditSubEvent_hWnd,ID
		DetectHiddenWindows, Off
		loop
		{
			sleep 250
			IfWinNotExist ahk_id %EditSubEvent_hWnd% 
				break
		}
		Gui, 4:Default
		return result	
	}
	else if(GoToLabel = "EditSubEventOK")
	{		
		SubEvent.GuiSubmit(SubEventGUI)
		Gui, Submit, NoHide
		if(!IsAction)
			SubEvent.Negate := EditSubEventNegate
		result := SubEvent
		Gui, 4:-Disabled
		Gui, Destroy
		return
	}
	else if(GoToLabel = "EditSubEventClose")
	{
		Gui, 4:-Disabled
		Gui, Cancel
		Gui, destroy
		Gui, 4:Default
		result := ""
		return
	}
	else if(GoToLabel = "FillSubEventCategories")
	{
		if(IsAction)
			enum := Action_Categories._newEnum()
		else
			enum := Condition_Categories._newEnum()
			
		while enum[key,value]
		{
			outputdebug add %key%
			if(key = SubEvent.Category)
				GuiControl,,EditSubEventCategory,%key%||
			else
				GuiControl,,EditSubEventCategory,%key%
		}
		gosub EditSubEventCategory
		return
	}
	else if(GoToLabel = "EditSubEventCategory")
	{
		GuiControlGet, EditSubEventCategory
		;SubEventGUI contains all control hwnds for the subevent-specific part of the gui
		if(SubEventGUI)
		{
			if(SubEvent.Category = EditSubEventCategory) ;selecting same item, ignore
				return
		}
		category := IsAction ? Action_Categories[EditSubEventCategory] : Condition_Categories[EditSubEventCategory]
		GuiControl,,EditSubEventType,|
		found := false
		Loop % category.len()
		{
			type := category[A_Index]
			if(SubEvent.type = type)
			{
				GuiControl,,EditSubEventType,%type%||
				found := true
			}
			else
				GuiControl,,EditSubEventType,%type%			
		}
		if(!found)
		{
			;Select first event, and create a subevent of that type (latter should maybe be done in selection label EditSubEventType)
			GuiControl, Choose, EditSubEventType, 1
		}	
		gosub EditSubEventType	
		return
	}
	else if(GoToLabel = "EditSubEventType")
	{
		GuiControlGet, type,,EditSubEventType
		GuiControlGet, category,,EditSubEventCategory
		;At startup, SubEventGUI isn't set, and so the original subevent doesn't get overriden
		if(SubEventGUI)
		{
			;SubEventGUI contains all control hwnds for the subevent-specific part of the gui
			if(SubEvent.Type = type && SubEvent.Category = category) ;selecting same item, ignore
				return
			t := SubEvent.Type
			c := SubEvent.Category
			SubEvent.GuiSubmit(SubEventGUI)
			SubEvent := EventSystem_CreateSubEvent(IsAction ? "Action" : "Condition",type)
		}
		;Show sub-specific part of the gui and store hwnds in SubEventGUI
		SubEventGUI := object("Type", type)
		SubEventGUI.x := 38
		if(!IsAction)
			SubEventGUI.y := 178
		else
			SubEventGUI.y := 148
		SubEventGUI.w := width - 74
		SubEventGUI.h := height - 168 - 28 
		SubEventGUI.GUINum := 5
		SubEvent.GuiShow(SubEventGUI)
		return
	}
	else if(GoToLabel = "SubEventHelp")
	{
		GuiControlGet, type,,EditSubEventType
		if(IsAction)
			Run http://code.google.com/p/7plus/wiki/docsActions%type%,, UseErrorLevel
		else
			Run http://code.google.com/p/7plus/wiki/docsConditions%type%,, UseErrorLevel
		return
	}
}
SubEventHelp:
GUI_EditSubEvent("","","SubEventHelp")
return

EditSubEventOK:
GUI_EditSubEvent("","","EditSubEventOK")
return

EditSubEventClose:
EditSubEventEscape:
EditSubEventCancel:
GUI_EditSubEvent("","","EditSubEventClose")
return

FillSubEventCategories:
GUI_EditSubEvent("","","FillSubEventCategories")
return

;Called when a subevent category gets selected
EditSubEventCategory:
GUI_EditSubEvent("","","EditSubEventCategory")
return

EditSubEventType:
GUI_EditSubEvent("","","EditSubEventType")
return