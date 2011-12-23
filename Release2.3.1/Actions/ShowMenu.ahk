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
	Menu, Tray, UseErrorLevel
	Menu, %Name%, DeleteAll
	if(Name = "Tray")
		Menu, Tray, Standard
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
	if(Name = "Tray")
	{
		Menu, tray, add  ; Creates a separator line.
		Menu, tray, add, Settings, SettingsHandler  ; Creates a new menu item.
		menu, tray, Default, Settings
	}
	Menu, Tray, UseErrorLevel, Off
	return entries
}