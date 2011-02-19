Action_ImageConverter_Init(Action)
{
	Action.Category := "7plus"
	Action.Files := "${SelNM}"
}

Action_ImageConverter_ReadXML(Action, XMLAction)
{
	Action.Files := XMLAction.Files
}
Action_ImageConverter_Execute(Action, Event)
{
	Files := Event.ExpandPlaceholders(Action.Files)
	ImageConverter(Files)
	return 1
}

Action_ImageConverter_DisplayString(Action)
{
	return "Open Image Converter: " Action.Slot
} 
Action_ImageConverter_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI	
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Files", "", "", "Files:", "Placeholders", "Action_ImageConverter_Placeholders")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Files")
}
Action_ImageConverter_Placeholders:
Action_ImageConverter_GuiShow("", "", "Placeholders")
return

Action_ImageConverter_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 