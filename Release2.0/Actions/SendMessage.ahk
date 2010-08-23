Action_SendMessage_Init(Action)
{
	WindowFilter_Init(Action)
	Action.Category := "System"
	Action.TargetControl := "Edit1"
	Action.Message := ""
	Action.wParam := ""
	Action.lParam := ""
	Action.MessageMode := "Post"
}
Action_SendMessage_ReadXML(Action, XMLAction)
{
	WindowFilter_ReadXML(Action, XMLAction)
	Action.TargetControl := XMLAction.TargetControl
	Action.Message := XMLAction.Message
	Action.wParam := XMLAction.wParam
	Action.lParam := XMLAction.lParam
	Action.MessageMode := XMLAction.MessageMode
}
Action_SendMessage_Execute(Action,Event)
{
	hwnd := WindowFilter_Get(Action)
	TargetControl := Event.ExpandPlaceholders(Action.TargetControl)
	Message := Event.ExpandPlaceholders(Action.Message)
	wParam := Event.ExpandPlaceholders(Action.wParam)
	lParam := Event.ExpandPlaceholders(Action.lParam)
	
	if(IsNumeric(TargetControl))
	{
		hwnd := TargetControl
		TargetControl := ""
	}
	if(Action.MessageMode = "Post")
	{
		if((!wParam || IsNumeric(wParam) ) && (!lParam || IsNumeric(lParam)))
			PostMessage, %Message%, %wParam%, %lParam%, %TargetControl%, ahk_id %hwnd%
		else if(!lParam || IsNumeric(lParam))
			PostMessage, %Message%, "" wParam "", %lParam%, %TargetControl%, ahk_id %hwnd%
		else if(!wParam || IsNumeric(wParam))
			PostMessage, %Message%, %wParam%, "" lParam "", %TargetControl%, ahk_id %hwnd%
		else
			PostMessage, %Message%, "" wParam "", "" lParam "", %TargetControl%, ahk_id %hwnd%
	}
	else
	{
		if((!wParam || IsNumeric(wParam) ) && (!lParam || IsNumeric(lParam)))
			SendMessage, %Message%, %wParam%, %lParam%, %TargetControl%, ahk_id %hwnd%
		else if(!lParam || IsNumeric(lParam))
			SendMessage, %Message%, "" wParam "", %lParam%, %TargetControl%, ahk_id %hwnd%
		else if(!wParam || IsNumeric(wParam))
		{
			SendMessage, %Message%, %wParam%, "" lParam "", %TargetControl%, ahk_id %hwnd%
			outputdebug send2 %lParam%
		}
		else
			SendMessage, %Message%, "" wParam "", "" lParam "", %TargetControl%, ahk_id %hwnd%
		Event.Placeholders.MessageResult := ErrorLevel
	}
	return 1
}
Action_SendMessage_DisplayString(Action)
{
	return Action.MessageMode "Message to " Action.TargetControl ", " WindowFilter_DisplayString(Action)
}
Action_SendMessage_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "MessageMode", "Post|Send", "", "Message mode:")
		SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Send waits for a response and allows ${MessageResult} to be used.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Message", "", "", "Message:", "Placeholders", "Action_SendMessage_Placeholders_Message")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "wParam", "", "", "wParam:", "Placeholders", "Action_SendMessage_Placeholders_wParam")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "lParam", "", "", "lParam:", "Placeholders", "Action_SendMessage_Placeholders_lParam")
		WindowFilter_GuiShow(Action,ActionGUI)
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetControl", "", "", "Target Control:")
	}
	else if(GoToLabel = "Placeholders_Message")
		SubEventGUI_Placeholders(sActionGUI, "Message")
	else if(GoToLabel = "Placeholders_wParam")
		SubEventGUI_Placeholders(sActionGUI, "wParam")
	else if(GoToLabel = "Placeholders_lParam")
		SubEventGUI_Placeholders(sActionGUI, "lParam")
}
Action_SendMessage_Placeholders_Message:
Action_SendMessage_GuiShow("", "", "Placeholders_Message")
return
Action_SendMessage_Placeholders_wParam:
Action_SendMessage_GuiShow("", "", "Placeholders_wParam")
return
Action_SendMessage_Placeholders_lParam:
Action_SendMessage_GuiShow("", "", "Placeholders_lParam")
return
Action_SendMessage_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 