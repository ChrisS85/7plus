Action_FastFoldersClear_Init(Action)
{
	Action.Category := "FastFolders"
}

Action_FastFoldersClear_ReadXML(Action, XMLAction)
{
	Action.Slot := XMLAction.Slot
}
Action_FastFoldersClear_Execute(Action, Event)
{
	global
	local Slot
	Slot := Action.Slot
	if(Slot >= 0 && Slot <= 9 )
		ClearStoredFolder(FF%Slot%,FFTitle%Slot%)
	return 1
} 

Action_FastFoldersClear_DisplayString(Action)
{
	return "Clear FastFolder: " Action.Slot
} 
Action_FastFoldersClear_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Slot", "", "", "Slot (0-9):")
}

Action_FastFoldersClear_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	Action.Slot := min(max(Action.Slot, 0), 9)
}