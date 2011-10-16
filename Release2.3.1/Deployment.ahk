AutoUpdate()
{	
	global MajorVersion,MinorVersion,BugfixVersion
	outputdebug AutoUpdate
	if(IsConnected())
	{
		random, rand
		;Disable keyboard hook to increase responsiveness
		Suspend, On
		URLDownloadToFile, http://7plus.googlecode.com/files/NewVersion.ini?x=%rand%, %A_Temp%\7plus\Version.ini
		Suspend, Off
		if(!Errorlevel)
		{
			IniRead, tmpMajorVersion, %A_Temp%\7plus\Version.ini, Version,MajorVersion
			IniRead, tmpMinorVersion, %A_Temp%\7plus\Version.ini, Version,MinorVersion
			IniRead, tmpBugfixVersion, %A_Temp%\7plus\Version.ini, Version,BugfixVersion
			Update := (CompareVersion(tmpMajorVersion, MajorVersion, tmpMinorVersion, MinorVersion, tmpBugfixVersion, BugfixVersion) = 1)
			if(Update)
			{
				IniRead, UpdateMessage, %A_Temp%\7plus\Version.ini, Version,UpdateMessage
				MsgBox,4,,%UpdateMessage%
				IfMsgBox Yes
				{
					Progress zh0 fs18,Downloading Update, please wait.
					Sleep 10
					link := "Link" (!A_IsCompiled ? "Source" : "") (A_PtrSize = 8 ? "x64" : "x86")
					if(A_IsCompiled)
						IniRead, Link, %A_Temp%\7plus\Version.ini, Version,Link
					else
						IniRead, Link, %A_Temp%\7plus\Version.ini, Version,LinkSource
					URLDownloadToFile, %link%?x=%rand%,%A_Temp%\7plus\Update.exe
					if(!Errorlevel)
					{
						;Write config path and script dir location to temp file to let updater know
						IniWrite, % Settings.ConfigPath, %A_Temp%\7plus\Update.ini, Update, ConfigPath
						IniWrite, %A_ScriptDir%, %A_Temp%\7plus\Update.ini, Update, ScriptDir
						Run %A_Temp%\7plus\Update.exe,,UseErrorlevel
						OnExit
						ExitApp
					}
					else
					{
						MsgBox Error while updating. Make sure http://7plus.googlecode.com is reachable.
						Progress, Off
					}
				}
			}
		}
		else
			MsgBox Could not download version info. Make sure http://7plus.googlecode.com is reachable.
	}
}
PostUpdate()
{
	global MajorVersion,MinorVersion,BugfixVersion
	outputdebug PostUpdate
	;If there is an Update.exe in 7plus temp directory, it is likely that an update was performed.
	if(FileExist(A_TEMP "\7plus\Update.exe"))
	{
		;Check if the version from the Update.exe in temp directory matches the version of the current instance. If yes, an update has been performed.
		IniRead, tmpMajorVersion, %A_TEMP%\7plus\Version.ini,Version,MajorVersion
		IniRead, tmpMinorVersion, %A_TEMP%\7plus\Version.ini,Version,MinorVersion
		IniRead, tmpBugfixVersion, %A_TEMP%\7plus\Version.ini,Version,BugfixVersion
		if(CompareVersion(tmpMajorVersion, MajorVersion, tmpMinorVersion, MinorVersion, tmpBugfixVersion, BugfixVersion) = 0)
		{
			ApplyUpdateFixes()
			if(FileExist(A_ScriptDir "\Changelog.txt"))
			{
				MsgBox,4,, Update successful. View Changelog?
				IfMsgBox Yes
					run %A_ScriptDir%\Changelog.txt,, UseErrorlevel
			}
		}		
		FileDelete %A_TEMP%\7plus\Update.exe
	}
	FileDelete %A_TEMP%\7plus\Version.ini
}
ApplyFreshInstallSteps()
{
	ApplyUpdateFixes()
}

;This function is called in 3 cases:
;A) Fresh installation
;B) After autoupdate has finished and 7plus is started again
;C) If the user manually extracted a newer version
ApplyUpdateFixes()
{
	global MajorVersion, MinorVersion, BugfixVersion, XMLMajorVersion, XMLMinorVersion, XMLBugfixVersion, Vista7, Events
	;On fresh installation, the versions are identical since a new Events.xml is used and no events patch needs to be applied
	;After autoupdate has finished, the XML version is lower and the events are patched
	;After manually overwriting 7plus, the XML version is lower and the events are patched
	if(XMLMajorVersion != "" && CompareVersion(XMLMajorVersion, MajorVersion, XMLMinorVersion, MinorVersion, XMLBugfixVersion, BugfixVersion) = -1)
	{		
		;apply release patch without showing messages
		if(FileExist(A_ScriptDir "\Events\ReleasePatch\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")) 
		{
			;This will also set the XML version variables. 
			;In case this is triggered by an autoupdate, it will make sure that case C) won't be recognized afterwards.
			;This requires that the version is specified in the patch.
			ReadEventsFile(Events, A_ScriptDir "\Events\ReleasePatch\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")
			
			;Upgrade from previous version resets the Patch version to 0
			PatchVersion := 0
			
			;Save the patched file immediately
			WriteMainEventsFile()
		}
	}
	;Register shell extension quietly
	RegisterShellExtension(1)
	AddUninstallInformation()
	if(MajorVersion "." MinorVersion "." BugfixVersion = "2.3.0")
	{
		;Switch to new autorun method
		RegRead, key, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, 7plus
		if(Vista7 && key != "")
		{
			DisableAutorun()
			EnableAutorun()
		}				
	}
	if(MajorVersion "." MinorVersion "." BugfixVersion = "2.4.0")
	{
		;Remove some old files that were renamed
		FileDelete, %A_ScriptDir%\Events\ExplorerButtons.xml
		FileDelete, %A_ScriptDir%\Events\FastFolders.xml
		FileDelete, %A_ScriptDir%\Events\WindowHandling.xml
		
		;Encrypt existing clipboard history
		ClipboardList := Array()
		ClipboardList.push := "Stack_Push"
		ClipboardList := Object("Base", ClipboardList)
		if(FileExist(Settings.ConfigPath "\Clipboard.xml"))
		{
			FileRead, xml, % Settings.ConfigPath "\Clipboard.xml"
			XMLObject := XML_Read(xml)
			;Convert empty and single arrays to real array
			if(!XMLObject.List.len())
				XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		

			Loop % min(XMLObject.List.len(), 10)
				ClipboardList.Insert(Decrypt(XMLObject.List[A_Index])) ;Read encrypted clipboard history
			XMLObject := Object("List",Array())
			Loop % min(ClipboardList.len(), 10)
				XMLObject.List.Insert(Encrypt(ClipboardList[A_Index])) ;Store encrypted
			XML_Save(XMLObject, Settings.ConfigPath "\Clipboard.xml")
		}
	}
}
AutoUpdate_CheckPatches()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, Events
	;Disable keyboard hook to increase responsiveness
	FileCreateDir, % Settings.ConfigPath "\Patches"
	FileDelete, % Settings.ConfigPath "\PatchInfo.xml"
	if(IsConnected("http://7plus.googlecode.com/files/PatchInfo.xml?x=" rand))
	{
		URLDownloadToFile, http://7plus.googlecode.com/files/PatchInfo.xml?x=%rand%, % Settings.ConfigPath "\PatchInfo.xml"
		if(!Errorlevel)
		{
			FileRead, xml, % Settings.ConfigPath "\PatchInfo.xml"
			XMLObject := XML_Read(xml)
		}
	}
	Update := Object("Message", "") ;Object storing update message
	Loop ;Iteratively apply all available patches
	{
		version := MajorVersion "." MinorVersion "." BugfixVersion "." (PatchVersion + 1)
		if(IsObject(XMLObject) && !FileExist(Settings.ConfigPath "\Patches\" version ".xml") && XMLObject.HasKey(version)) ;If a new patch is available online, download it to patches directory
		{
			random, rand
			PatchURL := XMLObject[version]
			if(IsConnected(PatchURL "?x=" rand))
				URLDownloadToFile, %PatchURL%?x=%rand%, % Settings.ConfigPath "\Patches\" version ".xml"
		}
		if(FileExist(Settings.ConfigPath "\Patches\" version ".xml")) ;If the patch exists in patches directory (does not mean it has been downloaded now, they are stored)
		{
			ReadEventsFile(Events, Settings.ConfigPath "\Patches\" version ".xml","", Update)
			PatchVersion++
			WriteMainEventsFile()
			patch := true
			continue
		}
		break
	}
	if(patch)
		MsgBox, % "A Patch has been installed that updates the event configuration. Applied changes:`n" Update.Message
}


AddUninstallInformation()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, IsPortable
	if(IsPortable)
		return
	RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, DisplayName, 7plus V.%MajorVersion%.%MinorVersion%.%BugfixVersion%.%PatchVersion%
	RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, NoModify, 1
	RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, NoRepair, 1
	RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, UninstallString, 1, "%A_ScriptDir%\Uninstall.exe"
}

RemoveUninstallInformation()
{
	if(IsPortable)
		return
	RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus
}