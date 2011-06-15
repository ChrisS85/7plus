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
	if(IsObject(ExplorerWindows.SubItem("hwnd", WinActive("ahk_group ExplorerGroup")).ReplaceDialog))
		Gui, % ExplorerWindows.SubItem("hwnd", WinActive("ahk_group ExplorerGroup")).ReplaceDialog.GUINum ":Show"
	else
	{
		ReplaceDialog := new CReplaceDialog(Action, Event)
		if(IsObject(ReplaceDialog))
		{
			ExplorerWindows.SubItem("hwnd", ReplaceDialog.Parent).ReplaceDialog := ReplaceDialog
			return 1
		}
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
		AddToolTip(hWith, "Use $1, $2, ...$(10)... for accessing regex subpatterns in the replace string")
		Gui, % this.GUINum ":Add",Text, x10 y88, In:
		Gui, % this.GUINum ":Add",Edit, x66 y84 w216 hwndhIn
		AddToolTip(hIn, "You may use wildcards here and use "","" as delimiter. Example: ""*.txt,text*""")
		Gui, % this.GUINum ":Add",Checkbox, x291 y87 hwndhInSelectedFiles, In selected files only
		Gui, % this.GUINum ":Add",Checkbox, x420 y36 hwndhCaseSensitive, Case sensitive
		Gui, % this.GUINum ":Add",Checkbox, x420 y59 hwndhRegex, Use regular expressions
		Gui, % this.GUINum ":Add",Checkbox, x563 y36 hwndhIncludeDirectories, Include directories
		Gui, % this.GUINum ":Add",Checkbox, x563 y59 hwndhIncludeSubdirectories, Include subdirectories
		Gui, % this.GUINum ":Add", Text, x420 y87, Action for colliding filenames:
		Gui, % this.GUINum ":Add", DropDownList, x563 y83 hwndhCollidingAction, Append (Number)||Skip
		Gui, % this.GUINum ":Add", ListView, x10 y120 w672 h310 hwndhListView gExplorerReplaceDialogListView Grid AltSubmit Checked NoSort ReadOnly, Old File|Path|New File
		LV_ModifyCol(1, 234)
		LV_ModifyCol(2, 200)
		LV_ModifyCol(3, 234)
		
		;Quick & Dirty
		;Filenames
		Gui, % this.GUINum ":Add", Groupbox, x+10 y11 w300 h420 Section, Quick && Dirty
		Gui, % this.GUINum ":Add", Text, xs+10 ys+20 hwndhInfo, Use these elements to quickly change things!
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhPrefix gExplorerReplaceDialogPrefix, Add prefix:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhPrefixEdit
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhSuffix  gExplorerReplaceDialogSuffix, Add suffix:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhSuffixEdit
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhChangeExtension  gExplorerReplaceDialogChangeExtension, Change extension:
		Gui, % this.GUINum ":Add",Edit, xs+249 y+-16 w40 hwndhChangeExtensionEdit
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhTrimStart  gExplorerReplaceDialogTrimStart, Trim characters from start:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhTrimStartEdit
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhTrimend  gExplorerReplaceDialogTrimEnd, Trim characters from end:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhTrimEndEdit
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhInsertChars  gExplorerReplaceDialogInsertChars, Insert
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhInsertCharsEdit
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhInsertCharsPosText, at position
		Gui, % this.GUINum ":Add",Edit, x+173 y+-16 w40 hwndhInsertCharsPos
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhInsertCharsDirText, relative to
		Gui, % this.GUINum ":Add",DropDownList, x+115 y+-16 w100 hwndhInsertCharsDir, Start||End	
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhRemoveChars  gExplorerReplaceDialogRemoveChars, Remove
		Gui, % this.GUINum ":Add",Edit, x+175 y+-16 w40 hwndhRemoveCharsLen
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhRemoveCharsPosText, character(s) at position
		Gui, % this.GUINum ":Add",Edit, xs+247 y+-16 w40 hwndhRemoveCharsPos
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhRemoveCharsDirText, relative to
		Gui, % this.GUINum ":Add",DropDownList, x+115 y+-16 w100 hwndhRemoveCharsDir, Start||End		
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhChangeCase  gExplorerReplaceDialogChangeCase, Change case to:
		Gui, % this.GUINum ":Add",DropDownList, x+77 y+-16 hwndhTrimChangeCaseList w100, UPPER||lower|Start Case
		Gui, % this.GUINum ":Add", Checkbox, xs+26 y+10 hwndhChangeCaseExtension, Include extension
		
		;Files
		Gui, % this.GUINum ":Add", Text, xs+10 ys+20 hwndhWarning Hidden, Caution: The options below can find many matches!
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhPrefixLine gExplorerReplaceDialogPrefixLine Hidden, Add line prefix:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhPrefixLineEdit Hidden
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhSuffixLine  gExplorerReplaceDialogSuffixLine Hidden, Add line suffix:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhSuffixLineEdit Hidden
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhTrimLineStart  gExplorerReplaceDialogTrimLineStart Hidden, Trim characters from start of line:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhTrimLineStartEdit Hidden
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhTrimLineEnd  gExplorerReplaceDialogTrimLineEnd Hidden, Trim characters from end of line:
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhTrimLineEndEdit Hidden
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhInsertLineChars gExplorerReplaceDialogInsertLineChars Hidden, Insert
		Gui, % this.GUINum ":Add",Edit, xs+189 y+-16 w100 hwndhInsertLineCharsEdit Hidden
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhInsertLineCharsPosText Hidden, at position
		Gui, % this.GUINum ":Add",Edit, x+173 y+-16 w40 hwndhInsertLineCharsPos Hidden
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhInsertLineCharsDirText Hidden, relative to
		Gui, % this.GUINum ":Add",DropDownList, x+115 y+-16 w100 hwndhInsertLineCharsDir Hidden, line start||line end	
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhRemoveLineChars gExplorerReplaceDialogRemoveLineChars Hidden, Remove
		Gui, % this.GUINum ":Add",Edit, x+175 y+-16 w40 hwndhRemoveLineCharsLen Hidden
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhRemoveLineCharsPosText Hidden, character(s) at position
		Gui, % this.GUINum ":Add",Edit, xs+247 y+-16 w40 hwndhRemoveLineCharsPos Hidden
		Gui, % this.GUINum ":Add", Text, xs+26 y+10 hwndhRemoveLineCharsDirText Hidden, relative to
		Gui, % this.GUINum ":Add",DropDownList, x+115 y+-16 w100 hwndhRemoveLineCharsDir Hidden, line start||line end		
		
		
		
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhTabsToSpaces  gExplorerReplaceTabsToSpaces Hidden, Convert tabs to
		Gui, % this.GUINum ":Add",Edit, x+83 y+-16 w40 hwndhTabsToSpacesEdit Hidden, 4
		Gui, % this.GUINum ":Add", Text, x+10 y+-18 hwndhTabsToSpacesText Hidden, spaces
		Gui, % this.GUINum ":Add", Checkbox, xs+10 y+10 hwndhSpacesToTabs  gExplorerReplaceSpacesToTabs Hidden, Convert spaces to
		Gui, % this.GUINum ":Add",Edit, x+69 y+-16 w40 hwndhSpacesToTabsEdit Hidden, 4
		Gui, % this.GUINum ":Add", Text, x+10 y+-18 hwndhSpacesToTabsText Hidden, tabs
		
		
		Gui, % this.GUINum ":Add",Button, x10 y440 w75 h23 gExplorerReplaceDialogRegEx, RegEx Help
		Gui, % this.GUINum ":Add",Button, x445 y440 w75 h23 gExplorerReplaceDialogSearch Default, Search
		Gui, % this.GUINum ":Add",Button, x526 y440 w75 h23 Disabled gExplorerReplaceDialogReplace hwndhReplaceButton, Replace
		Gui, % this.GUINum ":Add",Button, x607 y440 w75 h23 hwndhCancel gExplorerReplaceDialogCancel, Cancel
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
		
		this.QuicknDirtyFiles := Object()
		this.QuicknDirtyFiles.hWarning := hWarning
		this.QuicknDirtyFiles.hPrefixLine := hPrefixLine
		this.QuicknDirtyFiles.hPrefixLineEdit := hPrefixLineEdit
		this.QuicknDirtyFiles.hSuffixLine := hSuffixLine
		this.QuicknDirtyFiles.hSuffixLineEdit := hSuffixLineEdit
		this.QuicknDirtyFiles.hTrimLineStart := hTrimLineStart
		this.QuicknDirtyFiles.hTrimLineStartEdit := hTrimLineStartEdit
		this.QuicknDirtyFiles.hTrimLineEnd := hTrimLineEnd
		this.QuicknDirtyFiles.hTrimLineEndEdit := hTrimLineEndEdit
		this.QuicknDirtyFiles.hRemoveLineChars := hRemoveLineChars
		this.QuicknDirtyFiles.hRemoveLineCharsLen := hRemoveLineCharsLen
		this.QuicknDirtyFiles.hRemoveLineCharsPosText := hRemoveLineCharsPosText
		this.QuicknDirtyFiles.hRemoveLineCharsPos := hRemoveLineCharsPos
		this.QuicknDirtyFiles.hRemoveLineCharsDirText := hRemoveLineCharsDirText
		this.QuicknDirtyFiles.hRemoveLineCharsDir := hRemoveLineCharsDir
		this.QuicknDirtyFiles.hInsertLineChars := hInsertLineChars
		this.QuicknDirtyFiles.hInsertLineCharsEdit := hInsertLineCharsEdit
		this.QuicknDirtyFiles.hInsertLineCharsPosText := hInsertLineCharsPosText
		this.QuicknDirtyFiles.hInsertLineCharsPos := hInsertLineCharsPos
		this.QuicknDirtyFiles.hInsertLineCharsDirText := hInsertLineCharsDirText
		this.QuicknDirtyFiles.hInsertLineCharsDir := hInsertLineCharsDir
		this.QuicknDirtyFiles.hTabsToSpaces := hTabsToSpaces
		this.QuicknDirtyFiles.hTabsToSpacesEdit := hTabsToSpacesEdit
		this.QuicknDirtyFiles.hTabsToSpacesText := hTabsToSpacesText
		this.QuicknDirtyFiles.hSpacesToTabs := hSpacesToTabs
		this.QuicknDirtyFiles.hSpacesToTabsEdit := hSpacesToTabsEdit
		this.QuicknDirtyFiles.hSpacesToTabsText := hSpacesToTabsText
		
		this.QuicknDirtyFilenames := Object()
		this.QuicknDirtyFilenames.hInfo := hInfo
		this.QuicknDirtyFilenames.hPrefix := hPrefix
		this.QuicknDirtyFilenames.hPrefixEdit := hPrefixEdit
		this.QuicknDirtyFilenames.hSuffix := hSuffix
		this.QuicknDirtyFilenames.hSuffixEdit := hSuffixEdit
		this.QuicknDirtyFilenames.hChangeExtension := hChangeExtension
		this.QuicknDirtyFilenames.hChangeExtensionEdit := hChangeExtensionEdit
		this.QuicknDirtyFilenames.hTrimStart := hTrimStart
		this.QuicknDirtyFilenames.hTrimStartEdit := hTrimStartEdit
		this.QuicknDirtyFilenames.hTrimend := hTrimend
		this.QuicknDirtyFilenames.hTrimEndEdit := hTrimEndEdit
		this.QuicknDirtyFilenames.hRemoveChars := hRemoveChars
		this.QuicknDirtyFilenames.hRemoveCharsLen := hRemoveCharsLen
		this.QuicknDirtyFilenames.hRemoveCharsPosText := hRemoveCharsPosText
		this.QuicknDirtyFilenames.hRemoveCharsPos := hRemoveCharsPos
		this.QuicknDirtyFilenames.hRemoveCharsDirText := hRemoveCharsDirText
		this.QuicknDirtyFilenames.hRemoveCharsDir := hRemoveCharsDir
		this.QuicknDirtyFilenames.hInsertChars := hInsertChars
		this.QuicknDirtyFilenames.hInsertCharsEdit := hInsertCharsEdit
		this.QuicknDirtyFilenames.hInsertCharsPosText := hInsertCharsPosText
		this.QuicknDirtyFilenames.hInsertCharsPos := hInsertCharsPos
		this.QuicknDirtyFilenames.hInsertCharsDirText := hInsertCharsDirText
		this.QuicknDirtyFilenames.hInsertCharsDir := hInsertCharsDir
		this.QuicknDirtyFilenames.hChangeCase := hChangeCase
		this.QuicknDirtyFilenames.hTrimChangeCaseList := hTrimChangeCaseList
		this.QuicknDirtyFilenames.hChangeCaseExtension := hChangeCaseExtension
		
		this.hReplaceButton := hReplaceButton
		this.hCancel := hCancel
		Gui, % this.GUINum ":-Resize -MaximizeBox -MinimizeBox +ToolWindow +LastFound +LabelExplorerReplaceDialog"
		Gui, % this.GUINum ":Show", AutoSize, Rename / Replace
		this.hWnd := WinExist()
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
		if(this.InString)
		{
			this.InString := RegexReplace(this.InString, "(\\|\.|\?|\+|\[|\{|\||\(|\)|\^|\$)", "\$1") ;Escaping
			this.InString := RegexReplace(this.InString, "\*", ".*?") ;Wildcard
			this.InString := "^" RegexReplace(this.InString, ",", "$|^") "$" ;start and end of line
		}
		this.InSelectedFiles := ControlGet("Checked","","","ahk_id " this.hInSelectedFiles)
		this.CaseSensitive := ControlGet("Checked","","", "ahk_id " this.hCaseSensitive)
		this.Regex := ControlGet("Checked","","", "ahk_id " this.hRegex)
		this.IncludeDirectories := ControlGet("Checked","", "", "ahk_id " this.hIncludeDirectories)
		this.IncludeSubdirectories := ControlGet("Checked", "", "", "ahk_id " this.hIncludeSubdirectories)
		this.CollidingAction := ControlGetText("", "ahk_id " this.hCollidingAction)
		this.SearchResults := Array()
		LV_Delete()
		if(this.Regex && !this.CaseSensitive && InStr(this.SearchString, "i)") != 1) ;Case sensitive for regex is done here to save some time
			this.SearchString := "i)" this.SearchString
		WinSetTitle, % "ahk_id " this.hWnd,,Searching...,
		ControlSetText,, Stop, % "ahk_id " this.hCancel
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
			if(!this.Stop)
			{
				this.CheckForDuplicates(this.DirectoryTree, AppendPaths(this.DirectoryTree.Path, this.DirectoryTree.Name), Array())
				if(!this.Stop)
				{
					this.FlattenTree(this.DirectoryTree)
					if(!this.Stop)
					{
						Loop % this.SearchResults.len()
						{
							if(this.Stop)
								break
							LV_Add("Check", this.SearchResults[A_Index].Name, strTrimLeft(this.SearchResults[A_Index].Path,BasePath), this.SearchResults[A_Index].FixedNewFilename ? this.SearchResults[A_Index].FixedNewFilename : this.SearchResults[A_Index].NewFilename)
						}
					}
				}
			}
		}
		else
		{
			this.BasePath := ExplorerWindows.SubItem("hwnd", this.Parent).Path
			this.FileContentSearch()
			if(!this.Stop)
			{
				Loop % this.SearchResults.len()
				{
					if(this.Stop)
						break
					index := A_Index
					Loop % this.SearchResults[A_Index].Lines.len()
					{
						if(this.Stop)
							break
						LV_Add("Check", strTrimLeft(this.SearchResults[A_Index].Path,this.BasePath), this.SearchResults[index].Lines[A_Index].Line, RegexReplace(this.SearchResults[index].Lines[A_Index].Text, "D)(*ANYCRLF)\R$",""), RegexReplace(this.SearchResults[index].Lines[A_Index].NewText, "D)(*ANYCRLF)\R$",""))
					}
				}
			}
		}
		if(this.Stop)
		{
			this.Remove("SearchResults")
			this.Remove("DirectoryTree")
			this.Remove("BasePath")
			LV_Delete()
			Control, Disable,,, % "ahk_id " this.hReplaceButton
			this.Remove("Stop")
		}
		if(this.SearchResults.len() > 0)
			Control, Enable,,, % "ahk_id " this.hReplaceButton
		WinSetTitle, % "ahk_id " this.hWnd,,Rename / Replace
		ControlSetText,, Cancel, % "ahk_id " this.hCancel
	}
	
	; Directory structure must be kept. To archive this, a directory tree object ("DirectoryTree") is created recursively here.
	; This allows to rename the files by using a wide search and constructing the current paths from the tree.
	CreateFilenameSearchTree(Root)
	{
		if(this.Stop)
			return 0
		if(this.InSelectedFiles && Root = this.DirectoryTree) ;Base directory, skip files which are not in selection
			Selection := ToArray(GetSelectedFiles(1, this.Parent))
		items := 0
		Loop % AppendPaths(AppendPaths(Root.Path, Root.Name), "*"), 1, 0
		{
			if(this.Stop)
				return 0
			File := Array()
			SplitPath, A_LoopFileLongPath,,Path
			File.Path := Path
			File.Name := A_LoopFileName
			File.Directory := InStr(FileExist(A_LoopFileLongPath), "D")
			if(IsObject(Selection) && Selection.IndexOf(A_LoopFileLongPath) = 0) ;If selection exists and this file is not in it, skip it
				continue
			if(this.InString && !RegexMatch(A_LoopFileName,this.InString))
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
			if(this.Stop)
				return 0
			if(Root[A_Index].NewFilename)
				this.SearchResults.Append(Root[A_Index])
			if(Root[A_Index].Directory)
				this.FlattenTree(Root[A_Index])
		}
	}
	
	;This function checks for duplicates and modifies the new filenames appropriately
	CheckForDuplicates(Root, RootPath, PathsList)
	{
		index := 1
		len := Root.len()
		Loop % len
		{
			if(this.Stop)
				return 0
			OldPath := AppendPaths(RootPath, Root[index].Name)
			NewPath := Root[index].NewFilename ? AppendPaths(RootPath, Root[index].NewFilename) : OldPath
			if(this.CollidingAction = "Append (Number)")
			{
				SplitPath, NewPath,, dir, extension, filename
				i:=1 ;Find free filename
				while(FileExist(NewPath) || PathsList.IndexOf(NewPath)) ;Check for existing files on hdd and for target files from this rename operation
				{
					i++
					NewPath:=dir "\" filename " (" i ")" (extension = "" ? "" : "." extension)
				}
				if(i > 1)
					Root[index].FixedNewFilename := filename " (" i ")" (extension = "" ? "" : "." extension)
			}
			if(this.CollidingAction = "Skip" && FileExist(NewPath) || PathsList.IndexOf(NewPath))
			{
				Root.Remove(Index)
				continue
			}
			PathsList.append(NewPath)
			if(Root[index].Directory)
				this.CheckForDuplicates(Root[index], NewPath, PathsList)
			index++
		}
	}
	
	;This function performs the actual renaming
	;TODO check overwrite modes here and adjust paths based on rename success
	PerformFileNameReplace(Root, RootPath)
	{
		Loop % Root.len()
		{
			if(this.Stop)
				return 0
			OldPath := AppendPaths(RootPath, Root[A_Index].Name)
			NewPath := AppendPaths(RootPath, Root[A_Index].FixedNewFilename ? Root[A_Index].FixedNewFilename : Root[A_Index].NewFilename)
			if(Root[A_Index].Enabled && Root[A_Index].NewFilename)
			{
				if(!Root[A_Index].Directory)
					FileMove, %OldPath%, %NewPath%, 0
				else
					FileMoveDir, %OldPath%, %NewPath%, 0
			}
			if(Root[A_Index].Directory)
				this.PerformFileNameReplace(Root[A_Index], Root[A_Index].Enabled && Root[A_Index].NewFilename ? NewPath : OldPath)
		}
	}
	
	;tests a filename for replacement
	ProcessFilename(File)
	{
		if(this.Regex)
		{			
			NewFilename := RegexReplace(File.Name, this.SearchString, this.ReplaceString, Count) ;Case insensitivity is handled before
			if(Count)
				File.NewFilename := NewFilename
			return Count > 0
		}
		else
		{
			if(this.CaseSensitive)
				StringCaseSense, On
			NewFilename := StringReplace(File.Name, this.SearchString, this.ReplaceString, "All")
			if(!Errorlevel)
				File.NewFilename := NewFilename
			StringCaseSense, Off
			return !ErrorLevel
		}
	}
	;Tests if a specific line should be replaced
	ProcessLine(File, Text, LineNumber)
	{
		if(this.Regex)
		{			
			NewText := RegexReplace(Text, this.SearchString, this.ReplaceString, Count) ;Case insensitivity is handled before
			if(Count)
				File.Lines.Append(Object("Line", LineNumber, "Text", Text, "NewText", NewText, "Enabled", true))
			return Count > 0
		}
		else
		{
			if(this.CaseSensitive)
				StringCaseSense, On
			NewText := StringReplace(Text, this.SearchString, this.ReplaceString, "All")
			if(!Errorlevel)
				File.Lines.Append(Object("Line", LineNumber, "Text", Text, "NewText", NewText, "Enabled", true))
			StringCaseSense, Off
			return !ErrorLevel
		}
	}
	FileContentSearch()
	{
		if(this.InSelectedFiles) ;skip files which are not in selection
			Selection := ToArray(GetSelectedFiles(1, this.Parent))
		items := 0
		Loop % AppendPaths(this.BasePath, "*"), 0, % this.IncludeSubdirectories
		{
			if(this.Stop)
				return 0
			File := Object()
			File.Path := A_LoopFileLongPath
			File.Lines := Array()
			if(IsObject(Selection) && Selection.IndexOf(A_LoopFileLongPath) = 0) ;If selection exists and this file is not in it, skip it
				continue
			if(this.InString && !RegexMatch(A_LoopFileName,this.InString)) ;Check filter regex
				continue
			f := FileOpen(A_LoopFileLongPath, "r")			
			;Detect file encoding
			if f.Pos == 3 
				File.cp := "UTF-8"
			else if f.Pos == 2 
				File.cp := "UTF-16 "
			else 
				File.cp := "CP0" 
			while(!f.AtEOF)
			{
				if(this.Stop)
				{
					f.Close()
					return 0
				}
				Line := f.ReadLine()
				if(this.ProcessLine(File, Line, A_Index))
					this.SearchResults.Append(File)
			}
			f.Close()
		}
	}
	PerformFileContentReplace()
	{
		Loop % this.SearchResults.len()
		{
			index := A_Index
			Lines := ""
			output := ""
			Loop % this.SearchResults[index].Lines.len() ;Small loop to speed it up a bit for large files
			{
				if(this.SearchResults[index].Lines[A_Index].Enabled)
					Lines .= "," this.SearchResults[index].Lines[A_Index].Line
			}
			if(Lines = "")
				continue
			f := FileOpen(this.SearchResults[index].Path, "r") 			
			;Generate new file content
			while(!f.AtEOF)
			{
				if(this.Stop)
				{
					f.Close()
					return 0
				}
				Line := f.ReadLine()
				if(InStr(Lines, "," A_Index))
					output .= this.SearchResults[index].Lines.SubItem("Line", A_Index).NewText
				else
					output .= Line
			}
			f.Close()
			
			;Write the replaced text back into the file
			FileDelete, % this.SearchResults[index].Path
			f := FileOpen(this.SearchResults[index].Path, "rw", this.SearchResults[index].cp)
			f.Write(output)
			f.Close()
		}
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
			if(A_GUIEvent = "I") ;Check/Uncheck
			{
				if(ErrorLevel == "C") ;Check
					Enabled := true
				else if(ErrorLevel == "c") ;Uncheck
					Enabled := false
				 LV_GetText(Path, A_EventInfo, 1)
				 LV_GetText(LineNumber, A_EventInfo, 2)
				 Result := this.SearchResults.SubItem("Path", AppendPaths(this.BasePath,Path)).Lines.SubItem("Line", LineNumber)
				Result.Enabled := Enabled
			}
		}
	}
	Replace()
	{
		global ExplorerWindows		
		WinSetTitle, % "ahk_id " this.hWnd,,Searching...,
		if(this.Filenames)
			this.PerformFileNameReplace(this.DirectoryTree, AppendPaths(this.DirectoryTree.Path, this.DirectoryTree.Name))
		else
			this.PerformFileContentReplace()
		if(this.Stop)
		{
			this.Remove("SearchResults")
			this.Remove("DirectoryTree")
			this.Remove("BasePath")
			this.Remove("Stop")
			LV_Delete()
			WinSetTitle, % "ahk_id " this.hWnd,,Rename / Replace
			ControlSetText,, Cancel, % "ahk_id " this.hCancel
			Control, Disable,,, % "ahk_id " this.hReplaceButton
		}
		ExplorerWindows.SubItem("hwnd", this.Parent).Remove("ReplaceDialog")
	}
}
ExplorerReplaceDialogFiles:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		SetControlDelay, 0
		Control, Disable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIncludeDirectories
		Control, Disable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hCollidingAction
		enum := ExplorerWindows[A_Index].ReplaceDialog.QuicknDirtyFilenames._newEnum()
		while enum[key,value]
			Control, Hide,,,  ahk_id %value%
		enum := ExplorerWindows[A_Index].ReplaceDialog.QuicknDirtyFiles._newEnum()
		while enum[key,value]
			Control, Show,,, ahk_id %value%
		LV_ModifyCol(1,100, "File")
		LV_ModifyCol(2,38, "Line")
		LV_ModifyCol(3,265, "Text")
		if(LV_GetCount("Col") = 3)
		{
			LV_Delete()
			ExplorerWindows[A_Index].ReplaceDialog.Remove("SearchResults")
			ExplorerWindows[A_Index].ReplaceDialog.Remove("DirectoryTree")
			ExplorerWindows[A_Index].ReplaceDialog.Remove("BasePath")
			LV_InsertCol(4,265, "Replaced Text")
		}
	}
return
ExplorerReplaceDialogFilenames:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{		
		SetControlDelay, 0
		Control, Enable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hIncludeDirectories
		Control, Enable,,, % "ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hCollidingAction
		enum := ExplorerWindows[A_Index].ReplaceDialog.QuicknDirtyFiles._newEnum()
		while enum[key,value]
			Control, Hide,,,  ahk_id %value%
		enum := ExplorerWindows[A_Index].ReplaceDialog.QuicknDirtyFilenames._newEnum()
		while enum[key,value]
			Control, Show,,,  ahk_id %value%
		if(LV_GetCount("Col") = 4)
		{
			LV_Delete()
			ExplorerWindows[A_Index].ReplaceDialog.Remove("SearchResults")
			ExplorerWindows[A_Index].ReplaceDialog.Remove("BasePath")
			LV_DeleteCol(4)
		}
		LV_ModifyCol(1,234, "Old File")
		LV_ModifyCol(2,200, "Path")
		LV_ModifyCol(3,234, "New File")
	}
return
ExplorerReplaceDialogPrefix:
return
ExplorerReplaceDialogSuffix:
return
ExplorerReplaceDialogChangeExtension:
return
ExplorerReplaceDialogTrimStart:
return
ExplorerReplaceDialogTrimEnd:
return
ExplorerReplaceDialogChangeCase:
return
ExplorerReplaceDialogRemoveChars:
return
ExplorerReplaceDialogInsertChars:
return
ExplorerReplaceDialogPrefixLine:
return
ExplorerReplaceDialogSuffixLine:
return
ExplorerReplaceDialogTrimLineStart:
return
ExplorerReplaceDialogTrimLineEnd:
return
ExplorerReplaceDialogRemoveLineChars:
return
ExplorerReplaceDialogInsertLineChars:
return
ExplorerReplaceTabsToSpaces:
return
ExplorerReplaceSpacesToTabs:
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
Loop % ExplorerWindows.len()
{
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		if(ControlGetText("","ahk_id " ExplorerWindows[A_Index].ReplaceDialog.hCancel) = "Stop")
			ExplorerWindows[A_Index].ReplaceDialog.Stop := true
		else
			ExplorerWindows[A_Index].Remove("ReplaceDialog")
	}
}
return
ExplorerReplaceDialogClose:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
	{
		ExplorerWindows[A_Index].ReplaceDialog.Stop := true
		ExplorerWindows[A_Index].Remove("ReplaceDialog")
	}
return
ExplorerReplaceDialogReplace:
Loop % ExplorerWindows.len()
	if(ExplorerWindows[A_Index].ReplaceDialog.GUINum = A_GUI)
		ExplorerWindows[A_Index].ReplaceDialog.Replace()
return
ExplorerReplaceDialogRegEx:
run http://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm
return