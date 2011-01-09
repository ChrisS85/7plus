;If program is run without admin privileges, try to run it again as admin, and exit this instance when the user confirms it
if(!A_IsAdmin)
{
	If(A_IsCompiled)
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "/r", str, A_WorkingDir, int, 1)
	else
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, "/r """ A_ScriptFullPath """", str, A_WorkingDir, int, 1)
	ExitApp
}
if(FileExist(A_Temp "\7plus\hwnd.txt"))
{
	DetectHiddenWindows, On
	FileRead, hwnd, %A_Temp%\7plus\hwnd.txt
	if(WinExist("ahk_id " hwnd))
	{
		WinGet, pid, pid, ahk_id %hwnd%
		Process, Close, %pid%
	}
}
SetWorkingDir %a_scriptdir%
;Read current version from 7plus.ahk
Loop, Read, 7plus.ahk
{
	if(InStr(A_LoopReadLine, "MajorVersion := "))
		MajorVersion := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
	else if(InStr(A_LoopReadLine, "MinorVersion := "))
		MinorVersion := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
	else if(InStr(A_LoopReadLine, "BugfixVersion := "))
		BugfixVersion := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
}
7plusVersion := MajorVersion "." MinorVersion "." BugfixVersion
CreateUpdate("X86", "Source")
CreateUpdate("X86", "Binary")
CreateUpdate("X64", "Source")
CreateUpdate("X64", "Binary")
return
CreateUpdate(Platform, Version)
{
	global 7plusVersion
	FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
	FileDelete Updater.exe
	FileDelete Update.zip
	if(Platform = "X86")
		FileCopy, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC_UNICODE_32.bin, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC.bin, 1
	else
		FileCopy, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC_UNICODE_64.bin, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC.bin, 1
	if(Version = "Binary")
	{
		runwait %A_ProgramFiles%\Autohotkey\Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\7plus.ahk"
		Sleep 2000
	}
	FolderLoop(Platform, Version)
	runwait 7za.exe a -y "%a_scriptdir%\update.zip" "%A_TEMP%\7plusUpdateCreator\*", %a_scriptdir%,Hide
	WriteUpdater()
	sleep 500
	if(!FileExist(A_Scriptdir "\update.zip"))
		msgbox update.zip doesn't exist!
	; runwait %a_scriptdir%\update.zip
	; sleep 500
	runwait %A_ProgramFiles%\Autohotkey\Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\Updater.ahk"
	sleep 2000
	if(!FileExist(A_Scriptdir "\updater.exe"))
		msgbox updater.exe doesn't exist!
	FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
	FileMove %a_scriptdir%\update.zip, %A_ScriptDir%\7plus V.%7plusVersion% %Platform% %Version%.zip, 1
	FileMove, %A_ScriptDir%\Updater.exe, %A_ScriptDir%\Updater%Platform%%Version%.exe, 1
}
FolderLoop(Platform, Version)
{
	global 7plusVersion
	Loop *.*,0,1 ;Find files which should be included
	{
		if(Version = "Binary" && A_LoopFileExt = "ahk")
			continue
		if(Version = "Source" && A_LoopFileName = "7plus.exe")
			continue
		if A_LoopFileName contains UpdateCreator
			continue
		if(InStr(A_LoopFileName, "Update") && !InStr(A_LoopFileName, "AutoUpdate"))
			continue
		if A_LoopFileName contains .ini
			continue
		if A_LoopFileName contains Kopie
			continue
		if(A_LoopFileName="7za.exe")
			continue
		if(A_LoopFileName="Version.ini")
			continue
		if(A_LoopFileName="Autohotkey.exe")
			continue
		if(A_LoopFileName="Explorer.dll") ;Handled below
			continue
		if(A_LoopFileName="AU3_Spy.exe")
			continue
		if(A_LoopFileName="7+-128.ico")
			continue
		if(A_LoopFileName="Donate.ico")
			continue
		if(A_LoopFileExt = "bak")
			continue
		if(A_LoopFileExt = "html")
			continue
		if(A_LoopFileExt = "bin")
			continue
		if(A_LoopFileExt = "zip")
			continue
		; if(Version = "Binary" && A_LoopFileName = "128.png")
			; continue
		; if(Version = "Binary" && A_LoopFileName = "Donate.png")
			; continue
		; if(Version = "Binary" && A_LoopFileName = "7+-w2.ico")
			; continue
		; if(Version = "Binary" && A_LoopFileName = "7+-w.ico")
			; continue
		if A_LoopFileFullPath contains .svn
			continue
		if A_LoopFileFullPath contains Compiler
			continue
		if A_LoopFileFullPath contains DebugView
			continue
		if A_LoopFileFullPath contains Winspector
			continue
		if A_LoopFileFullPath contains Winspector
			continue
		if A_LoopFileFullPath contains Tools
			continue
		if A_LoopFileFullPath contains To be implemented\
			continue
		if A_LoopFileFullPath contains Explorer\Explorer
			continue
		if A_LoopFileFullPath contains x64\
			continue
		if A_LoopFileFullPath contains x86\
			continue
		if A_LoopFileFullPath contains SetACL ;Handled below
			continue
		if A_LoopFileFullPath contains Patches\
			continue
		if A_LoopFileFullPath contains DefaultConfig\
			continue
		if(InStr(A_LoopFileFullPath, "ReleasePatch\") && !InStr(A_LoopFileName, 7plusVersion)) ;Skip release patches for wrong 7plus version
			continue
		FileCreateDir %A_Temp%\7plusUpdateCreator\%A_LoopFileDir%
		FileCopy, %A_LoopFileLongPath%, %A_Temp%\7plusUpdateCreator\%A_LoopFileFullPath%, 1
	}
	FileCopy, %A_ScriptDir%\%Platform%\*, %A_Temp%\7plusUpdateCreator, 1
}
WriteUpdater()
{
	FileDelete %A_scriptdir%\Updater.ahk
	FileAppend, #NoTrayIcon`n,																	%A_scriptdir%\Updater.ahk
	FileAppend, if(!A_IsCompiled)`n,															%A_scriptdir%\Updater.ahk	;Make sure that only the compiled version can be executed
	FileAppend, `tExitApp`n,																	%A_scriptdir%\Updater.ahk
	FileAppend, SetWorkingDir `%A_scriptdir`%`n,												%A_scriptdir%\Updater.ahk
	FileAppend, Progress zh0 fs18`, Updating, please wait.`n,									%A_scriptdir%\Updater.ahk
	FileAppend, FileInstall`, %A_scriptdir%\Update.zip`, Update.zip`,1`n,						%A_scriptdir%\Updater.ahk	;%A_scriptdir% mustn't be dynamic for FileInstall -> no quotes
	FileAppend, FileInstall`, %A_scriptdir%\7za.exe`, 7za.exe`,1`n,								%A_scriptdir%\Updater.ahk	;%A_scriptdir% mustn't be dynamic for FileInstall -> no quotes
	FileAppend, runwait 7za.exe x -y Update.zip`, `%a_scriptdir`%`,hide`n,						%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete 7za.exe`n,															%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete Update.zip`n,														%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete `%A_Temp`%\7plus`n,													%A_scriptdir%\Updater.ahk	;Paranoia, a file with the name of our directory might be there
	FileAppend, FileMoveDir `%A_scriptdir`%\ReleasePatch`,`%A_Temp`%\7plus\ReleasePatch`, 2`n,	%A_scriptdir%\Updater.ahk
	FileAppend, if(FileExist("7plus.ahk"))`n,													%A_scriptdir%\Updater.ahk
	FileAppend, `trun 7plus.ahk`n,																%A_scriptdir%\Updater.ahk
	FileAppend, else if(FileExist("7plus.exe"))`n,												%A_scriptdir%\Updater.ahk
	FileAppend, `trun 7plus.exe`n,																%A_scriptdir%\Updater.ahk
	FileAppend, ExitApp`n,																		%A_scriptdir%\Updater.ahk
}