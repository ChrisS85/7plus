Trigger_ContextMenu_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.Name := "Context menu entry"
	Trigger.Description := "Context menu entry description"
	Trigger.SubMenu := ""
	Trigger.Directory := false
	Trigger.DirectoryBackground := false
	Trigger.Desktop := false
	; Trigger.Drive := false
	Trigger.Computer := false
}
Trigger_ContextMenu_ReadXML(Trigger, XMLTrigger)
{
	Trigger.FileTypes := XMLTrigger.FileTypes
	Trigger.Name := XMLTrigger.Name
	Trigger.Description := XMLTrigger.Description
	Trigger.Directory := XMLTrigger.Directory
	Trigger.DirectoryBackground := XMLTrigger.DirectoryBackground
	Trigger.Desktop := XMLTrigger.Desktop
	; Trigger.Drive := XMLTrigger.Drive
	Trigger.Computer := XMLTrigger.Computer
	Trigger.SubMenu := XMLTrigger.SubMenu
}

Trigger_ContextMenu_Enable(Trigger, Event)
{
	if(A_IsCompiled)
		ahk_path:="""" A_ScriptDir "\7plus.exe"""
	else
		ahk_path := """" A_AhkPath """ """ A_ScriptFullPath """"
	id := Event.ID
	files := Trigger.FileTypes
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, ID, %id%
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Name, % Trigger.Name
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Description, % Trigger.Description
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Submenu, % Trigger.Submenu
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Extensions, % Trigger.FileTypes
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Directory, % Trigger.Directory
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, DirectoryBackground, % Trigger.DirectoryBackground
	; RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Drive, % Trigger.Drive
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Desktop, % Trigger.Desktop
	; RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Computer, % Trigger.Computer
	; name := Trigger.Name
	; Loop, Parse, files,`,
	; {
		; RegRead, newpath, HKCR, .%A_LoopField%
		; if(!newpath)
			; newpath := "." A_LoopField
		; if(A_LoopField="*")
			; newpath := "*"
		; if(Trigger.SubMenu = "")
			; key := newpath "\shell\" Trigger.Name
		; else
		; {
			; key := newpath "\shell\" Trigger.SubMenu
			; RegWrite, REG_SZ, HKCR, %key%,subcommands,
			; key := newpath "\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegWrite, REG_SZ, HKCR, %key%,, %name%
		; }
		; RegDelete, HKCR, %key%
		; RegWrite, REG_EXPAND_SZ, HKCR, %key%\command,, %ahk_path% -ContextID:%id%
	; }
	; if(Trigger.Directory)
	; {
		; if(Trigger.SubMenu = "")
			; key := "shell\" Trigger.Name "\command"
		; else
		; {
			; key := "shell\" Trigger.SubMenu
			; RegWrite, REG_SZ, HKCR, Directory\%key%,subcommands,
			; key := "shell\" Trigger.SubMenu "\shell\" Trigger.Name 
			; RegWrite, REG_SZ, HKCR, Directory\%key%,, %name%
		; }
		; RegWrite, REG_SZ, HKCR, Directory\%key%\command,, %ahk_path% -ContextID:%id%
	; }
	; if(Trigger.DirectoryBackground)
	; {
		; if(Trigger.SubMenu = "")
			; key := "shell\" Trigger.Name "\command"
		; else
		; {
			; key := "shell\" Trigger.SubMenu
			; RegWrite, REG_SZ, HKCR, Directory\Background\%key%,subcommands,
			; key := "shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegWrite, REG_SZ, HKCR, Directory\Background\%key%,, %name%
		; }
		; RegWrite, REG_SZ, HKCR, Directory\Background\%key%\command,, %ahk_path% -ContextID:%id%
	; }
	; if(Trigger.Desktop)
	; {
		; if(Trigger.SubMenu = "")
			; key := "shell\" Trigger.Name "\command"
		; else
		; {
			; key := "shell\" Trigger.SubMenu
			; RegWrite, REG_SZ, HKCR, DesktopBackground\%key%,subcommands,
			; key := "shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegWrite, REG_SZ, HKCR, DesktopBackground\%key%,, %name%
		; }
		; RegWrite, REG_SZ, HKCR, DesktopBackground\%key%\command,, %ahk_path% -ContextID:%id%
	; }
	; if(Trigger.Drive)
	; {
		; if(Trigger.SubMenu = "")
			; key := "shell\" Trigger.Name "\command"
		; else
		; {
			; key := "shell\" Trigger.SubMenu
			; RegWrite, REG_SZ, HKCR, Drive\%key%,subcommands,
			; key := "shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegWrite, REG_SZ, HKCR, Drive\%key%,, %name%
		; }
		; RegWrite, REG_SZ, HKCR, Drive\%key%\command,, %ahk_path% -ContextID:%id%
	; }
	if(Trigger.Computer)
	{
		if(Trigger.SubMenu = "")
			key := "shell\" Trigger.Name "\command"
		else
		{
			key := "shell\" Trigger.SubMenu
			RegWrite, REG_SZ, HKCR, CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\%key%,subcommands,
			key := "shell\" Trigger.SubMenu "\shell\" Trigger.Name
			RegWrite, REG_SZ, HKCR, CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\%key%,, %name%
		}
		RegWrite, REG_SZ, HKCR, CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\%key%,, %ahk_path% -ContextID:%id%
	}
}
Trigger_ContextMenu_Disable(Trigger)
{
	RegDelete, HKCU, Software\7plus\ContextMenuEntries
	; files := Trigger.FileTypes
	; Loop, Parse, files,`,
	; {
		; RegRead, newpath, HKCR, .%A_LoopField%
		; if(!newpath)
			; newpath := "." A_LoopField
		; if(A_LoopField="*")
			; newpath := "*"
		; if(Trigger.SubMenu = "")
		; {
			; key := newpath "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
		; }
		; else
		; {
			; key := newpath "\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
			; key := newpath "\shell\" Trigger.SubMenu "\shell"
			; found := false
			; Loop, HKCR , %key%, 2, 0
			; {
				; found := true
				; break
			; }
			; if(!found)
			; {
				; key := newpath "\shell\" Trigger.SubMenu
				; RegDelete, HKCR, %key%
			; }
		; }
	; }
	; if(Trigger.Directory)
	; {
		; if(Trigger.SubMenu = "")
		; {
			; key := "Directory\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
		; }
		; else
		; {
			; key := "Directory\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
			; key := "Directory\shell\" Trigger.SubMenu "\shell"
			; found := false
			; Loop, HKCR , %key%, 2, 0
			; {
				; found := true
				; break
			; }
			; if(!found)
			; {
				; key := "Directory\shell\" Trigger.SubMenu
				; RegDelete, HKCR, %key%
			; }
		; }
	; }
	; if(Trigger.DirectoryBackground)
	; {
		; if(Trigger.SubMenu = "")
		; {
			; key := "Directory\Background\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
		; }
		; else
		; {
			; key := "Directory\Background\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
			; key := "Directory\Background\shell\" Trigger.SubMenu "\shell"
			; found := false
			; Loop, HKCR , %key%, 2, 0
			; {
				; found := true
				; break
			; }
			; if(!found)
			; {
				; key := "Directory\Background\shell\" Trigger.SubMenu
				; RegDelete, HKCR, %key%
			; }
		; }
	; }
	; if(Trigger.Desktop)
	; {
		; if(Trigger.SubMenu = "")
		; {
			; key := "DesktopBackground\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
		; }
		; else
		; {
			; key := "DesktopBackground\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
			; key := "DesktopBackground\shell\" Trigger.SubMenu "\shell"
			; found := false
			; Loop, HKCR , %key%, 2, 0
			; {
				; found := true
				; break
			; }
			; if(!found)
			; {
				; key := "DesktopBackground\shell\" Trigger.SubMenu
				; RegDelete, HKCR, %key%
			; }
		; }
	; }
	; if(Trigger.Drive)
	; {
		; if(Trigger.SubMenu = "")
		; {
			; key := "Drive\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
		; }
		; else
		; {
			; key := "Drive\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			; RegDelete, HKCR, %key%
			; key := "Drive\shell\" Trigger.SubMenu "\shell"
			; found := false
			; Loop, HKCR , %key%, 2, 0
			; {
				; found := true
				; break
			; }
			; if(!found)
			; {
				; key := "Drive\shell\" Trigger.SubMenu
				; RegDelete, HKCR, %key%
			; }
		; }
	; }
	if(Trigger.Computer)
	{
		if(Trigger.SubMenu = "")
		{
			key := "CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\" Trigger.Name
			RegDelete, HKCR, %key%
		}
		else
		{
			key := "CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\" Trigger.SubMenu "\shell\" Trigger.Name
			RegDelete, HKCR, %key%
			key := "CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\" Trigger.SubMenu "\shell"
			found := false
			Loop, HKCR , %key%, 2, 0
			{
				found := true
				break
			}
			if(!found)
			{
				key := "CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\" Trigger.SubMenu
				RegDelete, HKCR, %key%
			}
		}
	}
}
;When ContextMenu is deleted, it needs to be removed from ContextMenuarrays
Trigger_ContextMenu_Delete(Trigger)
{
	Trigger_ContextMenu_Disable(Trigger)
}

Trigger_ContextMenu_Matches(Trigger, Filter, Event)
{
	global ShellHookMsgNum
	return false ;Match is handled in Eventsystem.ahk through trigger event
}

Trigger_ContextMenu_DisplayString(Trigger)
{
	return "Context menu entry: " Trigger.Name
}

Trigger_ContextMenu_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "tmpText", "This trigger allows you to add context menu entries.")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Name", "", "", "Name:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Description", "", "", "Description:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "SubMenu", "", "", "Submenu:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "FileTypes", "", "", "File types:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Directory", "Show in directory context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "DirectoryBackground", "Show in directory background context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Desktop", "Show in desktop context menu")
	; SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Drive", "Show in drive context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Computer", "Show in ""My Computer"" context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Register", "Register context menu shell extension", "RegisterShellExtension", "")
	SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Unregister", "Unregister context menu shell extension", "UnregisterShellExtension", "")
}
RegisterShellExtension:
RegisterShellExtension(0)
return
UnregisterShellExtension:
UnregisterShellExtension(0)
return

RegisterShellExtension(Silent=1)
{
	global IsPortable
	if(!IsPortable)
	{
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
		If(uacrep = 42 && !Silent) ;UAC Prompt confirmed, application may run as admin
			MsgBox Shell extension successfully installed. Context menu entries defined in 7plus should now be visible.
		else ;Always show error
			MsgBox Unable to install the context menu shell extension. Please grant Admin permissions!
	}
	else if(!Silent)
		MsgBox Context menu shell extension can only be used in non-portable mode for now.
}
UnregisterShellExtension(Silent=1)
{
	uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s /u """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
	If(uacrep = 42 && !Silent) ;UAC Prompt confirmed, application may run as admin
		MsgBox Shell extension successfully deinstalled. All 7plus context menu entries should now be gone.
	else ;Always show error
		MsgBox Unable to deinstall the context menu shell extension. Please grant Admin permissions!
}
Trigger_ContextMenu_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger,TriggerGUI)
}  