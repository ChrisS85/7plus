Action_NewFolder_Init(Action)
{
	global shell32muipath,Vista7
	Action.Category := "Explorer"
	if(Vista7)
		Action.FolderName:=TranslateMUI(shell32muipath,16859) ;"New Folder"
	else
		Action.FolderName:=TranslateMUI("shell32.dll",30320) ;"New Folder"
	Action.Rename := true
}
Action_NewFolder_ReadXML(Action, ActionFileHandle)
{
	Action.Foldername := xpath(ActionFileHandle, "/Foldername/Text()")
	Action.Rename := xpath(ActionFileHandle, "/Rename/Text()")
}
Action_NewFolder_Execute(Action, Event)
{
	global Vista7
	if(!(WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()))
	{
		Msgbox This action requires explorer to be active!
		return 0
	}
	if(IsRenaming())
		return 0
	
	;This is done manually, by creating a folder desired name, which is then focussed
	SetFocusToFileView()
	path := GetCurrentFolder()
	name := Event.ExpandPlaceholders(Action.Foldername)
	Testpath := path "\" name
	i:=1 ;Find free Foldername
	while InStr(FileExist(Testpath), "D") 
	{
		i++
		Testpath:=path "\" name " (" i ")"
	}
	FileCreateDir, %TestPath% ;Create Folder and then select it and rename it
	if(!InStr(FileExist(Testpath), "D"))
	{
		ToolTip(1, "Could not create a new folder here. Make sure you have the correct permissions!", "Could not create new folder!","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		SetTimer, ToolTipClose, -5000
		return 0
	}
	RefreshExplorer()
	Sleep 50
	if(i=1)
		SelectFiles(name)
	else
		SelectFiles(name " (" i ")")
	if(Action.Rename)
	{
		Sleep 50
		Send {F2}
	}
	return 1
} 

Action_NewFolder_DisplayString(Action)
{
	return "Create Folder: " Action.Foldername
}

Action_NewFolder_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Foldername", "", "", "Foldername:", "Placeholders", "Action_NewFolder_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Rename", "Start Renaming", "", "")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Foldername")
}
Action_NewFolder_Placeholders:
Action_NewFolder_GuiShow("", "", "Placeholders")
return

Action_NewFolder_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}