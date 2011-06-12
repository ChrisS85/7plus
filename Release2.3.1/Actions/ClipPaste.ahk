 Action_ClipPaste_Init(Action)
{
	Action.Category := "System"
	Action.Index := 0
}
Action_ClipPaste_ReadXML(Action, XMLAction)
{
	Action.Index := XMLAction.HasKey("Index") ? XMLAction.Index : Action.Index
}
Action_ClipPaste_Execute(Action, Event)
{
	ClipboardMenuClicked(Action.Index)
} 

Action_ClipPaste_DisplayString(Action)
{
	return "Paste clipboard history entry"
}
Action_ClipPaste_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Index", "", "", "Index:")
}
Action_ClipPaste_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	return !(Action.Index >= 1 && Action.Index <= 10)
}