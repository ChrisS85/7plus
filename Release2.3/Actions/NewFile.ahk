Action_NewFile_Init(Action)
{
	global Vista7
	Action.Category := "Explorer"
	if(Vista7)
		Action.Filename:=TranslateMUI("notepad.exe",470) ".txt" ;"New Textfile" ".txt"
	else
		Action.Filename:=TranslateMUI("shell32.dll",8587) " " TranslateMUI("notepad.exe",469) ".txt" ;"New" "Textfile" ".txt"
	Action.Rename := true
}

Action_NewFile_ReadXML(Action, XMLAction)
{
	global Vista7
	Action.Filename := XMLAction.Filename
	Action.Rename := XMLAction.Rename
	if(!Action.Filename)
	{
		if(Vista7)
			Action.Filename:=TranslateMUI("notepad.exe",470) ".txt" ;"New Textfile" ".txt"
		else
			Action.Filename:=TranslateMUI("shell32.dll",8587) " " TranslateMUI("notepad.exe",469) ".txt" ;"New" "Textfile" ".txt"
	}
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
	SplitPath, name,, , extension, filename
	Testpath := path "\" name
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=path "\" filename " (" i ")." extension
	}
	FileAppend, %A_Space%, %TestPath%	;Create file and then select it and rename it
	outputdebug % "Testpath" Testpath " exist: " FileExist(TestPath)
	if(!FileExist(TestPath))
	{
		Notify("Could not create new file!", "Could not create a new file here. Make sure you have the correct permissions!", "5", "GC=555555 TC=White MC=White",Vista7 ? 78 : 110)
		; ToolTip(1, "Could not create a new file here. Make sure you have the correct permissions!", "Could not create new file!","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
		; SetTimer, ToolTipClose, -5000
		return 0
	}
	RefreshExplorer()
	Sleep 50
	if(WinActive("ahk_group DesktopGroup")) ;Desktop needs more time for refresh and selecting an item is handled by typing its name
		Sleep 1000
	if(i=1)
		SelectFiles(filename "." extension)
	else
		SelectFiles(filename " (" i ")." extension)
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
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Rename", "Start Renaming", "", "")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Filename")
}
Action_NewFile_Placeholders:
Action_NewFile_GuiShow("", "", "Placeholders")
return

Action_NewFile_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  