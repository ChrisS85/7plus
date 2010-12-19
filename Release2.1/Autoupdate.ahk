AutoUpdate()
{	
	global MajorVersion,MinorVersion,BugfixVersion, ConfigPath
	if(!A_IsAdmin) ;For some reason this does not work for normal user
		return
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
					if(A_IsCompiled)
						IniRead, Link, %A_Temp%\7plus\Version.ini, Version,Link
					else
						IniRead, Link, %A_Temp%\7plus\Version.ini, Version,LinkSource
					URLDownloadToFile, %link%?x=%rand%,%A_Temp%\7plus\Updater.exe
					if(!Errorlevel)
					{
						Run %A_Temp%\7plus\Updater.exe
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
	if(FileExist(A_Temp "\7plus\Updater.exe"))
	{
		IniRead, tmpMajorVersion, %A_Temp%\7plus\Version.ini,Version,MajorVersion
		IniRead, tmpMinorVersion, %A_Temp%\7plus\Version.ini,Version,MinorVersion
		IniRead, tmpBugfixVersion, %A_Temp%\7plus\Version.ini,Version,BugfixVersion
		if(tmpMajorVersion=MajorVersion && tmpMinorVersion = MinorVersion && tmpBugfixVersion = BugfixVersion)
		{
			;If the new version is 2.1.0, some registry values need to be modified according to the new version.
			if(MajorVersion "." MinorVersion "." BugfixVersion = "2.1.0")
			{
				RemoveAllButtons()
				RefreshFastFolders()
			}
			;2.0.0 -> 2.1.0 compatibility, update autorun executable
			if(!IsPortable)
			{
				RegRead, Autorun, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus
				if(InStr(Autorun, "UACAutorun"))
					if(A_IsCompiled)
						RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\7plus.exe"
					else
						RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\7plus.ahk"
			}
			;Possibly delete remaining files from 2.0.0 which are obsolete now
			List := "UACAutorun.exe,ChangeLocation.exe,Events\cmd.xml,Events\CopyFilenames.xml,Events\CreateNewFile,Folder.xml,Events\DoubleClickDesktop.xml,Events\DoubleClickTaskbar.xml,Events\DoubleClickUpwards.xml,Events\Mouse Volume.xml,Events\Open in Editor.xml,Events\Other things.xml,Events\Upload.xml,Events\AppendToClipboard.xml,Events\BackspaceUpwards.xml"
			Loop, Parse, List,`,
				if(FileExist(A_ScriptDir "/" A_LoopField) && WriteAccess(A_ScriptDir "/" A_LoopField))
					FileDelete %A_ScriptDir%/%A_LoopField%
			
			if(FileExist(ConfigPath "\Patches\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")) ;apply release patch, without showing messages
			{
				ReadEventsFile(Events, ConfigPath "\Patches\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml")
				PatchVersion := 1
				WriteMainEventsFile()
				WriteIni()
			}
			if(FileExist(A_ScriptDir "\Changelog.txt"))
			{
				MsgBox,4,, Update successful. View Changelog?
				IfMsgBox Yes
					run %A_ScriptDir%\Changelog.txt
				MsgBox Make sure to try out the new Accessor tool (Default: ALT + Space) !
			}
		}		
		FileDelete %A_Temp%\7plus\Updater.exe
	}
	FileDelete %A_Temp%\7plus\Version.ini
}

AutoUpdate_CheckPatches()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, ConfigPath, Events
	;Disable keyboard hook to increase responsiveness
	FileCreateDir, %ConfigPath%\Patches
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
				msgbox apply patch %version%.xml
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