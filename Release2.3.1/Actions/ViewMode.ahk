Action_ViewMode_Init(Action)
{
	Action.Category := "Explorer"
	Action.Action := "Toggle show hidden files"
}

Action_ViewMode_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Action")
}

Action_ViewMode_Execute(Action, Event)
{
	if(Action.Action = "Toggle show hidden files")
	{
		RegRead, ShowFiles, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
		if(ShowFiles = 2)
			RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1 
		else  
			RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2 
		RefreshExplorerView()
	}
	else if(Action.Action = "Show hidden files")
	{
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
		RefreshExplorerView()
	}
	else if(Action.Action = "Hide hidden files")
	{
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
		RefreshExplorerView()
	}
	if(Action.Action = "Toggle show file extensions")
	{
		RegRead, ShowFiles, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt 
		if(ShowFiles = 1)
			RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
		else  
			RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
		RefreshExplorerView()
	}
	else if(Action.Action = "Show file extensions")
	{
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
		RefreshExplorerView()
	}
	else if(Action.Action = "Hide file extensions")
	{
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
		RefreshExplorerView()
	}
	return 1
}
RefreshExplorerView()
{
	if (IsDialog() || WinActive("ahk_group ExplorerGroup"))
		send, {F5}
}
Action_ViewMode_DisplayString(Action)
{
	return Action.Action ;Action.Parameter
}

Action_ViewMode_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action can modify various explorer settings.")
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Toggle show hidden files|Show hidden files|Hide hidden files|Toggle show file extensions|Show file extensions|Hide file extensions", "", "Action:")
}

Action_ViewMode_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}