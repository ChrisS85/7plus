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
					URLDownloadToFile, %link%?x=%rand%,%A_Temp%\7plus\Updater.exe
					if(!Errorlevel)
					{
						;Write config path and script dir location to temp file to let updater know
						IniWrite, %ConfigPath%, %A_Temp%\7plus\Update.ini, Update, ConfigPath
						IniWrite, %A_ScriptDir%, %A_Temp%\7plus\Update.ini, Update, ScriptDir
						Run %A_Temp%\7plus\Updater.exe,,UseErrorlevel
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
	global MajorVersion,MinorVersion,BugfixVersion, ConfigPath, IsPortable, Events
	if(FileExist(A_TEMP "\Updater.exe")) ;TODO:Change here and below for 2.3.0 to A_TEMP
	{
		IniRead, tmpMajorVersion, %A_TEMP%\Version.ini,Version,MajorVersion
		IniRead, tmpMinorVersion, %A_TEMP%\Version.ini,Version,MinorVersion
		IniRead, tmpBugfixVersion, %A_TEMP%\Version.ini,Version,BugfixVersion
		if(tmpMajorVersion=MajorVersion && tmpMinorVersion = MinorVersion && tmpBugfixVersion = BugfixVersion)
		{
			;Remove 'Always run as admin' compatibility flag from registry from previous version (it enforces an unneeded UAC prompt when clicking explorer buttons)
			if(A_IsCompiled)
				RegRead, temp, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptFullPath%
			else
				RegRead, temp, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%
			if(temp)
			{
				if(A_IsCompiled)
					RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptFullPath%
				else
					RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%
			}
			;Register shell extension
			if(MajorVersion "." MinorVersion "." BugfixVersion = "2.3.0")
			{
				RegisterShellExtension(1)
			}
			if(FileExist(A_Temp "\7plus\ReleasePatch\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")) ;apply release patch, without showing messages
			{
				ReadEventsFile(Events, A_Temp "\7plus\ReleasePatch\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")
				PatchVersion := 0
				WriteMainEventsFile()
			}
			if(FileExist(A_ScriptDir "\Changelog.txt"))
			{
				MsgBox,4,, Update successful. View Changelog?
				IfMsgBox Yes
					run %A_ScriptDir%\Changelog.txt,, UseErrorlevel
			}
		}		
		FileDelete %A_TEMP%\Updater.exe
	}
	FileDelete %A_TEMP%\Version.ini
}

AutoUpdate_CheckPatches()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, ConfigPath, Events
	;Disable keyboard hook to increase responsiveness
	FileCreateDir, %ConfigPath%\Patches
	FileDelete, %ConfigPath%\PatchInfo.xml
	Suspend, On
	URLDownloadToFile, http://7plus.googlecode.com/files/PatchInfo.xml?x=%rand%, %ConfigPath%\PatchInfo.xml
	Suspend, Off
	if(!Errorlevel)
	{
		FileRead, xml, %ConfigPath%\PatchInfo.xml
		XMLObject := XML_Read(xml)
		Update := Object("Message", "") ;Object storing update message
		Loop ;Iteratively apply all available patches
		{
			version := MajorVersion "." MinorVersion "." BugfixVersion "." (PatchVersion + 1)
			if(!FileExist(ConfigPath "\Patches\" version ".xml") && XMLObject.HasKey(version)) ;If a new patch is available online, download it to patches directory
			{
				random, rand
				PatchURL := XMLObject[version]
				Suspend, On
				URLDownloadToFile, %PatchURL%?x=%rand%, %ConfigPath%\Patches\%version%.xml
				Suspend, Off
			}
			if(FileExist(ConfigPath "\Patches\" version ".xml")) ;If the patch exists in patches directory (does not mean it has been downloaded now, they are stored)
			{
				ReadEventsFile(Events, ConfigPath "\Patches\" version ".xml","", Update)
				PatchVersion++
				WriteMainEventsFile()
				WriteIni()
				patch := true
				continue
			}
			break
		}
		if(patch)
			MsgBox, % "A Patch has been installed that updates the event configuration. Applied changes:`n" Update.Message
	}
}