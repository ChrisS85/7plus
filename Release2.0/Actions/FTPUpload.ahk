Action_Upload_Init(Action)
{
	Action.Category := "File"
	Action.Port := 21
	Action.Hostname := "somehost.com"
	Action.TargetFolder := "Target/Folder/or/empty"
	Action.URL := "user.somehost.com"
	Action.Silent := 0
	Action.Clipboard := 1
}

Action_Upload_ReadXML(Action, ActionFileHandle)
{
	Action.SourceFiles := xpath(ActionFileHandle, "/SourceFiles/Text()")
	Action.Hostname := xpath(ActionFileHandle, "/Hostname/Text()")
	Action.Port := xpath(ActionFileHandle, "/Port/Text()")
	Action.User := xpath(ActionFileHandle, "/User/Text()")
	Action.Password := xpath(ActionFileHandle, "/Password/Text()")
	Action.TargetFolder := xpath(ActionFileHandle, "/TargetFolder/Text()")
	Action.URL := xpath(ActionFileHandle, "/URL/Text()")
	Action.Silent := xpath(ActionFileHandle, "/Silent/Text()")
	Action.Clipboard := xpath(ActionFileHandle, "/Clipboard/Text()")
}

Action_Upload_Execute(Action, Event)
{
	SourceFiles := Event.ExpandPlaceholders(Action.SourceFiles)
	TargetFolder := Event.ExpandPlaceholders(Action.TargetFolder)
	files := PathsToArray(SourceFiles)
	
	decrypted:=Decrypt(Action.Password)
	result:=FtpOpen(Action.Hostname, Action.Port, Action.User, decrypted)
	cliptext=
	if(result=1)
	{
		FtpCreateDirectory(TargetFolder)
		Loop % files.len()
		{
			FullPath := files[A_Index]
			SplitPath FullPath, file
			result:=FtpPutFile(FullPath, TargetFolder (TargetFolder ? "/" : "") file) 
			if(result=0 && !Action.Silent)
			{
				ToolTip(1, "Couldn't upload " TargetFolder (TargetFolder ? "/" : "") file " properly. Make sure you have write rights and the path exists", "Couldn't upload file","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
				SetTimer, ToolTipClose, -5000
			}
			else if(Action.URL && Action.Clipboard)
				cliptext .= (A_Index = 1 ? "" : "`r`n") Action.URL "/" TargetFolder (TargetFolder ? "\" : "") StringReplace(file, " ", "%20", 1)
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
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFiles", "", "", "Source files:", "Placeholders", "Action_Upload_Placeholders_SourceFiles")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Hostname", "", "", "Hostname:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Port", "", "", "Port:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "User", "", "", "Username:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "tmpPassword", "", "", "Password")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Placeholders", "Action_Upload_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "URL", "", "", "URL:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Silent", "Silent", "", "")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Clipboard", "Copy links to clipboard", "", "")
	}
	else if(GoToLabel = "Placeholders_SourceFiles")
		SubEventGUI_Placeholders(sActionGUI, "SourceFiles")
	else if(GoToLabel = "Placeholders_TargetFolder")
		SubEventGUI_Placeholders(sActionGUI, "TargetFolder")
}
Action_Upload_Placeholders_SourceFiles:
Action_Upload_GuiShow("", "", "Placeholders_SourceFiles")
return
Action_Upload_Placeholders_TargetFolder:
Action_Upload_GuiShow("", "", "Placeholders_TargetFolder")
return

Action_Upload_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	if(Action.tmpPassword != Action.Password)
		Action.Password := Encrypt(Action.tmpPassword)
	Action.tmpPassword := ""
}