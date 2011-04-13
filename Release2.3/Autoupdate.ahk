AutoUpdate()
{	
	global MajorVersion,MinorVersion,BugfixVersion, ConfigPath
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
						IniWrite, %ConfigPath%, %A_Temp%\7plus\Update.ini, Update, ConfigPath
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
	global MajorVersion,MinorVersion,BugfixVersion, ConfigPath, IsPortable, Events, XMLMajorVersion, XMLMinorVersion, XMLBugfixVersion
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
}
AutoUpdate_CheckPatches()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, ConfigPath, Events
	;Disable keyboard hook to increase responsiveness
	FileCreateDir, %ConfigPath%\Patches
	FileDelete, %ConfigPath%\PatchInfo.xml
	if(IsConnected("http://7plus.googlecode.com/files/PatchInfo.xml?x=" rand))
	{
		URLDownloadToFile, http://7plus.googlecode.com/files/PatchInfo.xml?x=%rand%, %ConfigPath%\PatchInfo.xml
		if(!Errorlevel)
		{
			FileRead, xml, %ConfigPath%\PatchInfo.xml
			XMLObject := XML_Read(xml)
		}
	}
	Update := Object("Message", "") ;Object storing update message
	Loop ;Iteratively apply all available patches
	{
		version := MajorVersion "." MinorVersion "." BugfixVersion "." (PatchVersion + 1)
		if(IsObject(XMLObject) && !FileExist(ConfigPath "\Patches\" version ".xml") && XMLObject.HasKey(version)) ;If a new patch is available online, download it to patches directory
		{
			random, rand
			PatchURL := XMLObject[version]
			if(IsConnected(PatchURL "?x=" rand))
				URLDownloadToFile, %PatchURL%?x=%rand%, %ConfigPath%\Patches\%version%.xml
		}
		if(FileExist(ConfigPath "\Patches\" version ".xml")) ;If the patch exists in patches directory (does not mean it has been downloaded now, they are stored)
		{
			ReadEventsFile(Events, ConfigPath "\Patches\" version ".xml","", Update)
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