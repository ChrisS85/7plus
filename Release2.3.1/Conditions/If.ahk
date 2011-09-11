 Condition_If_Init(Condition)
{
	Condition.Category := "Other"
	Condition.Operator := "equals"
	Condition.Compare := "${P}"
	Condition.With := ""
}
Condition_If_ReadXML(Condition, XMLCondition)
{
	Condition.ReadVar(XMLCondition, "Operator")
	Condition.ReadVar(XMLCondition, "Compare")
	Condition.ReadVar(XMLCondition, "With")
}
Condition_If_Evaluate(Condition, Event)
{
	Compare := Event.ExpandPlaceholders(Condition.Compare)
	With := Event.ExpandPlaceholders(Condition.With)
	if(Condition.Operator = "equals")
		return Compare = With
	else if(Condition.Operator = "is greater than")
		return Compare > With
	else if(Condition.Operator = "is lower than")
		return Compare < With
	else if(Condition.Operator = "contains")
		return InStr(Compare, With) > 0
	else if(Condition.Operator = "matches regular expression")
		return RegexMatch(Compare, With) > 0
	else if(Condition.Operator = "starts with")
		return strStartsWith(Compare, With)
	else if(Condition.Operator = "ends with")
		return strEndsWith(Compare, With)
}
Condition_If_DisplayString(Condition)
{
	return "If " Condition.Compare " " Condition.Operator " " Condition.With
}

Condition_If_GuiShow(Condition, ConditionGUI,GoToLabel="")
{
	static sConditionGUI
	if(GoToLabel = "")
	{
		sConditionGUI := ConditionGUI
		SubEventGUI_Add(Condition, ConditionGUI, "Text", "IfDesc", "This is a standard if condition that can evaluate all kinds of relations by comparing placeholders with values.")
		SubEventGUI_Add(Condition, ConditionGUI, "Edit", "Compare", "", "", "Compare:", "Placeholders", "Condition_If_Placeholders_Compare")
		SubEventGUI_Add(Condition, ConditionGUI, "DropDownList", "Operator", "equals|is greater than|is lower than|contains|matches regular expression|starts with|ends with", "", "Operator")
		SubEventGUI_Add(Condition, ConditionGUI, "Edit", "With", "", "", "With:", "Placeholders", "Condition_If_Placeholders_With")
	}
	else if(GoToLabel = "Placeholders_Compare")
		SubEventGUI_Placeholders(sConditionGUI, "Compare")
	else if(GoToLabel = "Placeholders_With")
		SubEventGUI_Placeholders(sConditionGUI, "With")
}
Condition_If_Placeholders_Compare:
Condition_If_GuiShow("", "","Placeholders_Compare")
return
Condition_If_Placeholders_With:
Condition_If_GuiShow("", "","Placeholders_With")
return

Condition_If_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 