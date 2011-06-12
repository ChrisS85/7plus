Action_NewFile_Init(Action)
{
	global Vista7
	Action.Category := "Explorer"
	if(Vista7)
		Action.Filename:=TranslateMUI("notepad.exe",470) ".txt" ;"New Textfile" ".txt"
	else
		Action.Filename:=TranslateMUI("shell32.dll",8587) " " TranslateMUI("notepad.exe",469) ".txt" ;"New" "Textfile" ".txt"
	Action.BaseFile := ""
	Action.Rename := true
}

Action_NewFile_ReadXML(Action, XMLAction)
{
	global Vista7
	Action.Filename := XMLAction.HasKey("Filename") ? XMLAction.Filename : Action.Filename
	Action.Rename := XMLAction.Rename
	Action.BaseFile := XMLAction.HasKey("BaseFile") ? XMLAction.BaseFile : Action.BaseFile
}

Action_NewFile_Execute(Action, Event)
{
	global Vista7
	if(!(WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()))
	{
		Msgbox This action requires explorer to be active!
		return 0
	}
	if(IsRenaming())
		return 0
	
	;This is done manually, by creating a text file desired name, which is then focussed
	SetFocusToFileView()
	path := GetCurrentFolder()
	name := Event.ExpandPlaceholders(Action.Filename)
	Testpath := FindFreeFileName(path "\" name)
	BaseFile := Event.ExpandPlaceholders(Action.BaseFile)
	if(BaseFile && FileExist(BaseFile))
		FileCopy, %BaseFile%, %TestPath%
	else
		FileAppend, %A_Space%, %TestPath%	;Create file and then select it and rename it
	if(!FileExist(TestPath))
	{
		Notify("Could not create new file!", "Could not create a new file here. Make sure you have the correct permissions!", "5", "GC=555555 TC=White MC=White",Vista7 ? 78 : 110)
		return 0
	}
	RefreshExplorer()
	Sleep 50
	if(WinActive("ahk_group DesktopGroup")) ;Desktop needs more time for refresh and selecting an item is handled by typing its name
		Sleep 1000
	SelectFiles(Testpath)
	if(Action.Rename)
	{
		Sleep 50
		Send {F2}
	}
	return 1
} 

Action_NewFile_DisplayString(Action)
{
	return "Create File: " Action.Filename
}

Action_NewFile_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Filename", "", "", "Filename:", "Placeholders", "Action_NewFile_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "BaseFile", "", "", "BaseFile:", "Browse", "Action_NewFile_Browse", "Placeholders", "Action_NewFile_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Rename", "Start Renaming", "", "")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Filename")
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "BaseFile")
}
Action_NewFile_Placeholders:
Action_NewFile_GuiShow("", "", "Placeholders")
return
Action_NewFile_Browse:
Action_NewFile_GuiShow("", "", "Browse")
return
Action_NewFile_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  