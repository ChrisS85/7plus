﻿;If program is run without admin privileges, try to run it again as admin, and exit this instance when the user confirms it
if(!A_IsAdmin)
{
	If(A_IsCompiled)
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "/r", str, A_WorkingDir, int, 1)
	else
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, "/r """ A_ScriptFullPath """", str, A_WorkingDir, int, 1)
	ExitApp
}
;Close running 7plus instance
if(running := FileExist(A_Temp "\7plus\hwnd.txt"))
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
if(running)
	run, %A_ScriptDir%\7plus.ahk
return
CreateUpdate(Platform, Version)
{
	global 7plusVersion
	;Everything is temporarily copied to %A_TEMP%\7plusUpdateCreator
	FileRemoveDir %A_TEMP%\7plusUpdateCreator, 1
	FileCreateDir %A_TEMP%\7plusUpdateCreator
	FileDelete Updater.exe
	FileDelete Update.zip
	;Copy matching autohotkey binary files and Dlls of the correct bitness
	if(Platform = "X86")
	{
		FileCopy, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC_UNICODE_32.bin, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC.bin, 1
		FileCopy, %A_ScriptDir%\ShellExtension\Release\ShellExtension.dll, %A_TEMP%\7plusUpdateCreator, 1
		FileCreateDir, %A_TEMP%\7plusUpdateCreator\lib
		FileCopy, %A_ScriptDir%\lib\sqlite3.dll, %A_TEMP%\7plusUpdateCreator\lib, 1
	}
	else
	{
		FileCopy, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC_UNICODE_64.bin, %A_ProgramFiles%\Autohotkey\Compiler\AutoHotkeySC.bin, 1
		FileCopy, %A_ScriptDir%\ShellExtension\x64\Release\ShellExtension.dll, %A_TEMP%\7plusUpdateCreator, 1
		FileCreateDir, %A_TEMP%\7plusUpdateCreator\lib\x64
		FileCopy, %A_ScriptDir%\lib\x64\sqlite3.dll, %A_TEMP%\7plusUpdateCreator\lib\x64, 1
	}
	
	;Compile 7plus and Uninstaller
	if(Version = "Binary")
	{
		runwait %A_ProgramFiles%\Autohotkey\Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\7plus.ahk"
		Sleep 1500
		
	}
	;Uninstaller is always compiled
	runwait %A_ProgramFiles%\Autohotkey\Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\Uninstall.ahk"
	Sleep 1500
	;Copy all other files
	FolderLoop(Platform, Version)
	;Zip them
	runwait 7za.exe a -y "%a_scriptdir%\update.zip" "%A_TEMP%\7plusUpdateCreator\*", %a_scriptdir%,Hide
	;Generate update script
	WriteUpdater()
	
	if(!FileExist(A_Scriptdir "\update.zip"))
		msgbox update.zip doesn't exist!
	
	;Compile updater
	runwait %A_ProgramFiles%\Autohotkey\Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\Updater.ahk"
	sleep 2000
	if(!FileExist(A_Scriptdir "\updater.exe"))
		msgbox updater.exe doesn't exist!
	;Cleanup and move resulting files
	FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
	FileMove %a_scriptdir%\update.zip, %A_ScriptDir%\7plus V.%7plusVersion% %Platform% %Version%.zip, 1
	FileMove, %A_ScriptDir%\Updater.exe, %A_ScriptDir%\Updater%Platform%%Version%.exe, 1
}
FolderLoop(Platform, Version)
{
	global 7plusVersion
	Loop *.*, 0, 1 ;Find files which should be included
	{
		if(Version = "Binary" && A_LoopFileExt = "ahk")
			continue
		if(Version = "Source" && A_LoopFileName = "7plus.exe")
			continue
		if A_LoopFileName contains UpdateCreator
			continue
		if(InStr(A_LoopFileName, "Update") && !InStr(A_LoopFileName, "AutoUpdate"))
			continue
		if(A_LoopFileExt = "ini")
			continue
		if A_LoopFileName contains Kopie
			continue
		if(A_LoopFileName = "7za.exe")
			continue
		if(A_LoopFileName = "Version.ini")
			continue
		if(A_LoopFileName = "Autohotkey.exe")
			continue
		if(A_LoopFileName = "Explorer.dll") ;Handled before
			continue
		if A_LoopFileName contains sqlite3.dll ;Handled before
			continue
		if(A_LoopFileName = "AU3_Spy.exe")
			continue
		if(A_LoopFileName = "7+-128.ico")
			continue
		if(A_LoopFileName = "Uninstall.ico")
			continue
		if(A_LoopFileName = "Donate.ico")
			continue
		if(A_LoopFileExt = "bak")
			continue
		if(A_LoopFileExt = "html")
			continue
		if(A_LoopFileExt = "bin")
			continue
		if(A_LoopFileExt = "zip")
			continue
		if(A_LoopFileExt = "svg")
			continue
		if(A_LoopFileExt = "log")
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
		if A_LoopFileFullPath contains Tools\
			continue
		if A_LoopFileFullPath contains Old Versions
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
		if A_LoopFileFullPath contains ShellExtension
			continue
		if A_LoopFileFullPath contains tests\
			continue
		if A_LoopFileFullpath contains CreateEventPatch
			continue
		if A_LoopFileFullPath contains SubEventBackup
			continue
		if A_LoopFileFullPath contains NewSettings
			continue
		if A_LoopFileName contains Improvements.txt
			continue
		if A_LoopFileName contains PatchInfo.xml
			continue
		if(InStr(A_LoopFileFullPath, "ReleasePatch\") && !InStr(A_LoopFileName, 7plusVersion)) ;Skip release patches for wrong 7plus version
			continue
		if(A_LoopFileExt = "xml") ;Remove german folder/file names
		{
			FileRead, content, %A_LoopFileFullPath%
			StringReplace, content, content,<Filename>Neues Textdokument.txt</Filename>`r`n
			StringReplace, content, content,<FolderName>Neuer Ordner</FolderName>`r`n
			FileDelete, %A_LoopFileFullPath%
			FileAppend, %content%, %A_LoopFileFullPath%
		}
		FileCreateDir %A_Temp%\7plusUpdateCreator\%A_LoopFileDir%
		FileCopy, %A_LoopFileLongPath%, %A_Temp%\7plusUpdateCreator\%A_LoopFileFullPath%, 1
	}
	FileCopy, %A_ScriptDir%\%Platform%\*, %A_Temp%\7plusUpdateCreator, 1
}

;Write the script which is executed on the client side
WriteUpdater()
{
	FileDelete %A_scriptdir%\Updater.ahk
	FileAppend, #NoTrayIcon`n,																						%A_scriptdir%\Updater.ahk
	FileAppend, if(!A_IsCompiled)`n,																				%A_scriptdir%\Updater.ahk	;Make sure that only the compiled version can be executed
	FileAppend, `tExitApp`n,																						%A_scriptdir%\Updater.ahk
	FileAppend, SetWorkingDir `%A_Temp`%\7plus`n,																	%A_scriptdir%\Updater.ahk
	FileAppend, IniRead`, ConfigPath`, `%A_Temp`%\7plus\Update.ini`, Update`, ConfigPath`, `%A_AppData`%\7plus`n, 	%A_scriptdir%\Updater.ahk
	FileAppend, IniRead`, ScriptDir`, `%A_Temp`%\7plus\Update.ini`, Update`, ScriptDir`, `%A_ProgramFiles`%\7plus`n,%A_scriptdir%\Updater.ahk
	FileAppend, Progress zh0 fs18`, Updating, please wait.`n,														%A_scriptdir%\Updater.ahk
	FileAppend, FileInstall`, %A_scriptdir%\Update.zip`, Update.zip`,1`n,											%A_scriptdir%\Updater.ahk	;%A_scriptdir% mustn't be dynamic for FileInstall -> no quotes
	FileAppend, FileInstall`, %A_scriptdir%\7za.exe`, 7za.exe`,1`n,													%A_scriptdir%\Updater.ahk	;%A_scriptdir% mustn't be dynamic for FileInstall -> no quotes
	FileAppend, run regsvr32 /s "`%ScriptDir`%\ShellExtension.dll"`n,											%A_scriptdir%\Updater.ahk	;Unregister context menu shell extension. It will get reregistered in PostUpdate()
	FileAppend, runwait 7za.exe x Update.zip -y -o`%A_Temp`%\7plus\Update`, `%A_Temp`%\7plus`, hide`n,				%A_scriptdir%\Updater.ahk	
	FileAppend, FileMoveDir`, `%A_Temp`%\7plus\Update\Patches`, `%ConfigPath`%\Patches`, 2`n, 						%A_scriptdir%\Updater.ahk	
    ; First move all the files (but not the folders):
    FileAppend, FileMove`, `%A_Temp`%\7plus\Update`, `%ScriptDir`%`, 1`n, 											%A_scriptdir%\Updater.ahk
    ; Now move all the folders:
    FileAppend, Loop`, `%A_Temp`%\7plus\Update\*.*`, 2`n,															%A_scriptdir%\Updater.ahk
    FileAppend, FileMoveDir`, `%A_LoopFileFullPath`%`, `%ScriptDir`%\`%A_LoopFileName`%`, 2`n,						%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete 7za.exe`n,																				%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete Update.zip`n,																			%A_scriptdir%\Updater.ahk
	FileAppend, FileMoveDir `%A_Temp`%\7plus\Update\ReleasePatch`,`%A_Temp`%\7plus\ReleasePatch`, 2`n,				%A_scriptdir%\Updater.ahk
	FileAppend, if(FileExist(ScriptDir "\7plus.ahk"))`n,																%A_scriptdir%\Updater.ahk
	FileAppend, `trun `%ScriptDir`%\7plus.ahk`n,																	%A_scriptdir%\Updater.ahk
	FileAppend, else if(FileExist(ScriptDir "\7plus.exe"))`n,														%A_scriptdir%\Updater.ahk
	FileAppend, `trun `%ScriptDir`%\7plus.exe`n,																	%A_scriptdir%\Updater.ahk
	FileAppend, ExitApp,																							%A_scriptdir%\Updater.ahk
}