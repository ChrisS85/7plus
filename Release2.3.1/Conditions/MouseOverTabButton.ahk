Condition_MouseOverTabButton_Init(Condition)
{
	Condition.Category := "Mouse"
}
Condition_MouseOverTabButton_ReadXML(Condition, XMLCondition)
{
}
Condition_MouseOverTabButton_Evaluate(Condition)
{
	return IsMouseOverTabButton()
}
Condition_MouseOverTabButton_DisplayString(Condition)
{
	return "Mouse is over Explorer tab button"
}

Condition_MouseOverTabButton_GuiShow(Condition, ConditionGUI,GoToLabel="")
{
}
;Using WindowFilter_GUISubmit is not required, as it does the same basically
Condition_MouseOverTabButton_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 