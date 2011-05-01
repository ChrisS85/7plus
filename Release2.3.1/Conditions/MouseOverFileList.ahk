Condition_MouseOverFileList_Init(Condition)
{
	Condition.Category := "Mouse"
}
Condition_MouseOverFileList_ReadXML(Condition, XMLCondition)
{
}
Condition_MouseOverFileList_Evaluate(Condition)
{
	return IsMouseOverFileList()
}
Condition_MouseOverFileList_DisplayString(Condition)
{
	return "Mouse is over explorer/file dialog file list"
}

Condition_MouseOverFileList_GuiShow(Condition, ConditionGUI,GoToLabel="")
{
}
;Using WindowFilter_GUISubmit is not required, as it does the same basically
Condition_MouseOverFileList_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 