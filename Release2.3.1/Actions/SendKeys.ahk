Action_SendKeys_Init(Action)
{
	Action.Category := "Input"
	Action.WriteText := False
	Action.KeyDelay := 0
}
Action_SendKeys_ReadXML(Action, XMLAction)
{
	Action.Keys := XMLAction.Keys
	Action.WriteText := XMLAction.HasKey("WriteText") ? XMLAction.WriteText : Action.WriteText
	Action.KeyDelay := XMLAction.HasKey("KeyDelay") ? XMLAction.KeyDelay : Action.KeyDelay
}
Action_SendKeys_Execute(Action,Event)
{
	keys := Event.ExpandPlaceholders(Action.Keys)
	if(Action.WriteText)
	{
		Transform, Text, deref, %keys%
		WriteText(Text)
	}
	else
	{
		Backup := A_KeyDelay
		SetKeyDelay % Action.KeyDelay
		SendEvent %keys%
		SetKeyDelay % Backup
	}
	return 1
} 
Action_SendKeys_DisplayString(Action)
{
	return "SendKeys " Action.Keys
}
Action_SendKeys_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action sends keyboard input.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Keys", "", "", "Keys to send:", "Placeholders", "Action_SendKeys_Placeholders", "Key names", "Action_SendKeys_KeyNames")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "KeyDelay", "", "", "Key delay:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "WriteText", "Write text directly (useful for newlines, tabs etc.)")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Keys")
}
Action_SendKeys_Placeholders:
Action_SendKeys_GuiShow("", "", "Placeholders")
return

Action_SendKeys_KeyNames:
run http://www.autohotkey.com/docs/commands/Send.htm ,, UseErrorLevel
return

Action_SendKeys_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}