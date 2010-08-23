Action_FastFoldersStore_Init(Action)
{
	Action.Category := "FastFolders"
}

Action_FastFoldersStore_ReadXML(Action, XMLAction)
{
	Action.Folder := XMLAction.Folder
	Action.Slot := XMLAction.Slot
}
Action_FastFoldersStore_Execute(Action, Event)
{
	global
	local Slot
	Slot := Action.Slot
	Folder := Event.ExpandPlaceholders(Action.Folder)
	if(Slot >= 0 && Slot <= 9)
	{
		UpdateStoredFolder(FF%Slot%,FFTitle%Slot%, Folder)
		return 1
	}
	return 1
} 

Action_FastFoldersStore_DisplayString(Action)
{
	return "Store FastFolder: " Action.Slot
} 
Action_FastFoldersStore_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI	
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Folder", "", "", "Folder:", "Placeholders", "Action_FastFoldersStore_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Slot", "", "", "Slot (0-9):")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Folder")
}
Action_FastFoldersStore_Placeholders:
Action_FastFoldersStore_GuiShow("", "", "Placeholders")
return

Action_FastFoldersStore_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	Action.Slot := min(max(Action.Slot, 0), 9)
} 