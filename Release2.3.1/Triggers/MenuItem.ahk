Trigger_MenuItem_Init(Trigger)
{
	Trigger.Category := "System"
	Trigger.Menu := "MenuName"
	Trigger.Name := "Menu entry"
	Trigger.Submenu := ""
}
Trigger_MenuItem_ReadXML(Trigger, XMLTrigger)
{
	Trigger.Menu := XMLTrigger.Menu
	Trigger.Name := XMLTrigger.Name
	Trigger.Submenu := XMLTrigger.Submenu
}

Trigger_MenuItem_Enable(Trigger)
{
	if(Trigger.Menu = "Tray")
		BuildMenu("Tray")
}
Trigger_MenuItem_Disable(Trigger)
{
	if(Trigger.Menu = "Tray")
		BuildMenu("Tray")
}

Trigger_MenuItem_Delete(Trigger)
{
	if(Trigger.Menu = "Tray")
		BuildMenu("Tray")
}

Trigger_MenuItem_Matches(Trigger, Filter)
{
	return false
}

Trigger_MenuItem_DisplayString(Trigger)
{
	return "MenuItem " Trigger.Name " in " Trigger.Menu
}

Trigger_MenuItem_GuiShow(Trigger, TriggerGUI)
{
	global Settings_Events
	sTriggerGUI := TriggerGUI
	; SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Menu", "", "", "Menu:")
	Menus := Array()
	Loop % Settings_Events.len()
	{
		if(Settings_Events[A_Index].Trigger.Type = "MenuItem" && Menus.indexOf(Settings_Events[A_Index].Trigger.Menu) = 0)
		{
			Menus.append(Settings_Events[A_Index].Trigger.Menu)
			MenuString .= (Menus.len() = 1 ? "" : "|") Settings_Events[A_Index].Trigger.Menu
		}
	}
	
	SubEventGUI_Add(Trigger, TriggerGUI, "ComboBox", "Menu", MenuString, "", "Menu:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Name", "", "", "Name:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Submenu", "", "", "Submenu:")
}

Trigger_MenuItem_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GUISubmit(Trigger, TriggerGUI)
} 

MenuItemHandler:
MenuItemTriggered(A_ThisMenu, A_ThisMenuItem, A_ThisMenuItemPos)
return

MenuItemTriggered(menu, item, pos)
{
	global Events
	if(menu = "Tray")
		pos -= 10
	index := 1
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "MenuItem" && Events[A_Index].Trigger.Menu = menu)
		{
			if(index = pos)
			{
				Trigger := EventSystem_CreateSubEvent("Trigger", "Trigger")
				Trigger.TargetID := Events[A_Index].ID
				OnTrigger(Trigger)				
				return
			}
			index++
		}
	}
	outputdebug MenuItem: Event not found! menu: %menu%, item: %item%, pos: %pos%
}