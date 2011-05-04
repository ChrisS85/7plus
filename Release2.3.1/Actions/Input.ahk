Action_Input_Init(Action)
{
	Action.Category := "Input"
	Action.Cancel := 0
	Action.Placeholder := "Input"
	Action.DataType := "Text"
	Action.Validate := 1
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
	else
		Action.Validate := XMLAction.HasKey("Validate") ? XMLAction.Validate : 1
}
Action_Input_Execute(Action,Event)
{
	if(!Action.tmpGuiNum)
	{
		result := UserInputBox(Action,Event)
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
		{
			Action.Remove("tmpGUINum") ;Remove so other actions in this event may reuse this GUI number
			return Action.tmpResult != "Cancel" ;Box closed, all fine
		}
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
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Placeholder", "", "", "Placeholder:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Cancel", "Show Cancel/Close Button")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Validate", "Validate input (file, path and text only)")
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
				Gui, Add, ListView, % "AltSubmit -Hdr -ReadOnly -Multi hwndListView w300 h100 x" sActionGUI.x " y" sActionGUI.y, Selection
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
UserInputBox(Action, Event, GoToLabel = "")
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
			Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit gAction_Input_Edit
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
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndHours Number, 00
			Gui, %GuiNum%:Add, Text, x+2 yp+4, :
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndMinutes Number, 10
			Gui, %GuiNum%:Add, Text, x+2 yp+4, :
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndSeconds Number, 00
			Action.tmpHours := Hours
			Action.tmpHours := Minutes
			Action.tmpSeconds := Seconds
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
		Gui, %GuiNum%:Add, Text, x+-80 hwndTest, test
		ControlGetPos, PosX, PosY,,,,ahk_id %Test%
		WinKill, ahk_id %Test%
		if(PosX < 160)
			PosX := 160
		if(!Action.Cancel)
			Gui, %GuiNum%:Add, Button, % "Default x" PosX " y" PosY " w80 gInputBox_OK " (Action.Validate && (Action.DataType = "Text" || Action.DataType = "Path" || Action.DataType = "File") ? "Disabled" : ""), OK
		if(Action.Cancel)
		{
			PosX -= 90
			Gui, %GuiNum%:Add, Button, % "Default x" PosX " y" PosY " w80 gInputBox_OK " (Action.Validate && (Action.DataType = "Text" || Action.DataType = "Path" || Action.DataType = "File") ? "Disabled" : ""), OK
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
Action_Input_Edit:
Action_Input_Edit()
return
Action_Input_Edit()
{
	EventFromGUINumber(A_Gui, "Input", Event, Action)
	if(Action.Validate)
	{
		ControlGetText, input, Edit1
		if(Action.DataType = "Text")
		{
			if(input = "")
				Control, Disable,, Button1
			else
				Control, Enable,, Button1
		}
		else if(Action.DataType = "File" || Action.DataType = "Path")
		{
			if(FileExist(input))
				Control, Enable,, Button2
			else
				Control, Disable,, Button2
		}
	}
}
InputBox_Browse:
UserInputBox("","","Browse")
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
	EventFromGUINumber(A_Gui, "Input", Event, Action)
	if(!Action.Cancel)
		return
	Action.tmpResult := "Cancel"
	Events.GlobalPlaceholders[Action.Placeholder] := ""
	Gui, Destroy
}
InputBoxOK()
{
	global Events
	EventFromGUINumber(A_Gui, "Input", Event, Action)
	Action.tmpResult := "OK"
	if(Action.DataType = "Text" || Action.DataType = "Number" || Action.DataType = "Path" || Action.DataType = "File")
		ControlGetText, input, Edit1
	else if(Action.DataType = "Time")
	{
		ControlGetText, Hours, Edit1
		ControlGetText, Minutes, Edit2
		ControlGetText, Seconds, Edit3
		input := (SubStr("00" Hours, -1) ":" SubStr("00" Minutes, -1) ":" SubStr("00" Seconds, -1))
	}
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