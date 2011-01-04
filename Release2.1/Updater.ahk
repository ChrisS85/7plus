#NoTrayIcon
SetWorkingDir %A_scriptdir%
FileInstall, C:\Projekte\Autohotkey\7plus\Update.zip, Update.zip,1
FileInstall, C:\Projekte\Autohotkey\7plus\7za.exe, 7za.exe,1
runwait 7za.exe x -y Update.zip, %a_scriptdir%,hide
FileDelete 7za.exe
FileDelete Update.zip
if(FileExist("7plus.ahk"))
	run 7plus.ahk
else if(FileExist("7plus.exe"))
	run 7plus.exe
ExitApp
