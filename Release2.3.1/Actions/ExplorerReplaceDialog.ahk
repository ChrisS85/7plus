Action_ExplorerReplaceDialog_Init(Action)
{
	Action.Category := "Explorer"
}
Action_ExplorerReplaceDialog_ReadXML(Action, XMLAction)
{
}
Action_ExplorerReplaceDialog_Execute(Action, Event)
{
	global ExplorerWindows, CReplaceDialog
	ReplaceDialog := new CReplaceDialog(Action, Event)
	if(IsObject(ReplaceDialog))
	{
		ExplorerWindows.SubItem("hwnd", ReplaceDialog.Parent).ReplaceDialog := ReplaceDialog
		return 1
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
Class CReplaceDialog
{
	__New(Action, Event)
	{
		global ExplorerWindows
		Critical, Off
		if(!this.Parent := WinActive("ahk_group ExplorerGroup"))
			return 0
		if(IsObject(ExplorerWindows.SubItem("hwnd", this.Parent).ReplaceDialog))
			return 0
		this.GUINum:=GetFreeGUINum(10)
		if(!this.GUINum)
			return 0
		Gui, % this.GUINum ":Default"
		Gui, % this.GUINum ":Add",Text, x10 y10, Replace in:
		Gui, % this.GUINum ":Add",Radio, x77 y10 hwndhFilenames gExplorerReplaceDialogFilenames Checked, File names
		Gui, % this.GUINum ":Add",Radio, x150 y10 hwndhFiles gExplorerReplaceDialogFiles, Files
		Gui, % this.GUINum ":Add",Text, x10 y36, Replace:
		Gui, % this.GUINum ":Add",Edit, x66 y35 w346 hwndhReplace
		Gui, % this.GUINum ":Add",Text, x10 y62, With:
		Gui, % this.GUINum ":Add",Edit, x66 y60 w346 hwndhWith
		Gui, % this.GUINum ":Add",Text, x10 y88, In:
		Gui, % this.GUINum ":Add",Edit, x66 y84 w216 hwndhIn
		Gui, % this.GUINum ":Add",Checkbox, x291 y87 gExplorerReplaceDialogInSelectedFiles hwndhInSelectedFiles, In selected files only
		Gui, % this.GUINum ":Add",Checkbox, x10 y121 hwndhCaseSensitive, Case sensitive
		Gui, % this.GUINum ":Add",Checkbox, x10 y144 hwndhRegex, Use regular expressions
		Gui, % this.GUINum ":Add",Checkbox, x153 y121 hwndhIncludeDirectories, Include directories
		Gui, % this.GUINum ":Add",Checkbox, x153 y144 hwndhIncludeSubdirectories, Include subdirectories
		Gui, % this.GUINum ":Add", Text, x10 y172, Action for colliding filenames:
		Gui, % this.GUINum ":Add", DropDownList, x153 y168 hwndhCollidingAction, Ask||Append (Number)|Skip
		Gui, % this.GUINum ":Add", ListView, x10 y200 w402 h310 hwndhListView gExplorerReplaceDialogListView Grid AltSubmit Checked NoSort ReadOnly, Old File|Path|New File
		LV_ModifyCol(1, 150)
		LV_ModifyCol(2, 100)
		LV_ModifyCol(3, 145)		
		Gui, % this.GUINum ":Add",Button, x10 y520 w75 h23 gExplorerReplaceDialogRegEx, RegEx Help
		Gui, % this.GUINum ":Add",Button, x175 y520 w75 h23 gExplorerReplaceDialogSearch Default, Search
		Gui, % this.GUINum ":Add",Button, x256 y520 w75 h23 Disabled gExplorerReplaceDialogReplace hwndhReplaceButton, Replace
		Gui, % this.GUINum ":Add",Button, x337 y520 w75 h23 gExplorerReplaceDialogCancel, Cancel
		this.hFiles := hFiles
		this.hFilenames := hFilenames
		this.hReplace := hReplace
		this.hWith := hWith
		this.hIn := hIn
		this.hInSelectedFiles := hInSelectedFiles
		this.hCaseSensitive := hCaseSensitive
		this.hRegex := hRegex
		this.hIncludeDirectories := hIncludeDirectories
		this.hIncludeSubdirectories := hIncludeSubdirectories
		this.hCollidingAction := hCollidingAction
		this.hReplaceButton := hReplaceButton
		Gui, % this.GUINum ":-Resize -MaximizeBox -MinimizeBox +ToolWindow +LastFound +LabelExplorerReplaceDialog"
		Gui, % this.GUINum ":Show", AutoSize, Rename / Replace
		ControlFocus , , ahk_id %hReplace%
		AttachToolWindow(this.Parent, this.GUINum, True)
	}
	__Delete()
	{
		Gui, % this.GUINum ":Destroy"
	}
	
	;Performs a search and shows the results in the preview listview
	Search()
	{
		global ExplorerWindows
		this.Filenames := ControlGet("Checked","","","ahk_id " this.hFilenames)
		this.SearchString := ControlGetText("","ahk_id " this.hReplace)
		this.ReplaceString := ControlGetText("","ahk_id " this.hWith)
		this.InString := ControlGetText("", "ahk_id " this.hIn)
		this.InSelectedFiles := ControlGet("Checked","","","ahk_id " this.hInSelectedFiles)
		this.CaseSensitive := ControlGetText("", "ahk_id " this.hCaseSensitive)
		this.Regex := ControlGetText("", "ahk_id " this.hRegex)
		this.IncludeDirectories := ControlGetText("", "ahk_id " this.hIncludeDirectories)
		this.IncludeSubdirectories := ControlGetText("", "ahk_id " this.hIncludeSubdirectories)
		this.CollidingAction := ControlGetText("", "ahk_id " this.hCollidingAction)
		this.SearchResults := Array()
		LV_Delete()
		if(this.Filenames)
		{
			this.DirectoryTree := Array()
			this.DirectoryTree.Directory := true			
			BasePath := ExplorerWindows.SubItem("hwnd", this.Parent).Path
			SplitPath, BasePath,Name,Path
			this.BasePath := BasePath
			this.DirectoryTree.Path := Path
			this.DirectoryTree.Name := Name
			this.CreateFilenameSearchTree(this.DirectoryTree)
			this.FlattenTree(this.DirectoryTree)
			Loop % this.SearchResults.len()
				LV_Add("Check", this.SearchResults[A_Index].Name, strTrimLeft(this.SearchResults[A_Index].Path,BasePath), this.SearchResults[A_Index].NewFilename)
			if(this.SearchResults.len() > 0)
				Control, Enable,,, % "ahk_id " this.hReplaceButton
		}
		else
			this.FileContentSearch()
	}
	
	; Directory structure must be kept. To archive this, a directory tree object ("DirectoryTree") is created recursively here.
	; This allows to rename the files by using a wide search and constructing the current paths from the tree.
	CreateFilenameSearchTree(Root)
	{
		if(this.InSelectedFiles && Root = this.DirectoryTree) ;Base directory, skip files which are not in selection
			Selection := ToArray(GetSelectedFiles(1, this.Parent))
		msgbox % exploreObj(selection)
		msgbox % GetSelectedFiles(1, this.Parent)
		items := 0
		Loop % AppendPaths(AppendPaths(Root.Path, Root.Name), "*"), 1, % this.IncludeSubdirectories
		{
			File := Array()
			SplitPath, A_LoopFileLongPath,,Path
			File.Path := Path
			File.Name := A_LoopFileName
			File.Directory := InStr(FileExist(A_LoopFileLongPath), "D")
			if(IsObject(Selection) && Selection.IndexOf(A_LoopFileLongPath) = 0) ;If selection exists and this file is not in it, skip it
				continue
			if((File.Directory && ((this.IncludeDirectories && this.ProcessFilename(File)) + (this.IncludeSubdirectories &&this.CreateFilenameSearchTree(File))) > 0 ) || (!File.Directory && this.ProcessFilename(File))) ;If File should be processed itself or contains other files which are processed
			{
				File.enabled := true
				Root.append(File)
				items++
			}
		}
		return items > 0
	}
	
	;Locates a tree item by its Path and Name value
	FindTreeItem(Root, Path, Name)
	{
		Loop % Root.len()
		{
			if(Root[A_Index].Path = Path && Root[A_Index].Name = Name)
				return Root[A_Index]
			if(Root[A_Index].Directory)
			{
				if(IsObject(result := this.FindTreeItem(Root[A_Index], Path, Name)))
					return result
			}
		}
		return 0
	}
	
	;Flattens the directory structure into a single array. Items which won't be renamed will be skipped.
	FlattenTree(Root)
	{
		Loop % Root.len()
		{
			if(Root[A_Index].NewFilename)
				this.SearchResults.Append(Root[A_Index])
			if(Root[A_Index].Directory)
				this.FlattenTree(Root[A_Index])
		}
	}
	
	;This function performs the actual renaming
	;TODO check overwrite modes here and adjust paths based on rename success
	PerformFileNameReplace(Root, RootPath)
	{
		Loop % Root.len()
		{
			OldPath := AppendPaths(RootPath, Root[A_Index].Name)
			NewPath := AppendPaths(RootPath, Root[A_Index].NewFilename)
			if(Root[A_Index].Enabled && Root[A_Index].NewFilename)
			{
				if(!Root[A_Index].Directory)
					FileMove, %OldPath%, %NewPath%, 0
				else
					FileMoveDir, %OldPath%, %NewPath%, 0
			}
			if(Root[A_Index].Directory)
				this.PerformFileNameReplace(Root[A_Index], Root[A_Index].NewFilename ? NewPath : OldPath)
		}
	}
	
	;tests a filename for replacement
	ProcessFilename(File)
	{
		NewFilename := StringReplace(File.Name, this.SearchString, this.ReplaceString, "All")
		if(!Errorlevel)
			File.NewFilename := NewFilename
		return !ErrorLevel
	}
	FileContentSearch()
	{
	
	}
	ListViewEvent()
	{
		if(this.Filenames)
		{
			if(A_GUIEvent = "I") ;Check/Uncheck
			{
				if(ErrorLevel == "C") ;Check
					Enabled := true
				else if(ErrorLevel == "c") ;Uncheck
					Enabled := false
				 LV_GetText(Name, A_EventInfo, 1)
				 LV_GetText(Path, A_EventInfo, 2)
				 Path := AppendPaths(this.BasePath, Path)
				TreeItem := this.FindTreeItem(this.DirectoryTree, Path, Name)
				TreeItem.Enabled := Enabled
			}
		}
		else
		{
		
		}
	}
	Replace()
	{
		global ExplorerWindows
		this.PerformFileNameReplace(this.DirectoryTree, AppendPaths(this.DirectoryTree.Path, this.DirectoryTree.Name))
		ExplorerWindows.SubItem("hwnd", this.Parent).Remove("ReplaceDialog")
	}
}
ExplorerReplaceDialogFiles:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		Control, Disable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIncludeDirectories
		Control, Disable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hCollidingAction
		LV_ModifyCol(1,100, "File")
		LV_ModifyCol(2,35, "Line")
		LV_ModifyCol(3,150, "Text")
		if(LV_GetCount("Col") = 3)
			LV_InsertCol(4,150, "Replaced Text")
	}
return
ExplorerReplaceDialogFilenames:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		Control, Enable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIncludeDirectories
		Control, Enable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hCollidingAction
		if(LV_GetCount("Col") = 4)
			LV_DeleteCol(4)
		LV_ModifyCol(1,150, "Old File")
		LV_ModifyCol(2,100, "Path")
		LV_ModifyCol(3,145, "New File")
	}
return
ExplorerReplaceDialogInSelectedFiles:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		if(ControlGet("Checked", "", "", "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hInSelectedFiles))
			Control, Disable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIn
		else
			Control, Enable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIn
	}
return
ExplorerReplaceDialogListView:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
		ExplorerWindows[A_Index].ReplaceDialog.ListViewEvent()
return
ExplorerReplaceDialogSearch:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
		ExplorerWindows[A_Index].ReplaceDialog.Search()
return
ExplorerReplaceDialogCancel:
ExplorerReplaceDialogClose:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
		ExplorerWindows[A_Index].Remove("ReplaceDialog")
return
ExplorerReplaceDialogReplace:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
		ExplorerWindows[A_Index].ReplaceDialog.Replace()
return
ExplorerReplaceDialogRegEx:
run http://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm
return