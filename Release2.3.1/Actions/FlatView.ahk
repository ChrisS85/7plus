Action_FlatView_Init(Action)
{
	Action.Category := "Explorer"
	Action.Paths := "${SelN}"
}

Action_FlatView_ReadXML(Action, XMLAction)
{
	Action.Paths := XMLAction.HasKey("Paths") ? XMLAction.Paths : Action.Paths
}
Action_FlatView_Execute(Action, Event)
{
	global Vista7
	if(Vista7)
		FlatView(ToArray(Event.ExpandPlaceholders(Action.Paths)))
	return 1
} 

Action_FlatView_DisplayString(Action)
{
	return "Show flat view of these files: " Action.Paths
}

Action_FlatView_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Paths", "", "", "Paths:", "Placeholders", "Action_FlatView_Placeholders")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Paths")
}
Action_FlatView_Placeholders:
Action_FlatView_GuiShow("", "", "Placeholders")
return

Action_FlatView_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	Action.Slot := min(max(Action.Slot, 0), 9)
}