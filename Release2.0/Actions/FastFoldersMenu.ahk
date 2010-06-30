 Action_FastFoldersMenu_Init(Action)
{
	global Vista7
	Action.Category := "FastFolders"
}

Action_FastFoldersMenu_Execute(Action, Event)
{
	if(!Action.tmpShowing)
	{
		Action.tmpShowing := true
		FastFolderMenu()
	}
	else if(!IsContextMenuActive()) ;Menu closed
	{
		Action.tmpShowing := false
		return 1
	}
	return -1 ;Waiting for menu to close
} 

Action_FastFoldersMenu_DisplayString(Action)
{
	return "Show FastFolders Menu"
} 