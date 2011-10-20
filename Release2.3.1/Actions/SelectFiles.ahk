Action_SelectFiles_Init(Action)
{
	Action.Category := "Explorer"
	Action.Clear := 1
	Action.Deselect := 0
	Action.Filter := "*.exe;*.jpg"
	Action.Wildcard := 1
	Action.WindowMatchType := "Active"
}
Action_SelectFiles_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Filter")
	Action.ReadVar(XMLAction, "Clear")
	Action.ReadVar(XMLAction, "Deselect")
	Action.ReadVar(XMLAction, "Wildcard")
	WindowFilter_ReadXML(Action,XMLAction)
}
Action_SelectFiles_Execute(Action, Event)
{
	hwnd := WindowFilter_Get(Action)
	Filter := Event.ExpandPlaceholders(Action.Filter)
	Separator := ";"
	Filter := ToArray(Filter, Separator)
	if(Action.Wildcard)
		Loop % Filter.MaxIndex()
			Filter[A_Index] := "*" Filter[A_Index] "*"
	SelectFiles(Filter,Action.Clear,Action.Deselect,1,1,hwnd)
	return 1
} 

Action_SelectFiles_DisplayString(Action)
{
	return (Action.Deselect ? "Des": "S") "elect files: " Action.Filter
}
Action_SelectFiles_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action selects files in an active explorer window.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Filter", "", "", "Filter:", "Placeholders", "Action_SelectFiles_Placeholders_Filter")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Clear", "Clear selection first")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Deselect", "Deselect files")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Wildcard", "Automatically add wildcards to start and end")
		WindowFilter_GuiShow(Action, ActionGUI)
	}
	else if(GoToLabel = "Placeholders_Filter")
		SubEventGUI_Placeholders(sActionGUI, "Filter")
}
Action_SelectFiles_Placeholders_Filter:
Action_SelectFiles_GuiShow("", "", "Placeholders_Filter")
return

Action_SelectFiles_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  