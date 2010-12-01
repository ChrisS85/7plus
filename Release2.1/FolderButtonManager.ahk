;#include %A_ScriptDir%\lib\com.ahk
;Some stuff here to use those functions separately to add custom buttons, might have to be expanded a bit later on
if(A_OSVersion!="WIN_VISTA" && A_OSVersion!="WIN_7")
{
	MsgBox This program is only used for Windows Vista and Windows 7. 
	return
}
MsgBox, 4,, This program allows you to add buttons to the explorer bar.`nWould you like to add a button(yes) or remove one(no)?
IfMsgBox Yes
{
	path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Enter Path to add as button", 0).Self.Path
	SplitPath, path , foldername
	if(foldername="")
		foldername:=path
	InputBox, foldername , Enter the title for the button, Enter the title for the button, , , , , , , , %foldername%
	if Errorlevel
		return
	AddButton("",path,,foldername)
}
IfMsgBox No
{
	MsgBox, 4,, Would you like to remove one button (yes) or remove all buttons(no) made by this script ?
	IfMsgBox Yes
	{
		path:=COMObjCreate("Shell.Application").BrowseForFolder(0, "Enter Path which should be removed", 0).Self.Path
		RemoveButton(path)
	}
	IfMsgBox No
	{
		RemoveAllButtons()
	}
}
return
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
		Command := """" (A_IsCompiled ? A_ScriptPath : A_AhkPath """ """ A_ScriptFullPath) """ -id " args
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
	outputdebug find button %function% %param%
	if(!IsFunc(function))
		return false
	outputdebug isfunction
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
				outputdebug ahk SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%
				;go into clsid folder
				Loop, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%, 2, 0
				{
					RegRead, value, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\%regkey%\TasksItemsSelected\%numberfolder%\%A_LoopRegName%\shell\InvokeTask\command
					outputdebug value %value%
					if(%function%(value, "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\" regkey "\TasksItemsSelected\" numberfolder "\" A_LoopRegName "\shell\InvokeTask\command", param))
						return true
				}
			}
		}
	}
	return false
}
uuid(c = false) { ; v1.1 - by Titan 
   static n = 0, l, i 
   f := A_FormatInteger, t := A_Now, s := "-" 
   SetFormat, Integer, H 
   t -= 1970, s 
   t := (t . A_MSec) * 10000 + 122192928000000000 
   If !i and c { 
      Loop, HKLM, System\MountedDevices 
      If i := A_LoopRegName 
         Break 
      StringGetPos, c, i, %s%, R2 
      StringMid, i, i, c + 2, 17 
   } Else { 
      Random, x, 0x100, 0xfff 
      Random, y, 0x10000, 0xfffff 
      Random, z, 0x100000, 0xffffff 
      x := 9 . SubStr(x, 3) . s . 1 . SubStr(y, 3) . SubStr(z, 3) 
   } t += n += l = A_Now, l := A_Now 
   SetFormat, Integer, %f% 
   Return, SubStr(t, 10) . s . SubStr(t, 6, 4) . s . 1 . SubStr(t, 3, 3) . s . (c ? i : x) 
}
