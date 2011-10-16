Trigger_ExplorerButton_Init(Trigger)
{
	Trigger.Category := "Explorer"
	Trigger.Name := "ExplorerButton"
	Trigger.Tooltip := "ExplorerButton"
	Trigger.ShowSelected := true
	Trigger.ShowNoSelected := true
}
Trigger_ExplorerButton_ReadXML(Trigger, XMLTrigger)
{
	Trigger.ReadVar(XMLTrigger, "Name")
	Trigger.ReadVar(XMLTrigger, "Tooltip")
	Trigger.ReadVar(XMLTrigger, "ShowSelected")
	Trigger.ReadVar(XMLTrigger, "ShowNoSelected")
}

Trigger_ExplorerButton_Enable(Trigger, Event)
{
	global
	if(!IsPortable && A_IsAdmin && Vista7 && !FindButton("IsExplorerButton", Event))
		AddButton("","",Event.ID, Trigger.Name, Trigger.Tooltip, (Trigger.ShowSelected && Trigger.ShowNoSelected ? "Both" : Trigger.ShowSelected ? "Selected" : Trigger.ShowNoSelected ? "NoSelected" : "")) ;Event.ID here
}
Trigger_ExplorerButton_Disable(Trigger, Event)
{
	global
	if(Event.Disabled && A_IsAdmin && Vista7 && !IsPortable)
		RemoveButton("IsExplorerButton", Event)
}
Trigger_ExplorerButton_Delete(Trigger, Event)
{
	global
	if(!IsPortable && Vista7 && A_IsAdmin)
		RemoveButton("IsExplorerButton", Event)
}
Trigger_ExplorerButton_PrepareReplacement(Trigger, Event1, Event2)
{
	global
	if(Trigger.Name = Event2.Trigger.Name && Trigger.Tooltip = Event2.Trigger.Tooltip && Trigger.ShowSelected = Event2.Trigger.ShowSelected && Trigger.ShowNoSelected = Event2.Trigger.ShowNoSelected) ; Check if something changed
		return
	if(!IsPortable && Vista7 && A_IsAdmin)
		RemoveButton("IsExplorerButton", Event1)
}
IsExplorerButton(value, key, Event)
{
	if(!Event.Trigger.ShowSelected && InStr(key, "TasksItemsSelected"))
		return false
	else if(!Event.Trigger.ShowNoSelected && InStr(key, "TasksNoItemsSelected"))
		return false
	RegRead, command, HKLM, %key%
	RegexMatch(command,""" -id:(\d+)$", command)
	if(command1 && command1 = Event.ID)
		return true
	return false
}
Trigger_ExplorerButton_Matches(Trigger, Filter, Event)
{
	return false ; Match is handled through type trigger in Eventsystem.ahk already
}

Trigger_ExplorerButton_DisplayString(Trigger)
{
	return "Explorer Button " Trigger.Name
}

Trigger_ExplorerButton_GuiShow(Trigger, TriggerGUI)
{
	global
	if(Vista7)
	{
		SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Desc", "This button will show up in the explorer folder band bar at the top (Vista/7 only)")
		SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Name", Trigger.Name, "", "Button Name:")
		SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "ShowSelected", "Show when files are selected", "", "")
		SubEventGUI_Add(Trigger, TriggerGUI, "Button", "RemoveAllButtons", "Remove custom Explorer Buttons", "RemoveAllExplorerButtons", "")
	}
	else
		SubEventGUI_Add(Trigger, TriggerGUI, "Text", "tmpText", "This trigger is only supported in Windows 7 and Vista", "", "")		
}

Trigger_ExplorerButton_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger,TriggerGUI)
}  
RemoveAllExplorerButtons:
RemoveAllExplorerButtons()
return