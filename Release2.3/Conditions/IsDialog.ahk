Condition_IsDialog_Init(Condition)
{
	Condition.Category := "Other"
}
Condition_IsDialog_ReadXML(Condition, XMLCondition)
{
}
Condition_IsDialog_Evaluate(Condition)
{
	return IsDialog() > 0
}
Condition_IsDialog_DisplayString(Condition)
{
	return "If file dialog window is active"
}

Condition_IsDialog_GuiShow(Condition, ConditionGUI)
{
}

Condition_IsDialog_GuiSubmit(Condition, ConditionGUI)
{
} 