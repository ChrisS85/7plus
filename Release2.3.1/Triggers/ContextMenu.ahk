Trigger_ContextMenu_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.Name := "Context menu entry"
	Trigger.Description := "Context menu entry description"
	Trigger.SubMenu := ""
	Trigger.Directory := false
	Trigger.DirectoryBackground := false
	Trigger.Desktop := false
	Trigger.Computer := false
	Trigger.SingleFileOnly := false
}
Trigger_ContextMenu_ReadXML(Trigger, XMLTrigger)
{
	Trigger.ReadVar(XMLTrigger, "FileTypes")
	Trigger.ReadVar(XMLTrigger, "Name")
	Trigger.ReadVar(XMLTrigger, "Description")
	Trigger.ReadVar(XMLTrigger, "Directory")
	Trigger.ReadVar(XMLTrigger, "DirectoryBackground")
	Trigger.ReadVar(XMLTrigger, "Desktop")
	Trigger.ReadVar(XMLTrigger, "Computer")
	Trigger.ReadVar(XMLTrigger, "SubMenu")
	Trigger.ReadVar(XMLTrigger, "SingleFileOnly")
}

Trigger_ContextMenu_Enable(Trigger, Event)
{
	if(A_IsCompiled)
		ahk_path:="""" A_ScriptDir "\7plus.exe"""
	else
		ahk_path := """" A_AhkPath """ """ A_ScriptFullPath """"
	id := Event.ID
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, ID, %id%
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Name, % Trigger.Name
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Description, % Trigger.Description
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Submenu, % Trigger.Submenu
	RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%id%, Extensions, % Trigger.FileTypes
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Directory, % Trigger.Directory
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, DirectoryBackground, % Trigger.DirectoryBackground
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, Desktop, % Trigger.Desktop
	RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%id%, SingleFileOnly, % Trigger.SingleFileOnly

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
	return false ;Match is handled in Eventsystem.ahk through trigger event
}

Trigger_ContextMenu_DisplayString(Trigger)
{
	return "Context menu: " Trigger.Name
}

Trigger_ContextMenu_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "tmpText", "This trigger allows you to add context menu entries.")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Name", "", "", "Name:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Description", "", "", "Description:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "SubMenu", "", "", "Submenu:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "FileTypes", "", "", "File types:", "", "", "", "", "File extensions separated by comma")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Directory", "Show in directory context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "DirectoryBackground", "Show in directory background context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Desktop", "Show in desktop context menu")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "Computer", "Show in ""My Computer"" context menus")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "SingleFileOnly", "Don't show with multiple files selected")
	SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Register", "Register context menu shell extension", "RegisterShellExtension", "")
	SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Unregister", "Unregister context menu shell extension", "UnregisterShellExtension", "")
}
RegisterShellExtension:
RegisterShellExtension(0)
return
UnregisterShellExtension:
Msgbox, 4, Unregister Shell Extension?, WARNING: If you unregister the shell extension, 7plus will not be able`n to show context menu entries. Do this only if you have problems with the shell extension.`nDo you really want to do this?
IfMsgbox Yes
	UnregisterShellExtension(0)
return

RegisterShellExtension(Silent=1)
{
	global IsPortable, Vista7
	if(!IsPortable)
	{
		if(Vista7)
			uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
		else
			run regsvr32 /s "%A_ScriptDir%\ShellExtension.dll"
		If(uacrep = 42|| !Vista7) ;UAC Prompt confirmed, application may run as admin
		{
			if(!Silent)
				MsgBox Shell extension successfully installed. Context menu entries defined in 7plus should now be visible.
		}
		else ;Always show error
			MsgBox Unable to install the context menu shell extension. Please grant Admin permissions!
	}
	else if(!Silent)
		MsgBox Context menu shell extension can only be used in non-portable mode for now.
}
UnregisterShellExtension(Silent=1)
{
	global IsPortable, Vista7
	if(!IsPortable)
	{
		if(Vista7)
			uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s /u """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
		else
			run regsvr32 /s /u "%A_ScriptDir%\ShellExtension.dll"
		If(uacrep = 42) ;UAC Prompt confirmed, application may run as admin
		{
			if(!Silent)
				MsgBox Shell extension successfully deinstalled. All 7plus context menu entries should now be gone.
		}
		else ;Always show error
			MsgBox Unable to deinstall the context menu shell extension. Please grant Admin permissions!
	}
	else if(!Silent)
		MsgBox Context menu shell extension can only be used in non-portable mode for now.
}
Trigger_ContextMenu_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger,TriggerGUI)
}  