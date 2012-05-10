Class CShowMenuAction Extends CAction
{
	static Type := RegisterType(CShowMenuAction, "Show menu")
	static Category := RegisterCategory(CShowMenuAction, "System")
	static Menu := ""
	static X := ""
	static Y := ""
	
	Execute(Event)
	{
		X := Event.ExpandPlaceholders(this.X)
		Y := Event.ExpandPlaceholders(this.Y)
		BuildMenu(this.Menu)
		Menu, Tray, UseErrorLevel
		Menu, % this.Menu, Show, %X%, %Y%
		Menu, Tray, UseErrorLevel, Off
		return 1
	} 

	DisplayString()
	{
		return "Show menu " this.Menu
	}

	GuiShow(GUI, GoToLabel = "")
	{
		static sGUI
		if(GoToLabel = "")
		{
			sGUI := GUI
			this.AddControl(GUI, "Text", "Desc", "This action shows a menu which is made up out of events with a Menu trigger and the same name as the name specified here.")
			;Look for menus in SettingsWindow.Events to catch unsaved menus
			Menus := Array()
			Loop % SettingsWindow.Events.MaxIndex()
			{
				if(SettingsWindow.Events[A_Index].Trigger.Is(CMenuItemTrigger) && Menus.indexOf(SettingsWindow.Events[A_Index].Trigger.Menu) = 0)
				{
					Menus.Insert(SettingsWindow.Events[A_Index].Trigger.Menu)
					MenuString .= (Menus.MaxIndex() = 1 ? "" : "|") SettingsWindow.Events[A_Index].Trigger.Menu
				}
			}
		
			this.AddControl(GUI, "ComboBox", "Menu", MenuString, "", "Menu:")
			this.AddControl(GUI, "Edit", "X", "", "", "X:", "Placeholders", "PlaceholdersX")
			this.AddControl(GUI, "Edit", "Y", "", "", "Y:", "Placeholders", "PlaceholdersY")
		}
		else if(GoToLabel = "PlaceholdersX")
			ShowPlaceholderMenu(sGUI, "X")
		else if(GoToLabel = "PlaceholdersY")
			ShowPlaceholderMenu(sGUI, "Y")
	}
}
PlaceholdersX:
GetCurrentSubEvent().GuiShow("", "PlaceholdersX")
return
PlaceholdersY:
GetCurrentSubEvent().GuiShow("", "PlaceholdersY")
return

BuildMenu(Name)
{
	global ClipboardList, ExplorerHistory
	Menu, Tray, UseErrorLevel
	Menu, %Name%, DeleteAll
	;Fake default menu items
	if(Name = "Tray")
	{
		Menu, tray, NoStandard
		if(!A_IsCompiled)
		{
			Menu, tray, add, Open, Tray_Open
			Menu, tray, add, Help, Tray_Help
			Menu, tray, add
			Menu, tray, add, Window Spy, Tray_Spy
		}
		Menu, tray, add, Reload This Script, Tray_Reload
		if(!A_IsCompiled)
			Menu, tray, add
		Menu, tray, add, Suspend Hotkeys, Tray_Suspend
		
		if(!A_IsCompiled)
			Menu, tray, add, Pause Script, Tray_Pause
		Menu, tray, add, Exit, Tray_Exit
	}
	else if(Name = "ClipboardMenu")
	{
		;Persistent clips
		Menu, PersistentClipboard, DeleteAll

		if(text := GetSelectedText())
			Menu, PersistentClipboard, add, Add selected text as persistent clip ..., AddClip

		Menu, PersistentClipboard, add, Edit persistent clips ..., EditClips

		if(ClipboardList.Persistent.MaxIndex())
			for index, Entry in ClipboardList.Persistent
				Menu, PersistentClipboard, add, % Entry.Name, PersistentClipboardHandler
		Menu, ClipboardMenu, add, Clips, :PersistentClipboard

		;Explorer history
		if(ExplorerHistory.MaxIndex())
		{
			Menu, ExplorerHistory, DeleteAll
			for index, Entry in ExplorerHistory.History
				Menu, ExplorerHistory, add, % Entry.Path, ExplorerHistoryHandler
			Menu, ClipboardMenu, add, Path History, :ExplorerHistory
			Menu, ExplorerFrequent, DeleteAll
			for index, Entry in ExplorerHistory.FrequentPaths
				Menu, ExplorerFrequent, add, % Entry.Path, ExplorerHistoryHandler
			Menu, ClipboardMenu, add, Frequent Paths, :ExplorerFrequent
		}

		;Clipboard history
		Loop % ClipboardList.MaxIndex()
		{
			x := ClipboardList[A_Index]
			StringReplace, x, x, `r,, All
			StringReplace, x, x, `n, [NEWLINE], All
			y := "`t"
			StringReplace, x, x, %y%, [TAB], All ;Weird syntax bug requires `t to be stored in a variable here
			x := "&" (A_Index - 1) ": " Substr(x, 1, 100)
			if(x)
				Menu, ClipboardMenu, add, %x%, ClipboardHandler%A_Index%
		}
	}
	;Add menu entries that are defined through events
	for index, Event in EventSystem.Events
	{
		if(Event.Trigger.Is(CMenuItemTrigger) && Event.Trigger.Menu = Name)
		{
			if(Event.Trigger.Submenu = "")
			{
				Menu, %Name%, add, % Event.Trigger.Name, MenuItemHandler
				if(!Event.Enabled)
					Menu, %Name%, disable, % Event.Trigger.Name
			}
			else
			{
				entries := BuildMenu(Event.Trigger.Submenu)
				if(entries)
					Menu, %Name%, add, % Event.Trigger.Name, % ":" Event.Trigger.Submenu
			}
			entries := true
		}
	}

	;Add tools for Tray menu
	if(Name = "Tray")
	{
		Loop %A_ScriptDir%\Tools\*.ahk, 0, 0
		{
			Menu, Tray_Debug_Tools, add, %A_LoopFileName%, Tray_Debug_Tools_Handler
			Added := true
		}
		Loop %A_ScriptDir%\Tools\*.exe, 0, 0
		{
			Menu, Tray_Debug_Tools, add, %A_LoopFileName%, Tray_Debug_Tools_Handler
			Added := true
		}
		if(Added)
			Menu, tray, add, Tools, :Tray_Debug_Tools
		
		Menu, tray, add  ; Creates a separator line.
		Menu, tray, add, Settings, SettingsHandler  ; Creates a new menu item.
		menu, tray, Default, Settings
	}
	Menu, Tray, UseErrorLevel, Off
	return entries
}

Tray_Debug_Tools_Handler:
run % A_ScriptDir "\Tools\" A_ThisMenuItem
return

Tray_Open:
ListLines
return

Tray_Help:
Run %A_AhkPath%\..\AutoHotkey.chm
Return

Tray_Pause:
if(A_IsPaused)
	Menu, Tray, UnCheck, Pause Script
else
	Menu, Tray, Check, Pause Script
Pause Toggle
return

Tray_Reload:
   GoSub ReloadSub
Return

Tray_Suspend:
Suspend, Toggle
if(A_IsSuspended)
	Menu, Tray, Check, Suspend Hotkeys
else
	Menu, Tray, Uncheck, Suspend Hotkeys
return

Tray_Spy:   ;   Run Edit With SciTE 
   Run %A_AHKPath%\..\AU3_Spy.exe
Return 


Tray_Exit: ; exit script label 
   GoSub ExitSub
return