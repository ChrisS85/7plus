#NoTrayIcon
if(!A_IsCompiled)
	ExitApp
SetWorkingDir %A_scriptdir%
FileInstall, C:\Projekte\Autohotkey\7plus\Update.zip, Update.zip,1
FileInstall, C:\Projekte\Autohotkey\7plus\7za.exe, 7za.exe,1
runwait 7za.exe x -y Update.zip, %a_scriptdir%,hide
FileDelete 7za.exe
FileDelete Update.zip
FileDelete %A_Temp%\7plus
FileMoveDir %A_scriptdir%\ReleasePatch,%A_Temp%\7plus\ReleasePatch, 2
if(FileExist("7plus.ahk"))
	run 7plus.ahk
else if(FileExist("7plus.exe"))
	run 7plus.exe
ExitApp
