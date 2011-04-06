#NoTrayIcon
if(!A_IsCompiled)
	ExitApp
SetWorkingDir %A_Temp%\7plus
IniRead, ConfigPath, %A_Temp%\7plus\Update.ini, Update, ConfigPath, %A_AppData%\7plusIniRead, ScriptDir, %A_Temp%\7plus\Update.ini, Update, ScriptDir, %A_ProgramFiles%\7plusFileInstall, D:\Projekte\Autohotkey\7plus\Update.zip, Update.zip,1
FileInstall, D:\Projekte\Autohotkey\7plus\7za.exe, 7za.exe,1
runwait 7za.exe x -y Update.zip, %A_Temp%\7plus\Update, hide
FileMoveDir, %A_Temp%\7plus\Update\Patches, %ConfigPath%\Patches, 2FileMove, %A_Temp%\7plus\Update, %ScriptDir%, 2FileDelete 7za.exe
FileDelete Update.zip
if(FileExist(ScriptDir "7plus.ahk"))
	run %ScriptDir%\7plus.ahk
else if(FileExist(ScriptDir "7plus.exe"))
	run %ScriptDir%\7plus.exe
ExitApp
