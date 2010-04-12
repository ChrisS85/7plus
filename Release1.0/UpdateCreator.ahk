;FileDelete %a_scriptdir%\Updater.ahk
SetWorkingDir %a_scriptdir%
FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
FolderLoop()
runwait 7za.exe a "%a_scriptdir%\update.7z" "%A_TEMP%\7plusUpdateCreator\*", %a_scriptdir%,Hide
runwait Compiler\Compile_AHK.exe /nogui "%A_ScriptDir%\Updater.ahk"
FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
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