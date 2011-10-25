Class CInputAction Extends CAction
{
	static Type := RegisterType(CInputAction, "Ask for user input")
	static Category := RegisterCategory(CInputAction, "Input")
	
	static Cancel := false
	static Placeholder := "Input"
	static DataType := "Text"
	static Validate := true
	static Selection := "Default Selection"
	static Text := ""
	static Title := ""
	
	Execute(Event)
	{
		if(!this.tmpGuiNum)
		{
			result := this.UserInputBox(Event)
			if(result)
				return -1
			else
				return 0 ;Msgbox wasn't created
		}
		else
		{
			GuiNum := this.tmpGuiNum
			Gui,%GuiNum%:+LastFound 
			WinGet, InputBox_hwnd,ID
			DetectHiddenWindows, Off
			;outputdebug %A_IsCritical%
			If(WinExist("ahk_id " InputBox_hwnd)) ;Box not closed yet, need more processing time
				return -1
			else
			{
				this.Remove("tmpGUINum") ;Remove so other actions in this event may reuse this GUI number
				return this.tmpResult != "Cancel" ;Box closed, all fine
			}
		}
	}
	
	DisplayString()
	{
		return "Ask user input"
	}

	GuiShow(GUI, GoToLabel = "")
	{
		static sGUI, sPreviousSelection
		if(GoToLabel = "")
		{
			sGUI := GUI
			sPreviousSelection := ""
			this.AddControl(GUI, "Text", "Desc", "This action shows a dialog asking for user input. The result is stored in a placeholder that may be used in further actions.")
			this.AddControl(GUI, "Edit", "Text", "", "", "Text:", "Placeholders", "Action_Input_Placeholders_Text")
			this.AddControl(GUI, "Edit", "Title", "", "", "Window Title:", "Placeholders", "Action_Input_Placeholders_Title")
			this.AddControl(GUI, "Edit", "Placeholder", "", "", "Placeholder:","","","","","The name of the placeholder in which the result is stored. This is just the name without the enclosing ${ }.")
			this.AddControl(GUI, "Checkbox", "Cancel", "Show Cancel/Close Button")
			this.AddControl(GUI, "Checkbox", "Validate", "Validate input (file, path and text only)")
			this.AddControl(GUI, "DropDownList", "DataType", "File|Number|Path|Selection|Text|Time", "Action_Input_DataType", "Data type:")
			this.GuiShow(GUI, "DataType_SelectionChange")
		}
		else if(GoToLabel = "Text_Placeholders")
			ShowPlaceholderMenu(sGUI, "Text")
		else if(GoToLabel = "Title_Placeholders")
			ShowPlaceholderMenu(sGUI, "Title")
		else if(GoToLabel = "DataType_SelectionChange")
		{
			ControlGetText, DataType, , % "ahk_id " sGUI.DropDown_DataType
			if(DataType != sPreviousSelection)
			{
				if(sPreviousSelection)
					if(sPreviousSelection = "Selection")
						this.GuiShow(sGUI, "ListViewSubmit")
				
				if(DataType = "Selection")
				{
					Gui, Add, ListView, % "AltSubmit -Hdr -ReadOnly -Multi hwndListView w300 h100 x" sGUI.x " y" sGUI.y, Selection
					Selection := this.Selection
					Loop, Parse, Selection, |
						LV_Add("Select", A_LoopField)
					Gui, Add, Button, % "hwndAdd gAction_Input_Add w60 x+10 y" sGUI.y, Add
					Gui, Add, Button, % "hwndRemove gAction_Input_Remove w60 y+10", Remove
					sGUI.ListView := ListView
					sGUI.Add := Add
					sGUI.Remove := Remove
				}
			}
			sPreviousSelection := DataType
		}
		else if(GoToLabel = "ListViewSubmit")
		{
			GuiNum := sGUI.GUINum
			Gui, %GuiNum%:ListView, % sGUI.ListView
			this.Selection := ""
			Loop % LV_GetCount()
			{
				LV_GetText(line, A_Index)
				if(line)
					this.Selection .= (A_Index != 1 ? "|" : "") line
			}
			WinKill, % "ahk_id " sGUI.ListView
			WinKill, % "ahk_id " sGUI.Add
			WinKill, % "ahk_id " sGUI.Remove
		}
		else if(GoToLabel = "ListView_Add")
		{
			GuiNum := sGUI.GUINum
			Gui, %GuiNum%:ListView, % sGUI.ListView
			LV_Add("Select","Option")
			ControlFocus,, % "ahk_id " sGUI.ListView
			ControlSend,, {F2}, % "ahk_id " sGUI.ListView
		}
		else if(GoToLabel = "ListView_Remove")
		{
			GuiNum := sGUI.GUINum
			Gui, %GuiNum%:ListView, % sGUI.ListView
			LV_Delete(LV_GetNext("Selected"))
		}
	}
	
	GuiSubmit(GUI)
	{
		this.GuiShow(GUI, "ListViewSubmit")
		Base.GuiSubmit(GUI)
		if(!this.Placeholder)
		{
			Msgbox Placeholder must not be empty! It is now being set to "Input".
			this.Placeholder := "Input"
		}
	}
	
	;Non blocking Input box (can wait for closing in event system though)
	UserInputBox(Event)
	{
		WasCritical := A_IsCritical
		Critical, Off
		Title := Event.ExpandPlaceHolders(this.Title)
		Text :=	Event.ExpandPlaceHolders(this.Text)
		GuiNum:=GetFreeGUINum(1, "InputBox")
		this.tmpGuiNum := GuiNum
		StringReplace, Text, Text, ``n, `n
		Gui,%GuiNum%:Destroy
		Gui,%GuiNum%:Add,Text,y10,%Text% 
		
		if(this.DataType = "Text" || this.DataType = "Path" || this.DataType = "File")
		{
			Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit gAction_Input_Edit
			this.tmpEdit := Edit
			if(this.DataType = "Path" || this.DataType = "File")
			{
				Gui,%GuiNum%:Add, Button, x+10 w80 hwndButton gInputBox_Browse, Browse
				this.tmpButton := Button
			}
		}
		else if(this.DataType = "Number")
		{
			Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit Number
			this.tmpEdit := Edit
		}
		else if(this.DataType = "Time")
		{
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndHours Number, 00
			Gui, %GuiNum%:Add, Text, x+2 yp+4, :
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndMinutes Number, 10
			Gui, %GuiNum%:Add, Text, x+2 yp+4, :
			Gui, %GuiNum%:Add, Edit, x+2 yp-4 w30 hwndSeconds Number, 00
			this.tmpHours := Hours
			this.tmpHours := Minutes
			this.tmpSeconds := Seconds
		}
		else if(this.DataType = "Selection")
		{
			Selection := this.Selection
			Loop, Parse, Selection, |
			{
				Gui, %GuiNum%:Add, Radio, % "hwndRadio" (A_Index = 1 ? " Checked" : ""), %A_LoopField%
				this["tmpRadio" A_Index] := Radio
			}
		}
		Gui, %GuiNum%:Add, Text, x+-80 hwndTest, test
		ControlGetPos, PosX, PosY,,,,ahk_id %Test%
		WinKill, ahk_id %Test%
		if(PosX < 160)
			PosX := 160
		if(!this.Cancel)
			Gui, %GuiNum%:Add, Button, % "Default x" PosX " y" PosY " w80 gInputBox_OK " (this.Validate && (this.DataType = "Text" || this.DataType = "Path" || this.DataType = "File") ? "Disabled" : ""), OK
		if(this.Cancel)
		{
			PosX -= 90
			Gui, %GuiNum%:Add, Button, % "Default x" PosX " y" PosY " w80 gInputBox_OK " (this.Validate && (this.DataType = "Text" || this.DataType = "Path" || this.DataType = "File") ? "Disabled" : ""), OK
			Gui, %GuiNum%:Add, Button, x+10 w80 gInputBox_Cancel, Cancel
		}
		Gui,%GuiNum%:-MinimizeBox -MaximizeBox +LabelInputbox
		Gui,%GuiNum%:Show,,%Title%
		;return Gui number to indicate that the Input box is still open
		if(WasCritical)
			Critical
		return GuiNum
	}
	
	InputBoxBrowse()
	{
		if(this.DataType = "Path")
		{
			FileSelectFolder, result,, 3, Select Folder
			if(!Errorlevel)
				ControlSetText, Edit1, %result%, A
		}
		else if(this.DataType = "File")
		{
			FileSelectFile, result,,, Select File
			if(!Errorlevel)
				ControlSetText, Edit1, %result%, A
		}
	}
	
	InputBoxEdit()
	{
		if(this.Validate)
		{
			ControlGetText, input, Edit1
			if(this.DataType = "Text")
			{
				if(input = "")
					Control, Disable,, Button1
				else
					Control, Enable,, Button1
			}
			else if(this.DataType = "File" || this.DataType = "Path")
			{
				if(FileExist(input))
					Control, Enable,, Button2
				else
					Control, Disable,, Button2
			}
		}
	}
	
	InputBoxCancel()
	{
		if(!this.Cancel)
			return
		this.tmpResult := "Cancel"
		EventSystem.Events.GlobalPlaceholders[this.Placeholder] := ""
		Gui, Destroy
	}
	
	InputBoxOK(Event)
	{
		this.tmpResult := "OK"
		if(this.DataType = "Text" || this.DataType = "Number" || this.DataType = "Path" || this.DataType = "File")
			ControlGetText, input, Edit1
		else if(this.DataType = "Time")
		{
			ControlGetText, Hours, Edit1
			ControlGetText, Minutes, Edit2
			ControlGetText, Seconds, Edit3
			input := (SubStr("00" Hours, -1) ":" SubStr("00" Minutes, -1) ":" SubStr("00" Seconds, -1))
		}
		else if(this.DataType = "Selection")
		{			
			Loop
			{
				ControlGet, Selected, Checked, , , % "ahk_id " this["tmpRadio" A_Index]
				if(Errorlevel)
					break
				if(Selected)
				{
					ControlGetText, input, , % "ahk_id " this["tmpRadio" A_Index]
					break
				}
			}
		}
		if(!this.Placeholder)
			this.Placeholder := "Input"
		EventSystem.Events.GlobalPlaceholders[this.Placeholder] := input
		Gui, Destroy
	}
}

Action_Input_Placeholders_Text:
GetCurrentSubEvent().GuiShow("", "Text_Placeholders")
return
Action_Input_Placeholders_Title:
GetCurrentSubEvent().GuiShow("", "Title_Placeholders")
return
Action_Input_DataType:
GetCurrentSubEvent().GuiShow("", "DataType_SelectionChange")
return
Action_Input_Add:
GetCurrentSubEvent().GuiShow("", "ListView_Add")
return
Action_Input_Remove:
GetCurrentSubEvent().GuiShow("", "ListView_Remove")
return

Action_Input_Edit:
EventSystem.SubEventEventFromGUI().InputBoxEdit()
return
InputBox_Browse:
EventSystem.SubEventEventFromGUI().InputBoxBrowse()
return
InputboxClose:
InputboxEscape:
InputBox_Cancel:
EventSystem.SubEventEventFromGUI().InputBoxCancel()
return
InputBox_OK:
EventSystem.SubEventEventFromGUI().InputBoxOK()
return