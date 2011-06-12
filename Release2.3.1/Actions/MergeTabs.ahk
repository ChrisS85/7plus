Action_MergeTabs_Init(Action)
{
	Action.Category := "Explorer"
}

Action_MergeTabs_ReadXML(Action, XMLAction)
{
}

Action_MergeTabs_DisplayString(Action)
{
	return "Merge all explorer windows into one window with tabs"
}
Action_MergeTabs_Execute(Action, Event)
{
	global UseTabs, ExplorerWindows, CTabContainer
	if(!UseTabs)
		return 0
	Active := WinActive("ahk_group ExplorerGroup")
	if(!Active)
		return 0
	if(ExplorerWindows.TabContainerList.TabCreationInProgress)
		return 0
	if(ExplorerWindows.len() < 2)
		return 0
	TabContainer := ExplorerWindows.SubItem("hwnd", Active).TabContainer
	if(!TabContainer)
		TabContainer := new CTabContainer(ExplorerWindows.SubItem("hwnd", Active))
	Loop % ExplorerWindows.len()
	{
		if(!TabContainer.tabs.SubItem("hwnd", ExplorerWindows[A_Index].hwnd))
			TabContainer.Add(ExplorerWindows[A_Index], "", 0)
	}
	index := 1
	Loop % ExplorerWindows.TabContainerList.len()
	{
		if(ExplorerWindows.TabContainerList[index] != TabContainer)
			ExplorerWindows.TabContainerList.Remove(index)
		else
			index++
	}
}
Action_MergeTabs_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_MergeTabs_GUISubmit(Action, ActionGUI)
{
}