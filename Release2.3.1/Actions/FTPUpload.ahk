#include %A_ScriptDir%\Lib\FTP.ahk
Class CFTPUploadAction Extends CAction
{
	static Type := RegisterType(CFTPUploadAction, "Upload to FTP")
	static Category := RegisterCategory(CFTPUploadAction, "File")
	static SourceFiles := "${SelNM}" ;All upload actions need to have SourceFiles property (used in ImageConverter)
	static TargetFolder := ""
	static TargetFile := ""
	static Silent := 0
	static Clipboard := 1
	static FTPProfile := 1
	Startup()
	{
		if(FTPProfiles := this.ReadFTPProfiles())
			this.FTPProfiles := FTPProfiles
		else
			this.FTPProfiles := Array({Hostname : "Hostname.com", Password : "", Port : 21, URL : "http://somehost.com", User : "SomeUser"})
	}
	OnExit()
	{
		this.WriteFTPProfiles()
		this.Remove("FTPProfiles")
	}
	ReadFTPProfiles()
	{
		FTPProfiles := Array()
		FileRead, xml, % Settings.ConfigPath "\FTPProfiles.xml"
		if(!xml)
			return
		XMLObject := XML_Read(xml)
		
		;Convert to Array
		if(!XMLObject.List.MaxIndex())
			XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()
		Loop % XMLObject.List.MaxIndex()
		{
			ListEntry := XMLObject.List[A_Index]
			FTPProfiles.Insert(Object("Hostname", ListEntry.Hostname, "Port", ListEntry.Port, "User", ListEntry.User, "Password", ListEntry.Password, "URL", ListEntry.URL, "NumberOfFTPSubDirs", ListEntry.NumberOfFTPSubDirs))
		}
		return FTPProfiles
	}
	WriteFTPProfiles()
	{
		ConfigPath := Settings.ConfigPath
		SplitPath, ConfigPath,,path
		path .= "\FTPProfiles.xml"
		FileDelete, %ConfigPath%\FTPProfiles.xml
		
		XMLObject := Object("List",Array())
		Loop % this.FTPProfiles.MaxIndex()
		{
			ListEntry := this.FTPProfiles[A_Index]
			XMLObject.List.Insert(Object("Hostname", ListEntry.Hostname, "Port", ListEntry.Port, "User", ListEntry.User, "Password", ListEntry.Password, "URL", ListEntry.URL, "NumberOfFTPSubDirs", ListEntry.NumberOfFTPSubDirs))
		}
		XML_Save(XMLObject, ConfigPath "\FTPProfiles.xml")
	}

	Execute(Event)
	{
		global FTP
		SourceFiles := ToArray(Event.ExpandPlaceholders(this.SourceFiles))
		TargetFolder := Event.ExpandPlaceholders(this.TargetFolder)

		;Fetch all files (from folders)
		files := Array()
		for index, File in SourceFiles
		{
			if(InStr(FileExist(File), "D")) ;Directory
			{
				SplitPath, File,, Parent
				Loop, %File%\*.*, 0, 1
				{
					;Target path is relative to the original directory.
					Target := MakeRelativePath(A_LoopFileLongPath, Parent)
					pos := InStr(Target, "\", 0, 0)
					TargetPath := SubStr(Target, 1, pos - 1)
					TargetFile := SubStr(Target, pos + 1)
					files.Insert({File : A_LoopFileLongPath, TargetPath : TargetPath, TargetFile : TargetFile})
				}
			}
			else if(FileExist(File))
			{
				SplitPath, File, Name
				files.Insert({File : File, TargetPath : "", TargetFile : Name})
			}
		}

		;Process target filenames
		;The target file can be used to specify target file names and/or extensions. Filenames are checked afterwards to avoid conflicts
		TargetFile := Event.ExpandPlaceholders(this.TargetFile)
		SplitPath, TargetFile, , , TargetFileExtension, TargetFilenameNoExtension
		for index2, File in files
		{
			Target := file.TargetFile
			Splitpath, Target, Filename, , FileExtension, FilenameNoExtension

			;Possibly use filename or extension from TargetFile property
			if(TargetFilenameNoExtension && TargetFileExtension)
				File.TargetFile := TargetFilenameNoExtension "." TargetFileExtension
			else if(TargetFilenameNoExtension)
				File.TargetFile := TargetFilenameNoExtension "." FileExtension
			else if(TargetFileExtension)
				File.TargetFile := FilenameNoExtension "." TargetFileExtension
			else
				File.TargetFile := Filename

			;Now we need to make sure that there are no duplicates
			Target := file.TargetFile
			Splitpath, Target, Filename, , FileExtension, FilenameNoExtension
			found := true
			while(found)
			{
				Target := FilenameNoExtension (A_Index > 1 ? "(" A_Index ")" : "") "." FileExtension
				found := false
				for index3, File3 in files
				{
					if(File = File3)
						break
					if(File3.TargetPath = File.TargetPath) ;Only consider files from the same target folder
						if(File3.TargetFile = Target)
						{
							found := true
							break
						}
				}
			}
			file.TargetFile := Target
		}

		if(files.MaxIndex() > 0)
		{
			this.GetFTPVariables(this.FTPProfile, Hostname, Port, User, Password, URL, NumberOfFTPSubDirs)
			if(!Hostname || Hostname = "Hostname.com")
			{
				Notify("FTP profile not set", "The FTP profile was not created yet or is invalid. Click here to enter a valid FTP login.", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
				return 0
			}
			decrypted := Decrypt(Password)
			cliptext := ""
			result := 1
			; connect to FTP server 
			FTP := FTP_Init()
			FTP.Port := Port
			FTP.Hostname := Hostname
			if !FTP.Open(Hostname, User, decrypted) 
			{ 
				if(!this.Silent)
					Notify("Connection Error", "Couldn't connect to " Hostname ". Correct host/username/password?", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
				result := 0
			}
			else
			{
				;go into target directory, optionally creating directories along the way.
				if(TargetFolder != "" && FTP.SetCurrentDirectory(TargetFolder) != true)
				{
					Loop, Parse, TargetFolder, /\
					{
						;Skip current level if it exists
						if(ftp.SetCurrentDirectory(A_LoopField))
							continue
						;Try to create current level
						if(ftp.CreateDirectory(A_LoopField) != true)
						{
							if(!this.Silent)
								Notify("FTP Error", "Couldn't create target directory " A_LoopField ". Check permissions!", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
							result := 0
							break
						}
						;Try to go into newly created directory
						if(ftp.SetCurrentDirectory(A_LoopField) != true)
						{
							if(!this.Silent)
								Notify("FTP Error", "Couldn't switch to created target directory" A_LoopField ". Check permissions!", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
							result := 0
							break
						}
					}
				}
				if(result != 0)
				{
					FTPBaseDir := FTP.GetCurrentDirectory()
					success := 0
					for index4, File in files
					{
						FTP.NumFiles := files.MaxIndex() - index4 + 1
						;The url is sometimes mapped differently on FTP vs. Web.
						;FTP might have more directories while the webserver only mirrors a part of the directory structure.
						;The code below allows skipping some directories
						URLTargetFolder := File.TargetPath
						URLTargetFolder := TargetFolder ? TargetFolder (URLTargetFolder ? "\" : "") : ""
						Loop % NumberOfFTPSubDirs
						{
							if(pos := InStr(URLTargetFolder, "/"))
								URLTargetFolder := SubStr(URLTargetFolder, pos + 1)
							else
							{
								URLTargetFolder := ""
								break
							}
						}

						;Go back into base dir
						if(A_Index > 1)
							FTP.SetCurrentDirectory(FTPBaseDir)

						;go into target directory, optionally creating directories along the way.
						TargetPath := File.TargetPath
						if(TargetPath != "" && FTP.SetCurrentDirectory(TargetPath) != true)
						{
							Loop, Parse, TargetPath, \/
							{
								;Skip current level if it exists
								if(ftp.SetCurrentDirectory(A_LoopField))
									continue
								;Try to create current level
								if(ftp.CreateDirectory(A_LoopField) != true)
								{
									if(!this.Silent)
										Notify("FTP Error", "Couldn't create target directory " A_LoopField ". Check permissions!", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
									result := 0
									break
								}
								;Try to go into newly created directory
								if(ftp.SetCurrentDirectory(A_LoopField) != true)
								{
									if(!this.Silent)
										Notify("FTP Error", "Couldn't switch to created target directory" A_LoopField ". Check permissions!", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
									result := 0
									break
								}
							}
						}

						FullPath := File.File
						result := FTP.InternetWriteFile(FullPath,  File.TargetFile, "Action_FTPUpload_Progress")

						if(!success && result)
							success := result
						if(result=0 && !this.Silent)
							Notify("Couldn't upload file", "Couldn't upload " File.File " properly.`nMake sure you have write rights and the path exists", 5, NotifyIcons.Error, new Delegate(this, "NotifyError"))
						else if(result != 0 && URL && this.Clipboard)
							cliptext .= StringReplace((A_Index = 1 ? "" : "`r`n") URL "/" URLTargetFolder (URLTargetFolder ? "/" : "") File.TargetFile, " ", "%20", 1)
					}
					FTP.Close()
					if(URL && this.Clipboard && cliptext)
						clipboard := cliptext
					if(!this.Silent && success)
					{
						FTP.NotificationWindow.Close()
						Notify("Transfer finished", "File uploaded", 2, NotifyIcons.Success)
						SoundBeep
					}
					result := 1
				}
			}
			return result
		}
	}
	NotifyError()
	{
		ShowSettings("FTP Profiles")
	}
	DisplayString()
	{
		this.GetFTPVariables(this.FTPProfile, Hostname, "", "", "", "")
		return "Upload " this.SourceFiles " to " Hostname (this.TargetFolder ? "/" : "") this.TargetFolder
	}

	GuiShow(GUI, GoToLabel = "")
	{
		static sGUI
		if(GoToLabel = "")
		{
			sGUI := GUI
			this.AddControl(GUI, "Text", "Desc", "This action can upload files to FTP servers.")
			this.AddControl(GUI, "Edit", "SourceFiles", "", "", "Source files:", "Browse", "Action_Upload_Browse", "Placeholders", "Action_Upload_Placeholders_SourceFiles")
			for index, Profile in SettingsWindow.FTPProfiles
				Profiles .= "|" index ": " Profile.Hostname
			this.AddControl(GUI, "DropDownList", "FTPProfile", Profiles, "", "FTP profile:","","","","","FTP profiles are created on their specific sub page in the settings window.")
			this.AddControl(GUI, "Edit", "TargetFolder", "", "", "Target folder:", "Placeholders", "Action_Upload_Placeholders_TargetFolder")
			this.AddControl(GUI, "Edit", "TargetFile", "", "", "Target files:", "Placeholders", "Action_Upload_Placeholders_TargetFile", "", "", "Filename(+ optionally .extension) / or empty for original filename")
			this.AddControl(GUI, "Checkbox", "Silent", "Silent", "", "")
			this.AddControl(GUI, "Checkbox", "Clipboard", "Copy links to clipboard", "", "")
		}
		else if(GoToLabel = "Placeholders_SourceFiles")
			ShowPlaceholderMenu(sGUI, "SourceFiles")
		else if(GoToLabel = "Browse")
			this.SelectFile(sGUI, "SourceFiles")
		else if(GoToLabel = "Placeholders_TargetFolder")
			ShowPlaceholderMenu(sGUI, "TargetFolder")
		else if(GoToLabel = "Placeholders_TargetFile")
			ShowPlaceholderMenu(sGUI, "TargetFile")
	}
	
	GetFTPVariables(id, ByRef Hostname, ByRef Port, ByRef User, ByRef Password, ByRef URL, ByRef NumberOfFTPSubDirs)
	{
		Hostname := this.FTPProfiles[id].Hostname
		Port := this.FTPProfiles[id].Port
		User := this.FTPProfiles[id].User
		Password := this.FTPProfiles[id].Password
		URL := this.FTPProfiles[id].URL
		NumberOfFTPSubDirs := this.FTPProfiles[id].NumberOfFTPSubDirs
	}
}
Action_FTPUpload_Progress()
{
	global FTP
	my := FTP.File
	done := my.BytesTransfered
	total := my.BytesTotal
	if(!FTP.init)
	{
		FTP.NotificationWindow := Notify("Uploading " FTP.NumFiles " file" (FTP.NumFiles = 1 ? "":"s") " to " FTP.Hostname, my.RemoteName " - " FormatFileSize(done) " / " FormatFileSize(total), "", NotifyIcons.Internet, "", {min : 0, max : 100, value : 0})
		FTP.init := 1
		return 1
	}
	FTP.NotificationWindow.Progress := done / total * 100
	FTP.NotificationWindow.Text := my.RemoteName " - " FormatFileSize(done) " / " FormatFileSize(total)
	FTP.NotificationWindow.Title := "Uploading " FTP.NumFiles " file" (FTP.NumFiles = 1 ? "":"s") " to " FTP.Hostname
}
Action_Upload_Placeholders_SourceFiles:
GetCurrentSubEvent().GuiShow("", "Placeholders_SourceFiles")
return
Action_Upload_Browse:
GetCurrentSubEvent().GuiShow("", "Browse")
return
Action_Upload_Placeholders_TargetFolder:
GetCurrentSubEvent().GuiShow("", "Placeholders_TargetFolder")
return
Action_Upload_Placeholders_TargetFile:
GetCurrentSubEvent().GuiShow("", "Placeholders_TargetFile")
return