#include %A_ScriptDir%\lib\com.ahk
#include %A_ScriptDir%\Registry.ahk
MsgBox, 4,, Do you really want to uninstall 7plus? This will delete the folder where 7plus is installed, possibly %A_AppData%\7plus and undo all changes to the registry
IfMsgBox Yes
{
	if(FileExist(A_ScriptDir "\7plus.exe") || FileExist(A_ScriptDir "\7plus.ahk"))
	{
		DetectHiddenWindows, On	
		FileRead, hwnd, %A_Temp%\7plus\hwnd.txt
		if(WinExist("ahk_id " hwnd))
		{
			WinGet, pid, pid, ahk_id %hwnd%
			Process, Close, %pid%
		}
		FileRemoveDir, %A_Temp%\7plus
		FileRemoveDir, %A_AppData%\7plus
		FileRemoveDir, %A_ScriptDir%\7plus
		RemoveAllButtons()
		RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus
		RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick, 0
		RestoreFolderBandButtons()
		RestorePlacesBar()
		RestoreFolderBand()
		if(A_IsCompiled)
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptDir%\7plus.exe
		else
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_ScriptDir%\7plus.ahk
		Msgbox 7plus was uninstalled successfully. Please report any possible errors or problems that caused you to uninstall it.
	}
}
;Removes all buttons created with this script. Function can be the name of a function with these arguments: func(command,title,tooltip) and it can be used to tell the script if an entry may be deleted
RemoveAllButtons(function="")
{
	;go into view folders (clsid)
	Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes, 2, 0
	{			
		regkey:=A_LoopRegName
		;go into number folder
		Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected, 2, 0
		{
			numberfolder:=A_LoopRegName			
			
			;Custom skip function code
			;go into clsid folder
			Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, 2, 0
			{
				skip:=false
				RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%, InfoTip
				RegRead, title, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%, Title
				RegRead, cmd, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%\shell\InvokeTask\command
				
				if(IsFunc(function))
					if(!%function%(cmd,title,value))
					{
						skip:=true
						break
					}
			}
			if(skip) 
				continue
			;Custom skip function code
			RegRead, ahk, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, AHK			
			if(ahk)
				RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%
		}
		Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected, 2, 0
		{
			numberfolder:=A_LoopRegName
			
			
			;Custom skip function code
			;go into clsid folder
			Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%, 2, 0
			{
				skip:=false
				RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%\%A_LoopRegName%, InfoTip
				RegRead, title, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%\%A_LoopRegName%, Title
				RegRead, cmd, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%\%A_LoopRegName%\shell\InvokeTask\command
				
				if(IsFunc(function))
					if(!%function%(cmd,title,value))
					{
						skip:=true
						break
					}
			}
			if(skip) 
				continue
			;Custom skip function code
			
			
			RegRead, ahk, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%, AHK
			if(ahk)
				RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%
		}
	}
}