Action_OpenInNewFolder_Init(Action)
{
	Action.Category := "Explorer"
	Action.Action := "Tab in Background"
}
Action_OpenInNewFolder_ReadXML(Action, XMLAction)
{
	if(XMLAction.HasKey("Action"))
		Action.Action := XMLAction.Action
}
Action_OpenInNewFolder_Execute(Action, Event)
{
	OpenInNewFolder(Action)
}
Action_OpenInNewFolder_DisplayString(Action)
{
	return "Open explorer folder under mouse in new window/tab"
}
Action_OpenInNewFolder_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action opens the explorer folder under the mouse in a new window, tab or in a tab without activating it.")
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Tab|Tab in Background|Window", "", "Open in new:")
}
Action_OpenInNewFolder_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}

;Opens the folder under the mouse in a new window or tab
OpenInNewFolder(Action)
{
	global UseTabs, MiddleOpenFolder
 	if(!WinActive("ahk_group ExplorerGroup")||!IsMouseOverFileList())
 		return false	
	selected:=GetSelectedFiles(0)
	Send {LButton}
	Sleep 100
	if(InStr(FileExist(undermouse:=GetSelectedFiles()), "D"))
		dir:=true
	if(select!=selected)
		SelectFiles(selected,1,0,0)
	if(!dir)
		return false
	if(Action.Action = "Tab" && UseTabs)
		CreateTab(0,undermouse, 1)
	else if(Action.Action = "Tab in background" && UseTabs)
		CreateTab(0,undermouse, 0)
	else
		Run(A_WinDir "\explorer.exe /n,/e," undermouse)
	return true
}