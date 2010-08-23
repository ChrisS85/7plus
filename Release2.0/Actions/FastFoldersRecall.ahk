Action_FastFoldersRecall_Init(Action)
{
	Action.Category := "FastFolders"
}

Action_FastFoldersRecall_ReadXML(Action, XMLAction)
{
	Action.Slot := XMLAction.Slot
}
Action_FastFoldersRecall_Execute(Action, Event)
{
	global
	local Slot
	Slot := Action.Slot
	if(Slot >= 0 && Slot <= 9 )
		SetDirectory(FF%Slot%)
	return 1
} 

Action_FastFoldersRecall_DisplayString(Action)
{
	return "Open FastFolder: " Action.Slot
} 
Action_FastFoldersRecall_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Slot", "", "", "Slot (0-9):")
}

Action_FastFoldersRecall_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	Action.Slot := min(max(Action.Slot, 0), 9)
}