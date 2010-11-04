;---------------------------------------------------------------------------------------------------------------
;This file contains methods for storing and restoring fast folders related registry settings
;---------------------------------------------------------------------------------------------------------------

PrepareFolderBand()
{
	global Vista7
	if(Vista7)
	{
		;Give us all rights
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /setowner=S-1-5-32-544,,Hide
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /grant=S-1-5-32-545=F,,Hide
		AddAllButtons(1,0)
	}	
}
BackupAndRemoveFolderBandButtons()
{
	global Vista7
	if(Vista7)
	{
		;Give us all rights
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell /setowner=S-1-5-32-544,,Hide
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell /grant=S-1-5-32-545=F,,Hide
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Burn","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Burn7pBackup")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Organize","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Organize7pBackup")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.IncludeInLibrary","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.IncludeInLibrary7pBackup")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.NewFolder","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.NewFolder7pBackup")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Share","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Share7pBackup")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.SlideShow","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.SlideShow7pBackup")
	}
}
BackupPlacesBar()
{
	RegRename("HKCU","Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar","Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar7pBackup")
	AddAllButtons(0,1)
}

;---------------------------------------------------------------------------------------------------------------

RestoreFolderBand()
{
	global Vista7
	if(!Vista7)
		return
	RemoveAllButtons()
	;remove some rights
	runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /revoke=S-1-5-32-545,,Hide
	runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /grant=S-1-5-32-545=R,,Hide
}
RestoreFolderBandButtons()
{
	global Vista7
	if(Vista7)
	{
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Burn7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Burn")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Organize7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Organize")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.IncludeInLibrary7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.IncludeInLibrary")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.NewFolder7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.NewFolder")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Share7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.Share")
		RegRename("HKLM","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.SlideShow7pBackup","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.SlideShow")
		;remove some rights
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore /revoke=S-1-5-32-545,,Hide
		runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore /grant=S-1-5-32-545=R,,Hide
	}
}
RestorePlacesBar()
{
		RegRead, place, HKCU, Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar7pBackup ,Place0
		RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar
		if(place)
			RegRename("HKCU","Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar7pBackup"," Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\PlacesBar")
}

;---------------------------------------------------------------------------------------------------------------

RegRename(root,key,target)
{
	HKEY_CLASSES_ROOT   := 0x80000000   ; http://msdn.microsoft.com/en-us/library/aa393286.aspx 
	HKEY_CURRENT_USER   := 0x80000001 
	HKEY_LOCAL_MACHINE   := 0x80000002 
	HKEY_USERS         := 0x80000003 
	HKEY_CURRENT_CONFIG   := 0x80000005 
	HKEY_DYN_DATA      := 0x80000006 
	HKCR := HKEY_CLASSES_ROOT 
	HKCU := HKEY_CURRENT_USER 
	HKLM := HKEY_LOCAL_MACHINE 
	HKU    := HKEY_USERS 
	HKCC := HKEY_CURRENT_CONFIG
	hive:=%root%
	if(!hive)
		return 0
	
	result:=DllCall("Advapi32.dll\RegOpenKeyEx", "Ptr", hive, "str", key, "uint",0, "uint", 0xF003F, "Ptr *",hkey)
	if(result=0)
	{
		result:=DllCall("Advapi32.dll\RegCreateKeyEx", "Ptr", hive, "str", target, "uint", 0, "uint", 0, "uint", 0, "uint", 0xF003F, "uint", 0, "Ptr *", hNewKey, "uint",0)
		if(result=0)
		{
			result:=DllCall("Advapi32.dll\RegCopyTree", "Ptr", hkey, "uint", 0, "Ptr", hNewKey)
			if(result=0)
			{
				DllCall("Advapi32.dll\RegCloseKey", "Ptr", hkey)
				RegDelete, %root%, %key%
				DllCall("Advapi32.dll\RegCloseKey", "Ptr", hNewKey)
				return 1
			}			
			else
			{
				DllCall("Advapi32.dll\RegCloseKey", "Ptr", hNewKey)
				RegDelete, %root%, %target%
				DllCall("Advapi32.dll\RegCloseKey", "Ptr", hkey)
				return 1
			}
		}
		DllCall("Advapi32.dll\RegCloseKey", "Ptr", hkey)
	}
	return 0
}
