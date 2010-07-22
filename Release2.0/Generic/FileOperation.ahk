Action_FileOperation_Init(Action)
{
	Action.Category := "File"
	Action.Silent := 0
	Action.Overwrite := 0
}

Action_FileOperation_ReadXML(Action, ActionFileHandle)
{
	Action.Silent := xpath(ActionFileHandle, "/Silent/Text()")
	Action.Overwrite := xpath(ActionFileHandle, "/Overwrite/Text()")
	Action.SourceFile := xpath(ActionFileHandle, "/SourceFile/Text()")
	Action.TargetPath := xpath(ActionFileHandle, "/TargetPath/Text()")
	Action.TargetFile := xpath(ActionFileHandle, "/TargetFile/Text()")
}

Action_FileOperation_DisplayString(Action)
{
	return Action.Type " " Action.So urceFile (Action.TargetPath || Action.TargetFile ? " to " : " ") Action.TargetPath (Action.TargetFile && Action.TargetPath ? "\" : "") Action.TargetFile
}

Action_FileOperation_GuiShow(Action, ActionGUI, GoToLabel = "")
{	
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFile", "", "", "Source file(s):", "Browse", "Action_FileOperation_Browse_Source", "Placeholders", "Action_FileOperation_Placeholders_Source")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetPath", "", "", "Target path:", "Browse", "Action_FileOperation_Browse_Target", "Placeholders", "Action_FileOperation_Placeholders_TargetPath")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target file(s):", "Placeholders", "Action_FileOperation_Placeholders_TargetName")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Silent", "Silent", "", "")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Overwrite", "Overwrite existing files", "", "")
	}
	else if(GoToLabel = "PlaceholdersSource")
		SubEventGUI_Placeholders(sActionGUI, "SourceFile")
	else if(GoToLabel = "Browse_Source")
		SubEventGUI_SelectFile(sActionGUI, "SourceFile")
	else if(GoToLabel = "Browse_Target")
		SubEventGUI_SelectFile(sActionGUI, "TargetPath")
	else if(GoToLabel = "PlaceholdersTargetPath")
		SubEventGUI_Placeholders(sActionGUI, "TargetPath")
	else if(GoToLabel = "PlaceholdersTargetName")
		SubEventGUI_Placeholders(sActionGUI, "TargetFile")	
}
Action_FileOperation_Placeholders_Source:
Action_FileOperation_GuiShow("", "", "PlaceholdersSource")
return
Action_FileOperation_Browse_Source:
Action_FileOperation_GuiShow("", "", "Browse_Source")
return
Action_FileOperation_Browse_Target:
Action_FileOperation_GuiShow("", "", "Browse_Target")
return
Action_FileOperation_Placeholders_TargetPath:
Action_FileOperation_GuiShow("", "", "PlaceholdersTargetPath")
return
Action_FileOperation_Placeholders_TargetName:
Action_FileOperation_GuiShow("", "", "PlaceholdersTargetName")
return

Action_FileOperation_ProcessPaths(Action, Event, ByRef Sources, ByRef Targets, ByRef Flags)
{
	SourceFiles := Event.ExpandPlaceholders(Action.SourceFile)
	TargetPath := Event.ExpandPlaceholders(Action.TargetPath)
	TargetFile := Event.ExpandPlaceholders(Action.TargetFile)
	SplitPath, TargetFile, , , TargetExtension, TargetFilenameNoExt
	files := ToArray(SourceFiles)
	targets := Array()
	Loop % files.len()
	{
		file := files[A_Index]
		SplitPath, file, Filename, Filepath, Extension, FilenameNoExt
		if(!TargetPath)
			target := FilePath
		else
			target := TargetPath
		if(!TargetFile)
			target .= "\" Filename
		else
		{
			target .= "\" TargetFilenameNoExt ;(A_Index = 1 ? "" : " (" A_Index ")") ;Add (4) to multiple file targets
			if(TargetExtension)
				target .= "." TargetExtension
			else
				target .= "." Extension
		}
		sources .= (A_Index = 1 ? "" : "|") file
		targets.append(target)
	}
	target := targets
	targets := ""
	Loop % target.len()
	{
		file := target[A_Index]
		pos := A_Index
		if(!Action.Overwrite)
		{
			;Create new numbered filenames
			Splitpath, file, , path, Extension, NameNoExt
			Loop ;Loop over numbers
			{
				testfile := A_Index = 1 ? file : path "\" NameNoExt " (" A_Index ")." Extension	
				found := false
				if(FileExist(testfile))
					found := true
				if(!found)
				{
					Loop % pos - 1 ;Look through previous targets and see if number needs to be increased
					{
						if(target[A_Index] = testfile)
						{
							found := true
							break
						}
					}
				}
				if(!found)
				{
					target[pos] := testfile
					break
				}
			}			
		}
		targets .= (A_Index = 1 ? "" : "|") target[pos]
	}
	flags := (FOF_MULTIDESTFILES := 0x1) | (FOF_NOCONFIRMMKDIR := 0x200) | (Action.Silent ? (FOF_NO_UI := 0x614) : 0x0) | (Action.Overwrite ? 0x0 : (FOF_RENAMEONCOLLISION := 0x0008))
}	