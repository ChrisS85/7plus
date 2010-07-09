Action_Screenshot_Init(Action)
{
	Action.Category := "System"
	Action.Area := "Screen"
	Action.Quality := 95
}

Action_Screenshot_ReadXML(Action, ActionFileHandle)
{
	Action.Area := xpath(ActionFileHandle, "/Area/Text()")
	Action.Quality := xpath(ActionFileHandle, "/Quality/Text()")
	Action.TargetFolder := xpath(ActionFileHandle, "/TargetFolder/Text()")
	Action.TargetFile := xpath(ActionFileHandle, "/TargetFile/Text()")
}

Action_Screenshot_Execute(Action, Event)
{
	global ImageExtensions
	TargetFolder := Event.ExpandPlaceholders(Action.TargetFolder)
	TargetFile := Event.ExpandPlaceholders(Action.TargetFile)
	if(Action.Area = "Screen")
		pBitmap := Gdip_BitmapFromScreen()
	else if(Action.Area = "Window")
		pBitmap := Gdip_BitmapFromHWND(WinExist("A"))
	Gdip_SaveBitmapToFile(pBitmap, TargetFolder "\" TargetFile, Action.Quality)
	Gdip_DisposeImage(pBitmap)
	return 1
} 

Action_Screenshot_DisplayString(Action)
{
	if(Action.Area = "Screen")
		return "Take screenshot"
	else if(Action.Area = "Window")
		return "Take screenshot of active window"
}

Action_Screenshot_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Area", "Screen|Window", "", "Area:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Quality", "", "", "Quality:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Browse", "Action_Screenshot_Browse", "Placeholders", "Action_Screenshot_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target filename:", "Placeholders", "Action_Screenshot_Placeholders_TargetFile")
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_Browse(sActionGUI, "TargetFolder")
	else if(GoToLabel = "Placeholders_TargetFolder")
		SubEventGUI_Placeholders(sActionGUI, "TargetFolder")
	else if(GoToLabel = "Placeholders_TargetFile")
		SubEventGUI_Placeholders(sActionGUI, "TargetFile")
}
Action_Screenshot_Browse:
Action_Screenshot_GuiShow(Action, ActionGUI, "Browse")
return

Action_Screenshot_Placeholders_TargetFolder:
Action_Screenshot_GuiShow(Action, ActionGUI, "Placeholders_TargetFolder")
return

Action_Screenshot_Placeholders_TargetFile:
Action_Screenshot_GuiShow(Action, ActionGUI, "Placeholders_TargetFile")
return

Action_Screenshot_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}