Action_Input_Init(Action)
{
	Action.Category := "Input"
	Action.Cancel := 0
}	
Action_Input_ReadXML(Action, XMLAction)
{
	Action.Text := XMLAction.Text
	Action.Title := XMLAction.Title
	Action.Cancel := XMLAction.Cancel
}
Action_Input_Execute(Action,Event)
{
	global EventSchedule
	if(!Action.tmpGuiNum)
	{
		result := UserInputBox(Action, Event.ExpandPlaceHolders(Action.Title), Event.ExpandPlaceHolders(Action.Text), Action.Cancel)
		if(result)
			return -1
		else
			return 0 ;Msgbox wasn't created
	}
	else
	{
		GuiNum := Action.tmpGuiNum
		;outputdebug waiting for Inputbox close %guinum%
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
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Text", "", "", "Text:", "Placeholders", "Action_Input_Placeholders_Text")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Title", "", "", "Window Title:", "Placeholders", "Action_Input_Placeholders_Title")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Cancel", "Show Cancel/Close Button")
	}
	else if(GoToLabel = "Text_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Text")
	else if(GoToLabel = "Title_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Title")
}
Action_Input_Placeholders_Text:
Action_Input_GuiShow("", "", "Text_Placeholders")
return

Action_Input_Placeholders_Title:
Action_Input_GuiShow("", "", "Title_Placeholders")
return

Action_Input_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}

;Non blocking Input box (can wait for closing in event system though)
UserInputBox(Action, Title, Text, Cancel) 
{
	Critical, Off
	GuiNum:=GetFreeGUINum(10)

	Gui,%GuiNum%:Destroy 
	Gui,%GuiNum%:Add,Text,y10,%Text% 

	Gui,%GuiNum%:Add, Edit, x+10 yp-4 w200 hwndEdit
	if(!Cancel)
		Gui, %GuiNum%:Add, Button, Default xp+120 y+10 w80 gInputBox_OK, OK
	if(Cancel)
	{
		Gui, %GuiNum%:Add, Button, Default xp+30 y+10 w80 gInputBox_OK, OK
		Gui, %GuiNum%:Add, Button, x+10 w80 gInputBox_Cancel, Cancel
	}
	Gui,%GuiNum%:-MinimizeBox -MaximizeBox +LabelInputbox +AlwaysOnTop
	Gui,%GuiNum%:Show,,%Title%
	Action.tmpEdit := Edit
	Action.tmpGuiNum := GuiNum
	;return Gui number to indicate that the Input box is still open
	return GuiNum
}

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
	InputBoxEventFromGUINumber(A_Gui, Event, Action)
	if(!Action.Cancel)
		return
	Action.tmpResult := "Cancel"
	Event.Placeholders.Input := ""
	Gui, Destroy
}
InputBoxOK()
{
	InputBoxEventFromGUINumber(A_Gui, Event, Action)
	outputdebug(Action.type)
	Action.tmpResult := "OK"
	edit := Action.tmpEdit
	ControlGetText, input, , ahk_id %edit%
	Event.Placeholders.Input := input
	Gui, Destroy
}
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