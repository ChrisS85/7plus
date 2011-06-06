;This file contains a bunch of functions used for checking/setting various windows settings
;==========================================================
;Getter functions: Return 1 when enabled, 0 when disabled, or -1 when not used on this OS.
;==========================================================

WindowsSettings_Get_ShowAllTray()
{
	RegRead, ShowAllTray, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer, EnableAutoTray
	return ShowAllTray = 1 ? 0 : 1
}

WindowsSettings_Get_RemoveUserDir()
{
	RegRead, RemoveUserDir, HKCR, CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder, Attributes
	return RemoveUserDir = 0xf084012d ? 0 : 1
}

WindowsSettings_Get_RemoveWMP()
{
	if(A_OSVersion = "WIN_XP")
		RegRead, RemoveWMP, HKCR, CLSID\{CE3FB1D1-02AE-4a5f-A6E9-D9F1B4073E6C}
	else
		RegRead, RemoveWMP, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic
	return RemoveWMP = "" ? 1 : 0
}

WindowsSettings_Get_RemoveOpenWith()
{
	RegRead, RemoveOpenWith, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer, NoInternetOpenWIth
	return RemoveOpenWith = 1 ? 1 : 0
}

WindowsSettings_Get_RemoveCrashReporting()
{
	RegRead, RemoveCrashReporting, HKLM, Software\Microsoft\Windows\Windows Error Reporting, DontShowUI
	return RemoveCrashReporting = 1 ? 1 : 0
}

WindowsSettings_Get_ShowExtensions()
{
	RegRead, ShowExtensions, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt 
	return ShowExtensions = 1 ? 0 : 1
}

WindowsSettings_Get_ShowHiddenFiles()
{
	RegRead, ShowHiddenFiles, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
	return ShowHiddenFiles = 2 ? 0 : 1
}

WindowsSettings_Get_ShowSystemFiles()
{
	RegRead, ShowSystemFiles, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden 
	return ShowSystemFiles
}

WindowsSettings_Get_DisableUAC()
{
	global Vista7
	if(Vista7)
	{
		RegRead, DisableUAC, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System, EnableLUA 
		return DisableUAC = 0 ? 1 : 0
	}
	return -1
}	

WindowsSettings_Get_ClassicView()
{
	if(A_OSVersion = "WIN_XP")
	{
		RegRead, ClassicView, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced, WebView
		return ClassicView = 0 ? 1 : 0
	}
	return -1
}

WindowsSettings_Get_RemoveLibraries()
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegRead, RemoveLibraries, HKCR, CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder, Attributes
		return  RemoveLibraries = 0xb090010d ? 1 : 0	
	}
	return -1
}

WindowsSettings_Get_ActivateBehavior()
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegRead, HKActivateBehavior, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick
		return HKActivateBehavior = 1
	
	}
	return -1
}

;This function actually returns a time in ms.
WindowsSettings_Get_HoverTime()
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegRead, HoverTime, HKCU, Control Panel\Mouse, MouseHoverTime
		return HoverTime = "" ? 400 : HoverTime	
	}
	return -1
}


;======================================================================================
;Setter functions: Return 1 when PC needs to be restarted to apply a setting, and 2 when explorer needs to be restarted, 0/"" otherwise
;======================================================================================
;TODO: Check if permissions are properly set
;TODO: Additional steps for wmp context menus
WindowsSettings_ShowAllTray(ShowAllTray)
{
	RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer, EnableAutoTray, % ShowAllTray = 1 ? 0 : 1
}	

WindowsSettings_RemoveUserDir(RemoveUserDir)
{
	RegGivePermissions("hkcr\CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder")
	RegWrite, REG_DWORD, HKCR, CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder, Attributes, % RemoveUserDir ? 0xf094012d : 0xf084012d
	RegRevokePermissions("hkcr\CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder")
}

WindowsSettings_RemoveWMP(RemoveWMP)
{
	if(A_OSVersion = "WIN_XP")
		run, % "regsvr32 " (RemoveWMP ?"/u " : "") "/s wmpshell.dll",, Hide
	else
	{
		if(RemoveWMP)
		{
			RegDelete, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic
			RegWrite, REG_SZ, HKCR, SystemFileAssociations\audio\shell\Enqueue, LegacyDisable
			RegWrite, REG_SZ, HKCR, SystemFileAssociations\audio\shell\Play, LegacyDisable
		}
		else
		{
			RegDelete, HKCR, SystemFileAssociations\audio\shell\Enqueue, LegacyDisable
			RegDelete, HKCR, SystemFileAssociations\audio\shell\Play, LegacyDisable
			RegWrite, REG_SZ, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic,, {8A734961-C4AA-4741-AC1E-791ACEBF5B39}
		}
	}
}		

WindowsSettings_RemoveOpenWith(RemoveOpenWith)
{
		RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer, NoInternetOpenWIth, % RemoveOpenWith
}

WindowsSettings_RemoveCrashReporting(RemoveCrashReporting)
{		
		RegWrite, REG_DWORD, HKLM, Software\Microsoft\Windows\Windows Error Reporting, DontShowUI, % RemoveCrashReporting
}

WindowsSettings_ShowExtensions(ShowExtensions)
{		
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, % ShowExtensions = 1 ? 0 : 1
}

WindowsSettings_ShowHiddenFiles(ShowHiddenFiles)
{
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, % ShowHiddenFiles
}

WindowsSettings_ShowSystemFiles(ShowSystemFiles)
{		
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, % ShowSystemFiles
}

WindowsSettings_DisableUAC(DisableUAC)
{
	global Vista7
	if(Vista7)
	{
		RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System, EnableLUA, % DisableUAC = 1 ? 0 : 1
		return 1
	}
}

WindowsSettings_ClassicView(ClassicView)
{
		if(A_OSVersion = "WIN_XP")
			RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Advanced, WebView, % ClassicView = 1 ? 0 : 1
}

WindowsSettings_RemoveLibraries(RemoveLibraries)
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegGivePermissions("HKCR\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder")
		RegGivePermissions("HKCR\Folder\ShellEx\ContextMenuHandlers\Library Location")
		RegWrite, REG_DWORD, HKCR, CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder, Attributes, % RemoveLibraries = 1 ? 0xb090010d : 0xb080010d
		if(RemoveLibraries)
			RegDelete, HKCR, Folder\ShellEx\ContextMenuHandlers\Library Location
		else
			RegWrite, REG_SZ, HKCR,  Folder\ShellEx\ContextMenuHandlers\Library Location,, {3dad6c5d-2167-4cae-9914-f99e41c12cfa}
		RegRevokePermissions("HKCR\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder")
		RegRevokePermissions("HKCR\Folder\ShellEx\ContextMenuHandlers\Library Location")
	}
}

WindowsSettings_ActivateBehavior(ActivateBehavior)
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick, % ActivateBehavior
		return 2
	}
}

WindowsSettings_HoverTime(HoverTime)
{
	if(A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_VISTA")
	{
		RegWrite, REG_SZ, HKCU, Control Panel\Mouse, MouseHoverTime, % HoverTime
	}
}