Action_SendKeys_Init(Action)
{
	Action.Category := "Input"
}
Action_SendKeys_ReadXML(Action, ActionFileHandle)
{
	Action.Keys := xpath(ActionFileHandle, "/Keys/Text()")
}
Action_SendKeys_Execute(Action,Event)
{
	keys := Event.ExpandPlaceholders(Action.Keys)
	Send %keys%
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
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Keys", "", "", "Keys to send:", "Placeholders", "Action_SendKeys_Placeholders")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Keys")
}
Action_SendKeys_Placeholders:
Action_SendKeys_GuiShow("", "", "Placeholders")
return

Action_SendKeys_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}