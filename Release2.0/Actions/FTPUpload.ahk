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
	Action.TargetFolder := (OtherAction ? OtherAction.TargetFolder : "Target/Folder/or/empty")
	Action.TargetFile := (OtherAction ? OtherAction.TargetFile : "Filename(+ optionally .extension) / or empty for original filename")
	Action.Silent := (OtherAction ? OtherAction.Silent : 0)
	Action.Clipboard := (OtherAction ? OtherAction.Clipboard : 1)
}

Action_Upload_ReadFTPProfiles()
{
	global ConfigPath, FTPProfiles
	SplitPath, ConfigPath,,path
	path .= "\FTPProfiles.xml"
	FTPProfiles := Array()
	if(!FileExist(path))
		return
	FileRead, xml, %path%
	XMLObject := XML_Read(xml)
	;Convert empty and single arrays to real array
	if(!XMLObject.List.len())
		XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()
	Loop % XMLObject.List.len()
	{
		ListEntry := XMLObject.List[A_Index]
		FTPProfiles.append(Object("Hostname", ListEntry.Hostname, "Port", ListEntry.Port, "User", ListEntry.User, "Password", ListEntry.Password, "URL", ListEntry.URL))
	}
}
Action_Upload_WriteFTPProfiles()
{
	global ConfigPath, FTPProfiles
	SplitPath, ConfigPath,,path
	path .= "\FTPProfiles.xml"
	FileDelete, %path%
	
	XMLObject := Object("List",Array())
	Loop % FTPProfiles.len()
	{
		ListEntry := FTPProfiles[A_Index]
		XMLObject.List.append(Object("Hostname", ListEntry.Hostname, "Port", ListEntry.Port, "User", ListEntry.User, "Password", ListEntry.Password, "URL", ListEntry.URL))
	}
	XML_Save(XMLObject,path)
}

Action_Upload_GetFTPVariables(id, ByRef Hostname, ByRef Port, ByRef User, ByRef Password, ByRef URL)
{
	global FTPProfiles
	Hostname := FTPProfiles[id].Hostname
	Port := FTPProfiles[id].Port
	User := FTPProfiles[id].User
	Password := FTPProfiles[id].Password
	URL := FTPProfiles[id].URL
}

Action_Upload_ReadXML(Action, XMLAction)
{
	Action.SourceFiles := XMLAction.SourceFiles
	Action.FTPProfile := XMLAction.FTPProfile
	Action.TargetFolder := XMLAction.TargetFolder
	Action.TargetFile := XMLAction.TargetFile
	Action.Silent := XMLAction.Silent
	Action.Clipboard := XMLAction.Clipboard
}

Action_Upload_Execute(Action, Event)
{
	SourceFiles := Event.ExpandPlaceholders(Action.SourceFiles)
	TargetFolder := Event.ExpandPlaceholders(Action.TargetFolder)
	TargetFile := Event.ExpandPlaceholders(Action.TargetFile)
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
		number := 1
		pos := A_Index
		Loop % pos - 1 ;add (Number) to avoid duplicate filenames
			if(targets[A_Index] = CheckFilenameNoExtension (number > 1 ? " (" number ")" : "") "." CheckExtension)
				number++
		targets[pos] := CheckFilenameNoExtension (number > 1 ? " (" number ")" : "") "." CheckExtension
	}
	if(files.len() > 0)
	{
		Action_Upload_GetFTPVariables(Action.FTPProfile, Hostname, Port, User, Password, URL)
		decrypted:=Decrypt(Password)
		result:=FtpOpen(Hostname, Port, User, decrypted)
		cliptext=
		if(result=1)
		{
			FtpCreateDirectory(TargetFolder)
			success := 0
			Loop % files.len()
			{
				FullPath := files[A_Index]
				result:=FtpPutFile(FullPath, TargetFolder (TargetFolder ? "/" : "") targets[A_Index]) 
				if(!success && result)
					success := result
				if(result=0 && !Action.Silent)
				{
					ToolTip(1, "Couldn't upload " TargetFolder (TargetFolder ? "/" : "") targets[A_Index] " properly. Make sure you have write rights and the path exists", "Couldn't upload file","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
					SetTimer, ToolTipClose, -5000
				}
				else if(result != 0 && URL && Action.Clipboard)
					cliptext .= (A_Index = 1 ? "" : "`r`n") URL "/" TargetFolder (TargetFolder ? "/" : "") StringReplace(targets[A_Index], " ", "%20", 1)
			}
			FtpClose()
			if(URL && Action.Clipboard && cliptext)
				clipboard:=cliptext
			if(!Action.Silent && success)
			{
				ToolTip(1, "File uploaded" (URL && Action.Clipboard ? " and links copied to clipboard" : ""), "Transfer finished","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
				SetTimer, ToolTipClose, -2000
				SoundBeep
			}
			return 1
		}
		else
		{
			if(!Action.Silent)
			{
				ToolTip(1, "Couldn't connect to " Hostname ". Correct host/username/password?", "Connection Error","O1 L1 P99 C1 XTrayIcon YTrayIcon I4")
				SetTimer, ToolTipClose, -5000
			}
			return 0
		}
	}
}
Action_Upload_DisplayString(Action)
{
	Action_Upload_GetFTPVariables(Action.FTPProfile, Hostname, Port, User, Password, URL)
	return "Upload " Action.SourceFiles " to " Hostname (Action.TargetFolder ? "/" : "") Action.TargetFolder
}

Action_Upload_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	global FTPProfiles
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		; Action.tmpPassword := Action.Password
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFiles", "", "", "Source files:", "Browse", "Action_Upload_Browse", "Placeholders", "Action_Upload_Placeholders_SourceFiles")
		Loop % FTPProfiles.len()
			Profiles .= "|" A_Index ": " FTPProfiles[A_Index].Hostname
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "FTPProfile", Profiles, "", "FTP profile:")
		; SubEventGUI_Add(Action, ActionGUI, "Edit", "Hostname", "", "", "Hostname:")
		; SubEventGUI_Add(Action, ActionGUI, "Edit", "Port", "", "", "Port:")
		; SubEventGUI_Add(Action, ActionGUI, "Edit", "User", "", "", "Username:")
		; SubEventGUI_Add(Action, ActionGUI, "Edit", "tmpPassword", "", "", "Password")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Placeholders", "Action_Upload_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target files:", "Placeholders", "Action_Upload_Placeholders_TargetFile")
		; SubEventGUI_Add(Action, ActionGUI, "Edit", "URL", "", "", "URL:")
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
	; if(Action.tmpPassword != Action.Password)
		; Action.Password := Encrypt(Action.tmpPassword)
	; Action.tmpPassword := ""
}