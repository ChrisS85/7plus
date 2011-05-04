Action_ExplorerReplaceDialog_Init(Action)
{
	Action.Category := "Explorer"
}
Action_ExplorerReplaceDialog_ReadXML(Action, XMLAction)
{
}
Action_ExplorerReplaceDialog_Execute(Action, Event)
{
	if(!Action.tmpGuiNum)
	{
		result := ExplorerReplaceDialog(Action,Event)
		if(result)
			return 1
		else
			return 0
	}
	return 0
} 
Action_ExplorerReplaceDialog_DisplayString(Action)
{
	return "Show Explorer Rename/Replace dialog"
}
Action_ExplorerReplaceDialog_GuiShow(Action, ActionGUI)
{
}
Action_ExplorerReplaceDialog_GuiSubmit(Action, ActionGUI)
{
}

;Non blocking explorer rename/replace dialog
ExplorerReplaceDialog(Action, Event)
{
	Critical, Off
	if(!hExplorer := WinActive("ahk_group ExplorerGroup"))
		return 0
	GuiNum:=GetFreeGUINum(10)
	Gui, %GuiNum%:Destroy
	Gui, %GuiNum%:Add,Text, x10 y10, Replace in:
	Gui, %GuiNum%:Add,Radio, x77 y10 hwndhFiles gExplorerReplaceDialogFiles, Files
	Gui, %GuiNum%:Add,Radio, x129 y10 hwndhFilenames gExplorerReplaceDialogFilenames, File names
	Gui, %GuiNum%:Add,Text, x10 y36, Replace:
	Gui, %GuiNum%:Add,Edit, x66 y36 w346 hwndhReplace
	Gui, %GuiNum%:Add,Text, x10 y62, With:
	Gui, %GuiNum%:Add,Edit, x66 y61 w346 hwndhWith
	Gui, %GuiNum%:Add,Text, x10 y88, In:
	Gui, %GuiNum%:Add,Edit, x66 y85 w216 hwndhIn
	Gui, %GuiNum%:Add,Checkbox, x291 y87 gExplorerReplaceDialogInSelectedFiles hwndhInSelectedFiles, In selected files only
	Gui, %GuiNum%:Add,Checkbox, x10 y111 hwndhCaseSensitive, Case sensitive
	Gui, %GuiNum%:Add,Checkbox, x10 y134 hwndhRegex, Use regular expressions
	Gui, %GuiNum%:Add,Checkbox, x153 y111 hwndhIncludeDirectories, Include directories
	Gui, %GuiNum%:Add,Checkbox, x153 y134 hwndhIncludeSubdirectories, Include subdirectories
	Gui, %GuiNum%:Add,Button, x175 y162 w75 h23 gExplorerReplaceDialogOK Default, OK
	Gui, %GuiNum%:Add,Button, x256 y162 w75 h23 gExplorerReplaceDialogCancel, Cancel
	Gui, %GuiNum%:Add,Button, x337 y162 w75 h23 gExplorerReplaceDialogApply, Apply
	Action.tmpGuiNum := GuiNum
	Action.tmphFiles := hFiles
	Action.tmphFilenames := hFilenames
	Action.tmphReplace := hReplace
	Action.tmphWith := hWith
	Action.tmphIn := hIn
	Action.tmphInSelectedFiles := hInSelectedFiles
	Action.tmphCaseSensitive := hCaseSensitive
	Action.tmphRegex := hRegex
	Action.tmphIncludeDirectories := hIncludeDirectories
	Action.tmphIncludeSubdirectories := hIncludeSubdirectories
	Gui, %GuiNum%:-Resize -MaximizeBox -MinimizeBox +ToolWindow +LastFound +LabelExplorerReplaceDialog
	Gui, %GuiNum%:Show, AutoSize, Rename / Replace
	hwnd := WinExist("")
	DllCall("SetWindowLong", "Ptr", Hwnd, "int", -8, "PTR", hExplorer)	
	; DllCall("SetParent", "PTR" , hwnd, "PTR", hExplorer)
	return GuiNum
}
ExplorerReplaceDialogFiles:
return
ExplorerReplaceDialogFilenames:
return
ExplorerReplaceDialogInSelectedFiles:
return
ExplorerReplaceDialogOK:
return
ExplorerReplaceDialogCancel:
ExplorerReplaceDialogClose:
Gui, Destroy
return
ExplorerReplaceDialogApply:
return