 Condition_IsRenaming_Init(Condition)
{
	Condition.Category := "Explorer"
}
Condition_IsRenaming_ReadXML(Condition, XMLCondition)
{
}
Condition_IsRenaming_Evaluate(Condition)
{
	return IsRenaming()
}
Condition_IsRenaming_DisplayString(Condition)
{
	return "Explorer is renaming"
}

Condition_IsRenaming_GuiShow(Condition, ConditionGUI)
{
}

Condition_IsRenaming_GuiSubmit(Condition, ConditionGUI)
{
}