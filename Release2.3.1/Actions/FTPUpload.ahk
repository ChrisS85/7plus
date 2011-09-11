#include %A_ScriptDir%\Lib\FTP.ahk
Action_Upload_Init(Action)
{
	global Settings_Events
	;When creating a new upload action, try to find estimates for some settings based on existing upload actions
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
	Action.Category := "File"
	Action.SourceFiles := "${SelNM}" ;All upload actions need to have SourceFiles property (used in ImageConverter)
	Action.TargetFolder := (OtherAction && Settings_Events ? OtherAction.TargetFolder : "")
	Action.TargetFile := (OtherAction && Settings_Events ? OtherAction.TargetFile : "")
	Action.Silent := (OtherAction && Settings_Events? OtherAction.Silent : 0)
	Action.Clipboard := (OtherAction && Settings_Events ? OtherAction.Clipboard : 1)
}

Action_Upload_ReadFTPProfiles()
{
	global ConfigPath, FTPProfiles
	FTPProfiles := Array()
	FileRead, xml, %ConfigPath%\FTPProfiles.xml
	if(!xml)
	{
		xml =
		( LTrim
			<List>
			<Hostname>Hostname.com</Hostname>
			<Password></Password>
			<Port>21</Port>
			<URL>http://somehost.com</URL>
			<User>SomeUser</User>
			</List>
		)
	}
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
	FileDelete, %ConfigPath%\FTPProfiles.xml
	
	XMLObject := Object("List",Array())
	Loop % FTPProfiles.len()
	{
		ListEntry := FTPProfiles[A_Index]
		XMLObject.List.append(Object("Hostname", ListEntry.Hostname, "Port", ListEntry.Port, "User", ListEntry.User, "Password", ListEntry.Password, "URL", ListEntry.URL))
	}
	XML_Save(XMLObject, ConfigPath "\FTPProfiles.xml")
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
	Action.ReadVar(XMLAction, "SourceFiles")
	Action.ReadVar(XMLAction, "FTPProfile")
	Action.ReadVar(XMLAction, "TargetFolder")
	Action.ReadVar(XMLAction, "TargetFile")
	Action.ReadVar(XMLAction, "Silent")
	Action.ReadVar(XMLAction, "Clipboard")
}

Action_Upload_Execute(Action, Event)
{
	global FTP, Vista7
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
		if(!Hostname || Hostname = "Hostname.com")
		{
			Notify("FTP profile not set", "The FTP profile was not created yet or is invalid. Click here to enter a valid FTP login.", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",Vista7 ? 78 : 110)
			return 0
		}
		decrypted:=Decrypt(Password)
		cliptext=
		result := 1
		; connect to FTP server 
		FTP := FTP_Init()
		FTP.Port := Port
		FTP.Hostname := Hostname
		if !FTP.Open(Hostname, User, decrypted) 
		{ 
			if(!Action.Silent)
				Notify("Connection Error", "Couldn't connect to " Hostname ". Correct host/username/password?", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",Vista7 ? 78 : 110)
			result := 0
		}
		else
		{
			; create a new directory
			if(TargetFolder != "" && ftp.SetCurrentDirectory(TargetFolder) != true)
			{
				if(ftp.CreateDirectory(TargetFolder) != true)
				{
					if(!Action.Silent)
						Notify("FTP Error", "Couldn't create target directory. Check permissions!", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",Vista7 ? 78 : 110)
					result := 0
				}
				else if(ftp.SetCurrentDirectory(TargetFolder) != true)
				{
					if(!Action.Silent)
						Notify("FTP Error", "Couldn't switch to created target directory. Check permissions!", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",Vista7 ? 78 : 110)
					result := 0
				}
			}
			if(result != 0)
			{
				success := 0
				FTP.NumFiles := files.len()
				Loop % files.len()
				{
					FullPath := files[A_Index]
					result := FTP.InternetWriteFile(FullPath,  targets[A_Index], "Action_Upload_Progress")
					if(!success && result)
						success := result
					if(result=0 && !Action.Silent)
						Notify("Couldn't upload file", "Couldn't upload "  targets[A_Index] " properly. Make sure you have write rights and the path exists", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",Vista7 ? 78 : 110)
					else if(result != 0 && URL && Action.Clipboard)
						cliptext .= (A_Index = 1 ? "" : "`r`n") URL "/" TargetFolder (TargetFolder ? "/" : "") StringReplace(targets[A_Index], " ", "%20", 1)
				}
				FTP.Close()
				if(URL && Action.Clipboard && cliptext)
					clipboard:=cliptext
				if(!Action.Silent && success)
				{
					Notify("","",0, "Wait",FTP.NotifyID)
					Notify("Transfer finished", "File uploaded", 2, "GC=555555 TC=White MC=White",Vista7 ? 145 : 136)
					SoundBeep
				}
				result := 1
			}
		}
		return result
	}
}
Action_Upload_Progress()
{
	global FTP, Vista7
	my := FTP.File
	done := my.BytesTransfered
	total := my.BytesTotal
	if !FTP.init
	{
		FTP.NotifyID := Notify("Uploading " FTP.NumFiles " file" (FTP.NumFiles = 1 ? "":"s") " to " FTP.Hostname,my.RemoteName " - " FormatFileSize(done) " / " FormatFileSize(total),"","PG=100 GC=555555 TC=White MC=White",Vista7 ? 136 : 136)
		FTP.init := 1
		return 1
	}
	Notify("","",done/total*100, "Progress",FTP.NotifyID)
	Notify("","",my.RemoteName " - " FormatFileSize(done) " / " FormatFileSize(total), "Text",FTP.NotifyID)
}
FTP_Notify_Error:
ShowSettings("FTP Profiles")
return
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
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action can upload files to FTP servers.")
		; Action.tmpPassword := Action.Password
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFiles", "", "", "Source files:", "Browse", "Action_Upload_Browse", "Placeholders", "Action_Upload_Placeholders_SourceFiles")
		ShowFTPProfileSelectionGUI(Action, ActionGUI)
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

ShowFTPProfileSelectionGUI(Action, ActionGUI)
{
	global FTPProfiles
	Loop % FTPProfiles.len()
		Profiles .= "|" A_Index ": " FTPProfiles[A_Index].Hostname
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "FTPProfile", Profiles, "", "FTP profile:","","","","","FTP profiles are created on their specific sub page in the settings window.")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Placeholders", "Action_Upload_Placeholders_TargetFolder")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target files:", "Placeholders", "Action_Upload_Placeholders_TargetFile", "", "", "Filename(+ optionally .extension) / or empty for original filename")
}