Action_ShowMenu_Init(Action)
{
	Action.Category := "System"
	Action.Menu := ""
	Action.X := ""
	Action.Y := ""
}

Action_ShowMenu_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Menu")
	Action.ReadVar(XMLAction, "X")
	Action.ReadVar(XMLAction, "Y")
}

Action_ShowMenu_Execute(Action, Event)
{
	X := Event.ExpandPlaceholders(Action.X)
	Y := Event.ExpandPlaceholders(Action.Y)
	BuildMenu(Action.Menu)
	Menu, Tray, UseErrorLevel
	Menu, % Action.Menu, Show, %X%, %Y%
	Menu, Tray, UseErrorLevel, Off
	return 1
} 

Action_ShowMenu_DisplayString(Action)
{
	return "Show menu " Action.Menu
}

Action_ShowMenu_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action shows a menu which is made up out of events with a Menu trigger and the same name as the name specified here.")
		;Look for menus in SettingsWindow.Events to catch unsaved menus
		Menus := Array()
		Loop % SettingsWindow.Events.len()
		{
			if(SettingsWindow.Events[A_Index].Trigger.Type = "MenuItem" && Menus.indexOf(SettingsWindow.Events[A_Index].Trigger.Menu) = 0)
			{
				Menus.Insert(SettingsWindow.Events[A_Index].Trigger.Menu)
				MenuString .= (Menus.len() = 1 ? "" : "|") SettingsWindow.Events[A_Index].Trigger.Menu
			}
		}
	
		SubEventGUI_Add(Action, ActionGUI, "ComboBox", "Menu", MenuString, "", "Menu:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "X", "", "", "X:", "Placeholders", "Action_ShowMenu_PlaceholdersX")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Y", "", "", "Y:", "Placeholders", "Action_ShowMenu_PlaceholdersY")
	}
	else if(GoToLabel = "PlaceholdersX")
		SubEventGUI_Placeholders(sActionGUI, "X")
	else if(GoToLabel = "PlaceholdersY")
		SubEventGUI_Placeholders(sActionGUI, "Y")
}

Action_ShowMenu_PlaceholdersX:
Action_ShowMenu_GuiShow(Action, ActionGUI, "PlaceholdersX")
return
Action_ShowMenu_PlaceholdersY:
Action_ShowMenu_GuiShow(Action, ActionGUI, "PlaceholdersY")
return

Action_ShowMenu_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 

BuildMenu(Name)
{
	global Events
	Menu, Tray, UseErrorLevel
	Menu, %Name%, DeleteAll
	if(Name = "Tray")
		Menu, Tray, Standard
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "MenuItem" && Events[A_Index].Trigger.Menu = Name)
		{
			if(Events[A_Index].Trigger.Submenu = "")
			{
				Menu, %Name%, add, % Events[A_Index].Trigger.Name, MenuItemHandler
				if(!Events[A_Index].Enabled)
					Menu, %Name%, disable, % Events[A_Index].Trigger.Name
			}
			else
			{
				entries := BuildMenu(Events[A_Index].Trigger.Submenu)
				if(entries)
					Menu, %Name%, add, % Events[A_Index].Trigger.Name, % ":" Events[A_Index].Trigger.Submenu
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