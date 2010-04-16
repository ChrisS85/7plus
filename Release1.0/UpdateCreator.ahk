SetWorkingDir %a_scriptdir%
FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
FileDelete Updater.exe
FolderLoop()
runwait 7za.exe a -y "%a_scriptdir%\update.7z" "%A_TEMP%\7plusUpdateCreator\*", %a_scriptdir%,Hide
WriteUpdater()
sleep 500
runwait %a_scriptdir%\update.7z
sleep 500
runwait Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\Updater.ahk"
sleep 500
FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
FileDelete %a_scriptdir%\update.7z
return
FolderLoop()
{	
	Loop *.*,0,1 ;Extract files
	{
		if A_LoopFileName contains UpdateCreator
			continue
		if A_LoopFileName contains Update
			continue
		if A_LoopFileName contains .ini
			continue
		if (A_LoopFileName="7za.exe")
			continue
		if (A_LoopFileName="Version.ini")
			continue
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
		FileCreateDir %A_Temp%\7plusUpdateCreator\%A_LoopFileDir%
		FileCopy, %A_LoopFileLongPath%, %A_Temp%\7plusUpdateCreator\%A_LoopFileFullPath%
	}
}
WriteUpdater()
{
	FileDelete %A_scriptdir%\Updater.ahk
	FileAppend, #NoTrayIcon`n,%A_scriptdir%\Updater.ahk
	FileAppend, SetWorkingDir `%A_scriptdir`%`n,%A_scriptdir%\Updater.ahk
	FileAppend, Progress zh0 fs18`, Updating, please wait.`n,%A_scriptdir%\Updater.ahk
	FileAppend, FileInstall`, %A_scriptdir%\Update.7z`, Update.7z`,1`n,%A_scriptdir%\Updater.ahk
	FileAppend, FileInstall`, %A_scriptdir%\7za.exe`, 7za.exe`,1`n,%A_scriptdir%\Updater.ahk
	FileAppend, runwait 7za.exe x -y Update.7z`, `%a_scriptdir`%`,hide`n,%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete 7za.exe`n,%A_scriptdir%\Updater.ahk
	FileAppend, FileDelete Update.7z`n,%A_scriptdir%\Updater.ahk
	FileAppend, if(FileExist("7plus.ahk"))`n,%A_scriptdir%\Updater.ahk
	FileAppend, `trun 7plusahk`n,%A_scriptdir%\Updater.ahk
	FileAppend, else if(FileExist("7plus.exe"))`n,%A_scriptdir%\Updater.ahk
	FileAppend, `trun 7plus.exe`n,%A_scriptdir%\Updater.ahk
	FileAppend, ExitApp`n,%A_scriptdir%\Updater.ahk
}