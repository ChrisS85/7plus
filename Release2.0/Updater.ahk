#NoTrayIcon
SetWorkingDir %A_scriptdir%
FileInstall, C:\Program Files\Autohotkey\Update.7z, Update.7z,1
FileInstall, C:\Program Files\Autohotkey\7za.exe, 7za.exe,1
runwait 7za.exe x -y Update.7z, %a_scriptdir%,hide
FileDelete 7za.exe
FileDelete Update.7z
if(FileExist("7plus.ahk"))
	run 7plus.ahk
else if(FileExist("7plus.exe"))
	run 7plus.exe
ExitApp
