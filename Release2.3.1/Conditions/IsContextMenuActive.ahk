Condition_IsContextMenuActive_Init(Condition)
{
	Condition.Category := "Other"
}
Condition_IsContextMenuActive_ReadXML(Condition, XMLCondition)
{
}
Condition_IsContextMenuActive_Evaluate(Condition)
{
	x := IsContextMenuActive()
	return x
}
Condition_IsContextMenuActive_DisplayString(Condition)
{
	return "If Context menu is active"
}

Condition_IsContextMenuActive_GuiShow(Condition, ConditionGUI)
{
}

Condition_IsContextMenuActive_GuiSubmit(Condition, ConditionGUI)
{
} 