#NoTrayIcon
SetWorkingDir %A_Temp%\7plus
IniRead, ConfigPath, %A_Temp%\7plus\Update.ini, Update, ConfigPath, %A_AppData%\7plus
IniRead, ScriptDir, %A_Temp%\7plus\Update.ini, Update, ScriptDir, %A_ProgramFiles%\7plus
FileInstall, C:\Projekte\Autohotkey\7plus\Update.7z, Update.7z,1
FileInstall, C:\Projekte\Autohotkey\7plus\7za.exe, 7za.exe,1
runwait 7za.exe x -y Update.7z, %A_Temp%\7plus\Update, hide
FileMoveDir, %A_Temp%\7plus\Update\Patches, %ConfigPath%\Patches, 2
FileMove, %A_Temp%\7plus\Update, %ScriptDir%, 2
FileDelete 7za.exe
FileDelete Update.7z
if(FileExist("7plus.ahk"))
	run 7plus.ahk
else if(FileExist("7plus.exe"))
	run 7plus.exe
ExitApp
