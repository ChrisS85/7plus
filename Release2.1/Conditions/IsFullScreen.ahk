 Condition_IsFullScreen_Init(Condition)
{
	Condition.Category := "Window"
	Condition.UseIncludeList := 1
	Condition.UseExcludeList := 1
}
Condition_IsFullScreen_ReadXML(Condition, XMLCondition)
{
	Condition.UseIncludeList := XMLCondition.UseIncludeList
	Condition.UseExcludeList := XMLCondition.UseExcludeList
}
Condition_IsFullScreen_Evaluate(Condition)
{
	x:=IsFullScreen("A",Condition.UseExcludeList, Condition.UseIncludeList)
	outputdebug evaluate fullscreen %x%
	return x
}
Condition_IsFullScreen_DisplayString(Condition)
{
	return "In fullscreen"
}

Condition_IsFullScreen_GuiShow(Condition, ConditionGUI)
{
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "UseIncludeList", "Use include list")
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "UseExcludeList", "Use exclude list")
}

Condition_IsFullScreen_GuiSubmit(Condition, ConditionGUI)
{
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 