Action_Input_Init(Action)
{
	Action.Category := "Input"
	Action.Cancel := 0
	Action.Placeholder := "Input"
	Action.DataType := "Text"
}	
Action_Input_ReadXML(Action, XMLAction)
{
	Action.Text := XMLAction.Text
	Action.Title := XMLAction.Title
	Action.Cancel := XMLAction.Cancel
	Action.Placeholder := XMLAction.HasKey("Placeholder") ? XMLAction.Placeholder : "Input"
	Action.DataType := XMLAction.HasKey("DataType") ? XMLAction.DataType : "Text"
	if(Action.DataType = "Selection")
		Action.Selection := XMLAction.HasKey("Selection") ? XMLAction.Selection : "Default Selection"
}
Action_Input_Execute(Action,Event)
{
	global EventSchedule
	if(!Action.tmpGuiNum)
	{
		result := UserInputBox(Action)
		if(result)
			return -1
		else
			return 0 ;Msgbox wasn't created
	}
	else
	{
		GuiNum := Action.tmpGuiNum
		Gui,%GuiNum%:+LastFound 
		WinGet, InputBox_hwnd,ID
		DetectHiddenWindows, Off
		;outputdebug %A_IsCritical%
		If(WinExist("ahk_id " InputBox_hwnd)) ;Box not closed yet, need more processing time
			return -1
		else
			return Action.tmpResult != "Cancel" ;Box closed, all fine
	}
} 
Action_Input_DisplayString(Action)
{
	return "Ask user input"
}

Action_Input_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI, PreviousSelection
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		PreviousSelection := ""
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Text", "", "", "Text:", "Placeholders", "Action_Input_Placeholders_Text")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Title", "", "", "Window Title:", "Placeholders", "Action_Input_Placeholders_Title")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Cancel", "Show Cancel/Close Button")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Placeholder", "", "", "Placeholder:")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "DataType", "File|Number|Path|Selection|Text|Time", "Action_Input_DataType", "Data type:")
		Action_Input_GuiShow(Action, ActionGUI, "DataType_SelectionChange")
	}
	else if(GoToLabel = "Text_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Text")
	else if(GoToLabel = "Title_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Title")
	else if(GoToLabel = "DataType_SelectionChange")
	{
		ControlGetText, DataType, , % "ahk_id " sActionGUI.DropDown_DataType
		if(DataType != PreviousSelection)
		{
			if(PreviousSelection)
				if(PreviousSelection = "Selection")
					Action_Input_GuiShow(Action, ActionGUI, "ListViewSubmit")
			
			if(DataType = "Selection")
			{
				Gui, Add, ListView, % "AltSubmit -Hdr -ReadOnly -Multi hwndListView w300 h130 x" sActionGUI.x " y" sActionGUI.y, Selection
				Selection := Action.Selection
				Loop, Parse, Selection, |
					LV_Add("Select", A_LoopField)
				Gui, Add, Button, % "hwndAdd gAction_Input_Add w60 x+10 y" sActionGUI.y, Add
				Gui, Add, Button, % "hwndRemove gAction_Input_Remove w60 y+10", Remove
				sActionGUI.ListView := ListView
				sActionGUI.Add := Add
				sActionGUI.Remove := Remove
			}
		}
		PreviousSelection := DataType
	}
	else if(GoToLabel = "ListViewSubmit")
	{
		GuiNum := sActionGUI.GUINum
		Gui, %GuiNum%:ListView, SysListView321
		Action.Selection := ""
		Loop % LV_GetCount()
		{
			LV_GetText(line, A_Index)
			if(line)
				Action.Selection .= (A_Index != 1 ? "|" : "") line
		}
		WinKill, % "ahk_id " sActionGUI.ListView
		WinKill, % "ahk_id " sActionGUI.Add
		WinKill, % "ahk_id " sActionGUI.Remove
	}
	else if(GoToLabel = "ListView_Add")
	{
		GuiNum := sActionGUI.GUINum
		Gui, %GuiNum%:ListView, SysListView321
		LV_Add("Select","Option")
		ControlFocus, SysListView321, A
		ControlSend, SysListView321, {F2}, A
	}
	else if(GoToLabel = "ListView_Remove")
	{
		GuiNum := sActionGUI.GUINum
		Gui, %GuiNum%:ListView, SysListView321
		LV_Delete(LV_GetNext("Selected"))
	}
}
Action_Input_Placeholders_Text:
Action_Input_GuiShow("", "", "Text_Placeholders")
return

Action_Input_Placeholders_Title:
Action_Input_GuiShow("", "", "Title_Placeholders")
return
Action_Input_DataType:
Action_Input_GuiShow("", "", "DataType_SelectionChange")
return
Action_Input_Add:
Action_Input_GuiShow("", "", "ListView_Add")
return
Action_Input_Remove:
Action_Input_GuiShow("", "", "ListView_Remove")
return
Action_Input_GuiSubmit(Action, ActionGUI)
{
	Action_Input_GuiShow(Action, ActionGUI, "ListViewSubmit")
	SubEventGUI_GUISubmit(Action, ActionGUI)
	if(!Action.Placeholder)
	{
		Msgbox Placeholder must not be empty! It is now being set to "Input".
		Action.Placeholder := "Input"
	}
}
;Non blocking Input box (can wait for closing in event system though)
UserInputBox(Action, GoToLabel = "")
{
	static sAction
	if(GoToLabel = "")
	{
		sAction := Action
		WasCritical := A_IsCritical
		Critical, Off
		Title := Event.ExpandPlaceHolders(Action.Title)
		Text :=	Event.ExpandPlaceHolders(Action.Text)
		GuiNum:=GetFreeGUINum(10)
		StringReplace, Text, Text, ``n, `n
		Gui,%GuiNum%:Destroy 
		Gui,%GuiNum%:Add,Text,y10,%Text% 
		
		if(Action.DataType = "Text" || Action.DataType = "Path" || Action.DataType = "File")
		{
			Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit
			Action.tmpEdit := Edit
			if(Action.DataType = "Path" || Action.DataType = "File")
			{
				Gui,%GuiNum%:Add, Button, x+10 w80 hwndButton gInputBox_Browse, Browse
				Action.tmpButton := Button
			}
		}
		else if(Action.DataType = "Number")
		{
			Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit Number
			Action.tmpEdit := Edit
		}
		else if(Action.DataType = "Time")
		{
			Gui, %GuiNum%:Add, DateTime, x+10 yp-4 hwndEdit Choose20100101001000, Time
			Action.tmpEdit := Edit
		}
		else if(Action.DataType = "Selection")
		{
			Selection := Action.Selection
			Loop, Parse, Selection, |
			{
				Gui, %GuiNum%:Add, Radio, % "hwndRadio" (A_Index = 1 ? " Checked" : ""), %A_LoopField%
				Action["tmpRadio" A_Index] := Radio
			}
		}
		if(!Action.Cancel)
			Gui, %GuiNum%:Add, Button, Default xp+120 y+10 w80 gInputBox_OK, OK
		if(Action.Cancel)
		{
			Gui, %GuiNum%:Add, Button, Default xp+30 y+10 w80 gInputBox_OK, OK
			Gui, %GuiNum%:Add, Button, x+10 w80 gInputBox_Cancel, Cancel
		}
		Gui,%GuiNum%:-MinimizeBox -MaximizeBox +LabelInputbox
		Gui,%GuiNum%:Show,,%Title%
		Action.tmpGuiNum := GuiNum
		;return Gui number to indicate that the Input box is still open
		if(WasCritical)
			Critical
		return GuiNum
	}
	else if(GoToLabel = "Browse")
	{
		if(sAction.DataType = "Path")
		{
			FileSelectFolder, result,, 3, Select Folder
			if(!Errorlevel)
				ControlSetText, Edit1, %result%, A
		}
		else if(sAction.DataType = "File")
		{
			FileSelectFile, result,,, Select File
			if(!Errorlevel)
				ControlSetText, Edit1, %result%, A
		}
	}
}

InputBox_Browse:
UserInputBox("","Browse")
return
InputboxClose:
InputboxEscape:
InputBox_Cancel:
InputBoxCancel()
return
InputBox_OK:
InputBoxOK()
return
InputBoxCancel()
{
	global Events
	InputBoxEventFromGUINumber(A_Gui, Event, Action)
	if(!Action.Cancel)
		return
	Action.tmpResult := "Cancel"
	Events.GlobalPlaceholders[Action.Placeholder] := ""
	Gui, Destroy
}
InputBoxOK()
{
	global Events
	InputBoxEventFromGUINumber(A_Gui, Event, Action)
	Action.tmpResult := "OK"
	if(Action.DataType = "Text" || Action.DataType = "Number" || Action.DataType = "Path" || Action.DataType = "File")
		ControlGetText, input, Edit1
	else if(Action.DataType = "Time")
		ControlGetText, input, SysDateTimePick321
	else if(Action.DataType = "Selection")
	{
		
		Loop
		{
			ControlGet, Selected, Checked, , , % "ahk_id " Action["tmpRadio" A_Index]
			if(Errorlevel)
				break
			if(Selected)
			{
				ControlGetText, input, , % "ahk_id " Action["tmpRadio" A_Index]
				break
			}
		}
	}
	if(!Action.Placeholder)
		Action.Placeholder := "Input"
	Events.GlobalPlaceholders[Action.Placeholder] := input
	Gui, Destroy
}

;Finds the event and action of an input box action by its gui number
InputBoxEventFromGUINumber(number, ByRef Event, ByRef Action)
{
	global EventSchedule
	Loop % EventSchedule.len()
	{
		pos := A_Index
		Loop % EventSchedule[pos].Actions.len()
		{
			if(EventSchedule[pos].Actions[A_Index].Type = "Input" && EventSchedule[pos].Actions[A_Index].tmpGUINum = number)
			{
				Event := EventSchedule[pos]
				Action := EventSchedule[pos].Actions[A_Index]
				return EventSchedule[pos]
			}
		}
	}
	return 0
}