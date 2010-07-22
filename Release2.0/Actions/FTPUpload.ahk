Action_Upload_Init(Action)
{
	global Settings_Events
	Loop % Settings_Events.len()
	{
		Event := Settings_Events[A_Index]
		Loop % Event.Actions.len()
		{
			if(Event.Actions[A_Index].Type = "Upload")
			{
				OtherAction := Event.Actions[A_Index]
				break
			}
		}		
		if(OtherAction)
			break
	}
	outputdebug("init otheraction " isobject(OtherAction))
	Action.Category := "File"
	Action.Port := (OtherAction ? OtherAction.Port : 21)
	Action.Hostname := (OtherAction ? OtherAction.Hostname : "somehost.com")	
	Action.User := (OtherAction ? OtherAction.User : "username")
	Action.Password := (OtherAction ? OtherAction.Password : "")
	Action.TargetFolder := (OtherAction ? OtherAction.TargetFolder : "Target/Folder/or/empty")
	Action.TargetFile := (OtherAction ? OtherAction.TargetFile : "Filename(+ optionally .extension) / or empty for original filename")
	Action.URL := (OtherAction ? OtherAction.URL : "user.somehost.com")
	Action.Silent := (OtherAction ? OtherAction.Silent : 0)
	Action.Clipboard := (OtherAction ? OtherAction.Clipboard : 1)
}

Action_Upload_ReadXML(Action, ActionFileHandle)
{
	Action.SourceFiles := xpath(ActionFileHandle, "/SourceFiles/Text()")
	Action.Hostname := xpath(ActionFileHandle, "/Hostname/Text()")
	Action.Port := xpath(ActionFileHandle, "/Port/Text()")
	Action.User := xpath(ActionFileHandle, "/User/Text()")
	Action.Password := xpath(ActionFileHandle, "/Password/Text()")
	Action.TargetFolder := xpath(ActionFileHandle, "/TargetFolder/Text()")
	Action.TargetFile := xpath(ActionFileHandle, "/TargetFile/Text()")
	Action.URL := xpath(ActionFileHandle, "/URL/Text()")
	Action.Silent := xpath(ActionFileHandle, "/Silent/Text()")
	Action.Clipboard := xpath(ActionFileHandle, "/Clipboard/Text()")
}

Action_Upload_Execute(Action, Event)
{
	SourceFiles := Event.ExpandPlaceholders(Action.SourceFiles)
	TargetFolder := Event.ExpandPlaceholders(Action.TargetFolder)
	TargetFile := Event.ExpandPlaceholders(Action.TargetFile)
	outputdebug targetfile %targetfile%
	files := ToArray(SourceFiles)
	;Process target filenames
	targets := Array()
	Loop % files.len()
	{
		file := files[A_Index]
		Splitpath, file, filename, , fileextension, filenamenoextension
		SplitPath, TargetFile, , , targetfileextension, targetfilenamenoextension
		if(targetfilenamenoextension && targetfileextension)
			targets.append(targetfilenamenoextension "." targetfileextension)
		else if(targetfilenamenoextension)
			targets.append(targetfilenamenoextension "." fileextension)
		else if(targetfileextension)
			targets.append(filenamenoextension "." targetfileextension)
		else
			targets.append(filename)
		file1 := targets[A_Index]
		SplitPath, file1, ,,CheckExtension, CheckFilenameNoExtension
		outputdebug file1 %file1%
		number := 1
		pos := A_Index
		Loop % pos - 1 ;add (Number) to avoid duplicate filenames
			if(targets[A_Index] = CheckFilenameNoExtension (number > 1 ? " (" number ")" : "") "." CheckExtension)
				number++
		targets[pos] := CheckFilenameNoExtension (number > 1 ? " (" number ")" : "") "." CheckExtension
	}
	decrypted:=Decrypt(Action.Password)
	result:=FtpOpen(Action.Hostname, Action.Port, Action.User, decrypted)
	cliptext=
	if(result=1)
	{
		FtpCreateDirectory(TargetFolder)
		Loop % files.len()
		{
			FullPath := files[A_Index]
			result:=FtpPutFile(FullPath, TargetFolder (TargetFolder ? "/" : "") targets[A_Index]) 
			if(result=0 && !Action.Silent)
			{
				ToolTip(1, "Couldn't upload " TargetFolder (TargetFolder ? "/" : "") targets[A_Index] " properly. Make sure you have write rights and the path exists", "Couldn't upload file","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
				SetTimer, ToolTipClose, -5000
			}
			else if(Action.URL && Action.Clipboard)
				cliptext .= (A_Index = 1 ? "" : "`r`n") Action.URL "/" TargetFolder (TargetFolder ? "/" : "") StringReplace(targets[A_Index], " ", "%20", 1)
		}
		FtpClose()
		if(Action.URL && Action.Clipboard)
			clipboard:=cliptext
		if(!Action.Silent)
		{
			ToolTip(1, "File uploaded" (Action.URL ? " and links copied to clipboard" : ""), "Transfer finished","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
			SetTimer, ToolTipClose, -2000
			SoundBeep
		}
		return 1
	}
	else
	{
		if(!Action.Silent)
		{
			ToolTip(1, "Couldn't connect to " Action.Hostname ". Correct host/username/password?", "Connection Error","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
			SetTimer, ToolTipClose, -5000
		}
		return 0
	}
}
Action_Upload_DisplayString(Action)
{
	return "Upload " Action.SourceFiles " to " Action.Hostname (Action.TargetFolder ? "/" : "") Action.TargetFolder
}

Action_Upload_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		Action.tmpPassword := Action.Password
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFiles", "", "", "Source files:", "Browse", "Action_Upload_Browse", "Placeholders", "Action_Upload_Placeholders_SourceFiles")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Hostname", "", "", "Hostname:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Port", "", "", "Port:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "User", "", "", "Username:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "tmpPassword", "", "", "Password")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Placeholders", "Action_Upload_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target files:", "Placeholders", "Action_Upload_Placeholders_TargetFile")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "URL", "", "", "URL:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Silent", "Silent", "", "")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Clipboard", "Copy links to clipboard", "", "")
	}
	else if(GoToLabel = "Placeholders_SourceFiles")
		SubEventGUI_Placeholders(sActionGUI, "SourceFiles")
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "SourceFiles")
	else if(GoToLabel = "Placeholders_TargetFolder")
		SubEventGUI_Placeholders(sActionGUI, "TargetFolder")
	else if(GoToLabel = "Placeholders_TargetFile")
		SubEventGUI_Placeholders(sActionGUI, "TargetFile")
}
Action_Upload_Placeholders_SourceFiles:
Action_Upload_GuiShow("", "", "Placeholders_SourceFiles")
return
Action_Upload_Browse:
Action_Upload_GuiShow("", "", "Browse")
return
Action_Upload_Placeholders_TargetFolder:
Action_Upload_GuiShow("", "", "Placeholders_TargetFolder")
return
Action_Upload_Placeholders_TargetFile:
Action_Upload_GuiShow("", "", "Placeholders_TargetFile")
return
Action_Upload_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	if(Action.tmpPassword != Action.Password)
		Action.Password := Encrypt(Action.tmpPassword)
	Action.tmpPassword := ""
}