 Action_ClipMenu_Init(Action)
{
	global Vista7
	Action.Category := "System"
}

Action_ClipMenu_Execute(Action, Event)
{
	if(!Action.tmpShowing)
	{
		Action.tmpShowing := true
		ClipboardManagerMenu()
	}
	else if(!IsContextMenuActive()) ;Menu closed
	{
		Action.tmpShowing := false
		return 1
	}
	return -1 ;Waiting for menu to close
} 

Action_ClipMenu_DisplayString(Action)
{
	return "Show Clipboard Manager Menu"
}