  Condition_KeyIsDown_Init(Condition)
{
	Condition.Category := "Other"
	Condition.Physical := 1
	Condition.Toggle := 0
	Condition.Key := ""
}
Condition_KeyIsDown_ReadXML(Condition, XMLCondition)
{
	Condition.ReadVar(XMLCondition, "Key")
	Condition.ReadVar(XMLCondition, "Physical")
	Condition.ReadVar(XMLCondition, "Toggle")
}
Condition_KeyIsDown_Evaluate(Condition, Event)
{
	return GetKeyState(Condition.Key, (Condition.Toggle ? "T" : (Condition.Physical ? "P" : "")))
}
Condition_KeyIsDown_DisplayString(Condition)
{
	return Condition.Key " is " (Condition.Toggle ? "on" : "down")
}

Condition_KeyIsDown_GuiShow(Condition, ConditionGUI)
{
	SubEventGUI_Add(Condition, ConditionGUI, "Edit", "Key", "", "", "Key:", "Key names", "Condition_KeyIsDown_KeyNames")
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "Physical", "Use physical keystate")
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "Toggle", "Use toggle state (capslock,numlock, etc only)")
}
Condition_KeyIsDown_KeyNames:
run http://www.autohotkey.com/docs/KeyList.htm,,UseErrorLevel
return

Condition_KeyIsDown_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 