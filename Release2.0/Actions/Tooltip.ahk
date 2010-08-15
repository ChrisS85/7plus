Action_ToolTip_Init(Action)
{
	Action.Category := "System"
	Action.TrayToolTip := 0
	Action.Timeout := 5
}

Action_ToolTip_ReadXML(Action, ActionFileHandle)
{
	Action.Text := xpath(ActionFileHandle, "/Text/Text()")
	Action.Timeout := xpath(ActionFileHandle, "/Timeout/Text()")
	Action.Title := xpath(ActionFileHandle, "/Title/Text()")
	Action.TrayToolTip := xpath(ActionFileHandle, "/TrayToolTip/Text()")
}

Action_ToolTip_Execute(Action, Event)
{
	Text := Event.ExpandPlaceholders(Action.Text)
	Timeout := Action.Timeout * 1000
	if(TrayToolTip)
	{		
		Title := Event.ExpandPlaceholders(Action.Title)
		ToolTip(1, Text, Title, "O1 L1 C1 XTrayIcon YTrayIcon")
		SetTimer, ToolTipClose, -%Timeout%
	}
	else
	{
		ToolTip, %Text%
		SetTimer, Action_ToolTip_Timeout, -%Timeout%
	}
	return 1
}
 
Action_ToolTip_Timeout:
Tooltip
return

Action_ToolTip_DisplayString(Action)
{
	return "Show tooltip: " Action.Text
}

Action_ToolTip_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Text", "", "", "Text:", "Placeholders", "Action_ToolTip_Placeholders_Text")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Timeout", "", "", "Timeout:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "TrayToolTip", "Use tray tooltip")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Title", "", "", "Title:", "Placeholders", "Action_ToolTip_Placeholders_Title")
	}
	else if(GoToLabel = "Placeholders_Text")
		SubEventGUI_Placeholders(sActionGUI, "Text")
	else if(GoToLabel = "Placeholders_Title")
		SubEventGUI_Placeholders(sActionGUI, "Title")
}

Action_ToolTip_Placeholders_Text:
Action_ToolTip_GuiShow("", "", "Placeholders_Text")
return
Action_ToolTip_Placeholders_Title:
Action_ToolTip_GuiShow("", "", "Placeholders_Title")
return

Action_ToolTip_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 