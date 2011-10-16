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
Action_NewFolder_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Foldername")
	Action.ReadVar(XMLAction, "Rename")
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
	if(strEndsWith(path, "\"))
		path := SubStr(path, 1, StrLen(path) - 1)
	name := Event.ExpandPlaceholders(Action.Foldername)
	TestPath := FindFreeFileName(path "\" name)
	FileCreateDir, %TestPath% ;Create Folder and then select it and rename it
	
	;if folder wasn't created, it's possible that it happens because the user is on a network share/drive and logged in with wrong credentials.
	;Let CMD handle directory creation then.
	if(!InStr(FileExist(Testpath), "D"))
	{
		SplitPath, TestPath,,,,,Drive
		FileDelete, %A_Temp%\mkdir.bat
		FileAppend, %Drive%`nmkdir "%Testpath%", %A_Temp%\mkdir.bat
		Run, %A_Temp%\mkdir.bat,,Hide
		FileDelete, %A_Temp%\mkdir.bat
	}
	
	if(!InStr(FileExist(Testpath), "D"))
	{
		Notify("Could not create new folder!", "Could not create a new folder here. Make sure you have the correct permissions!", "5", "GC=555555 TC=White MC=White",NotifyIcons.Error)
		; ToolTip(1, "Could not create a new folder here. Make sure you have the correct permissions!", "Could not create new folder!","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		; SetTimer, ToolTipClose, -5000
		return 0
	}
	RefreshExplorer()
	Sleep 50
	if(WinActive("ahk_group DesktopGroup")) ;Desktop needs more time for refresh and selecting an item is handled by typing its name
		Sleep 1000
	SelectFiles(TestPath)
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
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action creates a new folder in the current directory while explorer is active and goes into renaming mode.")
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