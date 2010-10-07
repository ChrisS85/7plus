Trigger_ExplorerButton_Init(Trigger)
{
	Trigger.Category := "Explorer"
	Trigger.Name := "ExplorerButton"
	Trigger.Tooltip := "ExplorerButton"
	Trigger.ShowSelected := true
	Trigger.ShowNoSelected := true
	OnMessage(55555, "ExplorerButtonMessage")
}
ExplorerButtonMessage(wParam, lParam)
{
	Trigger := EventSystem_CreateSubEvent("Trigger", "ExplorerButton")
	Trigger.ID := wParam
	OnTrigger(Trigger)
}
Trigger_ExplorerButton_ReadXML(Trigger, XMLTrigger)
{
	Trigger.Name := XMLTrigger.Name
	Trigger.Tooltip := XMLTrigger.Tooltip
	Trigger.ShowSelected := XMLTrigger.ShowSelected
	Trigger.ShowNoSelected := XMLTrigger.ShowNoSelected
}

Trigger_ExplorerButton_Enable(Trigger, Event)
{
	global
	outputdebug enable
	if(!FindButton("IsExplorerButton", Event))
		AddButton("","",Event.ID, Trigger.Name, Trigger.Tooltip, (Trigger.ShowSelected && Trigger.ShowNoSelected ? "Both" : Trigger.ShowSelected ? "Selected" : Trigger.ShowNoSelected ? "NoSelected" : "")) ;Event.ID here
}
Trigger_ExplorerButton_Disable(Trigger, Event)
{
	global
	if(Event.Disabled)
		RemoveButton("IsExplorerButton", Event)
}
Trigger_ExplorerButton_Delete(Trigger, Event)
{
	global
	RemoveButton("IsExplorerButton", Event)
}
Trigger_ExplorerButton_PrepareReplacement(Trigger, Event1, Event2)
{
	global
	if(Trigger.Name = Event2.Trigger.Name && Trigger.Tooltip = Event2.Trigger.Tooltip && Trigger.ShowSelected = Event2.Trigger.ShowSelected && Trigger.ShowNoSelected = Event2.Trigger.ShowNoSelected) ; Check if something changed
		return
	RemoveButton("IsExplorerButton", Event1)
}
IsExplorerButton(value, key, Event)
{
	outputdebug value %value% key %key%
	if(!Event.Trigger.ShowSelected && InStr(key, "TasksItemsSelected"))
		return false
	else if(!Event.Trigger.ShowNoSelected && InStr(key, "TasksNoItemsSelected"))
		return false
	RegRead, command, HKLM, %key%
	outputdebug command %command%
	RegexMatch(command,""" -id (\d+)$", command)
	outputdebug % "command1: " command1 " id: " Event.ID
	if(command1 && command1 = Event.ID)
		return true
	return false
}
Trigger_ExplorerButton_Matches(Trigger, Filter, Event)
{
	if(Event.ID = Filter.ID)
		return true
	return false
}

Trigger_ExplorerButton_DisplayString(Trigger)
{
	return "Explorer Button " Trigger.Name
}

Trigger_ExplorerButton_GuiShow(Trigger, TriggerGUI)
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Name", Trigger.Name, "", "Button Name:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Tooltip", Trigger.Tooltip, "", "Tooltip:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "ShowSelected", "Show when files are selected", "", "")	
	SubEventGUI_Add(Trigger, TriggerGUI, "Checkbox", "ShowNoSelected", "Show when no files are selected", "", "")
}

Trigger_ExplorerButton_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger,TriggerGUI)
}  