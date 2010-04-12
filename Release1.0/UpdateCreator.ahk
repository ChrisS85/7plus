;FileDelete %a_scriptdir%\Updater.ahk
SetWorkingDir %a_scriptdir%
FileRemoveDir %A_TEMP%\7plusUpdateCreator,1
FolderLoop()
msgbox wait
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
		if A_LoopFileName contains Updater
			continue
		if (A_LoopFileName="7za.exe")
			continue
		if A_LoopFileLongPath contains .svn
			continue
		
		FileCreateDir %A_Temp%\7plusUpdateCreator\%A_LoopFileDir%
		FileCopy, %A_LoopFileLongPath%, %A_Temp%\7plusUpdateCreator\%A_LoopFileFullPath%
	}
}