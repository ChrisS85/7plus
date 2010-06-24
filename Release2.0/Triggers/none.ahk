Trigger_None_Init(Trigger)
{
	Trigger.Category := "Other"
}
Trigger_None_ReadXML(Trigger, TriggerFileHandle)
{	
}

Trigger_None_WriteXML(Trigger, ByRef TriggerFileHandle, Path)
{
}

Trigger_None_Enable(Trigger)
{
}

Trigger_None_Matches(Trigger, Filter)
{
	return false
}

Trigger_None_DisplayString(Trigger)
{
	return "None"
}

Trigger_None_GuiShow(WindowFilter, TriggerGUI)
{
	x := TriggerGui.x
	y := TriggerGui.y
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, This trigger type can only be triggered by a trigger action.
	TriggerGUI.Text1 := hwndtext1
}

Trigger_None_GuiSubmit(WindowFilter, TriggerGUI)
{
	text1 := TriggerGUI.Text1
	WinKill, ahk_id %text1%
}