Action_ShowMenu_Init(Action)
{
	Action.Category := "System"
	Menu := ""
	X := ""
	Y := ""
}

Action_ShowMenu_ReadXML(Action, XMLAction)
{
	Action.Menu := XMLAction.Menu
	Action.X := XMLAction.X
	Action.Y := XMLAction.Y
}

Action_ShowMenu_Execute(Action, Event)
{
	global ImageExtensions
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
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Menu", "", "", "Menu Name:")
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
	Menu, %Name%, Delete
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
	Menu, Tray, UseErrorLevel, Off
	return entries
}