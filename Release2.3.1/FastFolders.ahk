#include *i %A_ScriptDir%\Navigate.ahk
#include *i %A_ScriptDir%\MiscFunctions.ahk
ClearStoredFolder(Slot)
{
	global
	WasCritical := A_IsCritical
	Critical
	local pos, name
	Slot+=1
	FastFolders[Slot].Path := ""
	FastFolders[Slot].Title := ""
	if (Settings.Explorer.FastFolders.ShowInFolderBand)
	{
		RemoveAllExplorerButtons("IsFastFolderButton")
		loop 10
		{
			pos:=A_Index-1
			if(FastFolders[A_Index].Path)
				AddButton("",FastFolders[A_Index].Path,,pos ":" FastFolders[A_Index].Title)
		}
	}
	if(!WasCritical)
		Critical, Off
}
UpdateStoredFolder(Slot, Folder="")
{
	global FastFolders
	Slot+=1
	if(Folder)
		FastFolders[Slot].Path := Folder
	else
		FastFolders[Slot].Path:=GetCurrentFolder()
	title:=FastFolders[Slot].Path	
	if(strStartsWith(title,"::") && WinActive("ahk_group ExplorerGroup"))
		WinGetTitle,title,A
	
	SplitPath, title , split
	FastFolders[Slot].Title := split
	if(!FastFolders[Slot].Title)
		FastFolders[Slot].Title:=title
	RefreshFastFolders()	
}

RefreshFastFolders()
{
	if(Settings.Explorer.FastFolders.ShowInFolderBand)
		RemoveAllExplorerButtons("IsFastFolderButton")
	AddAllButtons(Settings.Explorer.FastFolders.ShowInFolderBand, Settings.Explorer.FastFolders.ShowInPlacesBar)
}
AddAllButtons(FolderBand,PlacesBar)
{
	global
	local pos, value
	WasCritical := A_IsCritical
	Critical
	loop 10
	{
		pos:=A_Index-1
		if(FastFolders[A_Index].Path)
		{				
			if (FolderBand)		
				AddButton("",FastFolders[A_Index].Path,,pos ":" FastFolders[A_Index].Title)
			if(pos<=4 && PlacesBar)	;Also update placesbar
			{
				value:=FastFolders[A_Index].Path
				RegWrite, REG_SZ,HKCU,Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar, Place%pos%,%value%
			}				
		}
	}
	if(!WasCritical)
		Critical, Off
}
;Callback function for determining if a specific registry key was created by 7plus
IsFastFolderButton(Command,Title,Tooltip)
{
	x:=substr(Title,1,1)
	if(IsNumeric(x)&&substr(Title,2,1)=":")
		return true
	return false
}

FastFolderMenu()
{
	global
	Menu, FastFolders, add, 1,FastFolderMenuHandler1
	Menu, FastFolders, DeleteAll
	if ((IsWindowUnderCursor("ExploreWClass")||IsWindowUnderCursor("CabinetWClass")||IsWindowUnderCursor("WorkerW")||IsWindowUnderCursor("Progman")) && !IsRenaming())
	{
		win:=WinExist("A")
		y:=GetSelectedFiles()
		loop 10
		{
			i:=A_INDEX-1
			if(FastFolders[A_Index].Path)
			{
				x:=FastFolders[A_Index].Title
				if(x && (!strStartsWith(x,"ftp://")||!y))
				{
					x := "&" i ": " x
					Menu, FastFolders, add, %x%, FastFolderMenuHandler%i%
				}
			} 
		}
		hwnd:=WinExist("A")
		Menu, FastFolders, Show
		return true
	}	
	return false
}

FastFolderMenuHandler0:
FastFolderMenuClicked(0)
return
FastFolderMenuHandler1:
FastFolderMenuClicked(1)
return
FastFolderMenuHandler2:
FastFolderMenuClicked(2)
return
FastFolderMenuHandler3:
FastFolderMenuClicked(3)
return
FastFolderMenuHandler4:
FastFolderMenuClicked(4)
return
FastFolderMenuHandler5:
FastFolderMenuClicked(5)
return
FastFolderMenuHandler6:
FastFolderMenuClicked(6)
return
FastFolderMenuHandler7:
FastFolderMenuClicked(7)
return
FastFolderMenuHandler8:
FastFolderMenuClicked(8)
return
FastFolderMenuHandler9:
FastFolderMenuClicked(9)
return

FastFolderMenuClicked(index)
{
	global
	local y:=FastFolders[index].Path
	x:=GetSelectedFiles()
	StringReplace, x, x, `n , |, A
	if(x && (GetKeyState("CTRL") || GetKeyState("Shift")))
	{	
		if(GetKeyState("CTRL"))
			ShellFileOperation(0x2, x, y,0,hwnd)   
		else if(GetKeyState("Shift"))
			ShellFileOperation(0x1, x, y,0,hwnd)
	}
	else
	{
		Sleep 100
		SetDirectory(y)
	}
	Menu, FastFolders, DeleteAll
}

;Removes all buttons created with this script. Function can be the name of a function with these arguments: func(command,title,tooltip) and it can be used to tell the script if an entry may be deleted
RemoveAllExplorerButtons(function="")
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
;Removes a button. Command can either be a real command (with arguments), a path or a function with three arguments (command, key, param) which identifies the proper key
RemoveButton(Command, param="")
{
	if(!IsFunc(Command) && InStr(Command,"\",0,strlen(Command)))
		StringTrimRight, Command, Command,1
	;go into view folders (clsid)
	Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes, 2, 0
	{			
		regkey:=A_LoopRegName
		found:=-1
		maxnumber:=-1
		;loop through selected item number folders (loop goes backwards)
		Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected, 2, 0
		{
			numberfolder:=A_LoopRegName
			if(numberfolder>maxnumber)
			{
				maxnumber:=numberfolder
			}
			RegRead, ahk, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, AHK
			if(ahk)
			{
				;go into clsid folder
				Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, 2, 0
				{
					RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%, InfoTip
					outputdebug value %value%
					if((!IsFunc(Command) && value = Command) || (IsFunc(Command) && %Command%(value, "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\" regkey "\TasksItemsSelected\" numberfolder "\" A_LoopRegName "\shell\InvokeTask\command", param)))
					{					
						RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%
						found:=numberfolder
						break
					}
				}
				if(found>-1)
					break
			}
		}
		;after item has been deleted, we need to move the higher ones down by one
		if(found>-1&&maxnumber>found)
		{
			i:=found+1
			while i<=maxnumber
			{
				j:=i-1
				Runwait, reg copy HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%i% HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%j% /s /f, , Hide
				regdelete, HKLM,SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%i%
				i++
			}		
		}
		if(found=-1) {
			outputdebug Button not found!
			break
		}			
		found:=-1
		maxnumber:=-1
		;loop through no item selected number folders (loop goes backwards)
		Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected, 2, 0
		{
			numberfolder:=A_LoopRegName
			if(numberfolder>maxnumber)
			{
				maxnumber:=numberfolder
			}
			RegRead, ahk, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%, AHK
			if(ahk)
			{
				;go into clsid folder
				Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%, 2, 0
				{
					RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%\%A_LoopRegName%, InfoTip
					if((!IsFunc(Command) && value = Command) || (IsFunc(Command) && %Command%(value, "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\" regkey "\TasksNoItemsSelected\" numberfolder "\" A_LoopRegName "\shell\InvokeTask\command", param)))
					{											
						RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%numberfolder%						
						found:=numberfolder
						break
					}
				}
				if(found>-1)
					break
			}
		}
		;after item has been deleted, we need to move the higher ones down by one
		if(found>-1&&maxnumber>found)
		{
			i:=found+1
			while i<=maxnumber
			{
				j:=i-1
				Runwait, reg copy HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%i% HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%j% /s /f, , Hide
				regdelete, HKLM,SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%i%
				i++
			}		
		}
		if(found=-1) {
			outputdebug Button not found!
			break
		}
	}
}

;Adds a button. You may specify a command (and possibly an argument) or a path, and a name which should be used.
AddButton(Command,path,Args="",Name="", Tooltip="",AddTo = "Both")
{
	outputdebug addbutton command %command% path %path% args %args% name %name%
	if(A_IsCompiled)
		ahk_path:="""" A_ScriptDir "\7plus.exe"""
	else
		ahk_path := """" A_AhkPath """ """ A_ScriptFullPath """"
	icon=`%SystemRoot`%\System32\shell32.dll`,3 ;Icon is not working, probably not supported by explorer, some ms entries have icons defined but they don't show up either
	if(Command)
	{
		if(!Name)
		{
			SplitPath, Command , Name
			if(Name="")
				Name:=Command
		}
		icon:=Command ",1"
		description:=command
		command .= " " args
	}
	
	if(path)
	{				
		;Remove trailing backslash
		if( InStr(path,"\",0,strlen(path)))
			StringTrimRight, path, path,1
		if(!name)
		{
			SplitPath, path , Name
			if(Name="")
				Name:=path
		}
		Command := ahk_path " """ path """"	
		description:=path	
	}		
	if(!command && !path && args) ;args only, use start 7plus with -id param
	{
		Command := """" (A_IsCompiled ? A_ScriptPath : A_AhkPath """ """ A_ScriptFullPath) """ -id:" args
		description := Tooltip
	}
	outputdebug add name %name%
	SomeCLSID:="{" . uuid(false) . "}"
	;go into view folders (clsid)
	Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes, 2, 0
	{
		if(AddTo = "Both" || AddTo = "Selected")
		{
			;figure out first free key number
			iterations:=0
			regkey:=A_LoopRegName
			Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected, 2, 0
			{
				iterations++
			}
			
			;Marker for easier recognition of ahk-added entries
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%iterations%, AHK, 1
			;Write reg keys
			RegWrite, REG_EXPAND_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%iterations%\%SomeCLSID%, Icon, %icon%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%iterations%\%SomeCLSID%, InfoTip, %description%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%iterations%\%SomeCLSID%, Title, %name%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%iterations%\%SomeCLSID%\shell\InvokeTask\command, , %command%
		}
		if(AddTo = "Both" || AddTo = "NoSelected")
		{
			;Now the same for TasksNoItemsSelected
			iterations:=0
			;figure out first free key number
			Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected, 2, 0
			{
				iterations++
			}
			
			;Marker for easier recognition of ahk-added entries
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%iterations%, AHK, 1
			;Write reg keys
			RegWrite, REG_EXPAND_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%iterations%\%SomeCLSID%, Icon, %icon%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%iterations%\%SomeCLSID%, InfoTip, %description%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%iterations%\%SomeCLSID%, Title, %name%
			RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksNoItemsSelected\%iterations%\%SomeCLSID%\shell\InvokeTask\command, , %command%
		}
	}
}
FindButton(function, param)
{
	if(!IsFunc(function))
		return false
	OutputDebug FindButton
	;go into view folders (clsid)
	Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes, 2, 0
	{
		regkey:=A_LoopRegName
		maxnumber:=-1
		;loop through selected item number folders (loop goes backwards)
		Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected, 2, 0
		{
			numberfolder:=A_LoopRegName
			RegRead, ahk, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, AHK
			if(ahk)
			{
				;go into clsid folder
				Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, 2, 0
				{
					RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%\shell\InvokeTask\command
					if(%function%(value, "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\" regkey "\TasksItemsSelected\" numberfolder "\" A_LoopRegName "\shell\InvokeTask\command", param))
					{
						OutputDebug found
						return true
					}
				}
			}
		}
	}
	OutputDebug not found
	return false
}