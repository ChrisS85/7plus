Condition_MouseOverTaskList_Init(Condition)
{
	Condition.Category := "Mouse"
}
Condition_MouseOverTaskList_ReadXML(Condition, XMLCondition)
{
}
Condition_MouseOverTaskList_Evaluate(Condition)
{
	return IsMouseOverTaskList()
}
Condition_MouseOverTaskList_DisplayString(Condition)
{
	return "Mouse is over task list"
}

Condition_MouseOverTaskList_GuiShow(Condition, ConditionGUI,GoToLabel="")
{
}
;Using WindowFilter_GUISubmit is not required, as it does the same basically
Condition_MouseOverTaskList_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 