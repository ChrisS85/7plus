;---------------------------------------------------------------------------------------------------------------
;This file contains methods for storing and restoring fast folders related registry settings
;---------------------------------------------------------------------------------------------------------------

PrepareFolderBand()
{
	global Vista7
	if(Vista7)
	{
		;Give us all rights
		msgbox grant
		runwait %A_ScriptDir%\SetACL.exe -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes" -ot Reg -actn setowner -ownr "n:S-1-5-32-544;s:y“ -rec yes
		runwait %A_ScriptDir%\SetACL.exe -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:full;s:y;i:so,sc;m:grant;w:dacl"
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /setowner=S-1-5-32-544,,Hide
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /grant=S-1-5-32-545=F,,Hide
		AddAllButtons(1,0)
	}	
}
BackupAndRemoveFolderBandButtons()
{
	global Vista7
	if(Vista7)
	{
		msgbox grant
		;Give us all rights
		runwait %A_ScriptDir%\SetACL.exe -on "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell" -ot Reg -actn setowner -ownr "n:S-1-5-32-544;s:y“ -rec yes
		runwait %A_ScriptDir%\SetACL.exe -on "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:full;s:y;i:so,sc;m:grant;w:dacl"
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell /setowner=S-1-5-32-544,,Hide
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell /grant=S-1-5-32-545=F,,Hide
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
	cmd := """" A_ScriptDir "\SetACL.exe"" -on ""hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"" -ot Reg -actn ace -ace ""n:S-1-5-32-545;p:full;s:y;i:so,sc;m:revoke;w:dacl"""
	msgbox % cmd
	run % cmd
	;remove some rights
	;~ runwait "%A_ScriptDir%\SetACL.exe" -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:full;s:y;i:so,sc;m:revoke;w:dacl"
	; runwait %A_ScriptDir%\SetACL.exe -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:read;s:y;i:so,sc;m:grant;w:dacl"
		
	; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /revoke=S-1-5-32-545,,Hide
	; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes /grant=S-1-5-32-545=R,,Hide
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
		runwait %A_ScriptDir%\SetACL.exe -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:full;s:y;i:so,sc;m:revoke;w:dacl"
		; runwait %A_ScriptDir%\SetACL.exe -on "hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell" -ot Reg -actn ace -ace "n:S-1-5-32-545;p:read;s:y;i:so,sc;m:grant;w:dacl"
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore /revoke=S-1-5-32-545,,Hide
		; runwait subinacl /subkeyreg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore /grant=S-1-5-32-545=R,,Hide
	}
}

;------------------------------------------------------------------------------
; StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")
; by Sean
;------------------------------------------------------------------------------

/*	Example1
MsgBox % sOutput := StdoutToVar_CreateProcess("ipconfig.exe /all")
*/

/*	Example2 with Streaming
MsgBox % sOutput := StdoutToVar_CreateProcess("ping.exe www.autohotkey.com", True)
*/

/*	Example3 with Streaming and Calling Custom Function	; Custom Function Name must not consist solely of numbers!
MsgBox % sOutput := StdoutToVar_CreateProcess("ping.exe www.autohotkey.com", "Stream")	; Custom Function Name is "Stream" in this example!

Stream(sString)
{
;	Custom Routine here! For example,
;	OutputDebug %sString%
}
*/

/*	Example4 with Working Directory
MsgBox % sOutput := StdoutToVar_CreateProcess("cmd.exe /c dir /a /o", "", A_WinDir)
*/

/*	Example5 with Input String
MsgBox % sOutput := StdoutToVar_CreateProcess("sort.exe", "", "", "abc`r`nefg`r`nhijk`r`n0123`r`nghjki`r`ndflgkhu`r`n")
*/

StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, si, 56)		; hStdInput
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If Not	DllCall("CreateProcess", "Uint", 0, "Uint", &sCmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", sDir ? &sDir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		ExitApp
	DllCall("CloseHandle", "Uint", NumGet(pi,0))
	DllCall("CloseHandle", "Uint", NumGet(pi,4))
	DllCall("CloseHandle", "Uint", hStdOutWr)
	DllCall("CloseHandle", "Uint", hStdInRd)
	If	sInput <>
	DllCall("WriteFile", "Uint", hStdInWr, "Uint", &sInput, "Uint", StrLen(sInput), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)
	bStream+0 ? (bAlloc:=DllCall("AllocConsole"),hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint",bAlloc ? 0 : 3,"Uint",0,"Uint",3,"Uint",0,"Uint",0)) : ""
	VarSetCapacity(sTemp, nTemp:=bStream ? 64-nTrim:=1 : 4095)
	Loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0)&&nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
			If	bStream
				Loop
					If	RegExMatch(sOutput, "[^\n]*\n", sTrim, nTrim)
						bStream+0 ? DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", 0, "Uint", 0) : %bStream%(sTrim), nTrim+=StrLen(sTrim)
					Else	Break
		}
		Else	Break
	DllCall("CloseHandle", "Uint", hStdOutRd)
	bStream+0 ? (DllCall("Sleep","Uint",1000),hCon+1 ? DllCall("CloseHandle","Uint",hCon) : "",bAlloc ? DllCall("FreeConsole") : "") : ""
	Return	sOutput
}
/*
StdoutToVar_CreateProcessCOM(sCmd, bStream = False, sDir = "", sInput = "")
{
	COM_Init()
	pwsh :=	COM_CreateObject("WScript.Shell")
	sDir ?	COM_Invoke(pwsh, "CurrentDirectory", sDir) : ""
	pexec:=	COM_Invoke(pwsh, "Exec", sCmd)
	pid  :=	COM_Invoke(pexec, "ProcessID")
		WinWait, ahk_pid %pid%,,3
	If	bStream
		bAttach:=DllCall("AttachConsole","Uint",pid),pcon:=COM_Invoke(pfso:=COM_CreateObject("Scripting.FileSystemObject"),"GetStandardStream",1),COM_Release(pfso)
	Else	WinHide
	If	sInput <>
	pin  :=	COM_Invoke(pexec, "StdIn"), COM_Invoke(pin, "Write", sInput), COM_Invoke(pin, "Close"), COM_Release(pin)
	pout :=	COM_Invoke(pexec, "StdOut")	; perr := COM_Invoke(pexec, "StdErr")
	Loop
		If	COM_Invoke(pout, "AtEndOfStream")=0
			sOutput.=sTrim:=COM_Invoke(pout, "ReadLine") . "`r`n", bStream ? COM_Invoke(pcon, "Write", sTrim) : ""
		Else	Break
	COM_Invoke(pout, "Close"), COM_Release(pout)
	bStream ? (COM_Invoke(pcon,"Close"),COM_Release(pcon),DllCall("Sleep","Uint",1000),bAttach ? DllCall("FreeConsole") : "") : ""
	Loop
		If	COM_Invoke(pexec, "Status")=0
			Sleep,	100
		Else	Break
;	COM_Invoke(pexec, "Terminate")
	COM_Release(pexec)
	COM_Release(pwsh)
	COM_Term()
	Return	sOutput
}
*/


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
