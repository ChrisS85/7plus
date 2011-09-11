 Condition_IsFullScreen_Init(Condition)
{
	Condition.Category := "Window"
	Condition.UseIncludeList := 1
	Condition.UseExcludeList := 1
}
Condition_IsFullScreen_ReadXML(Condition, XMLCondition)
{
	Condition.ReadVar(XMLCondition, "UseIncludeList")
	Condition.ReadVar(XMLCondition, "UseExcludeList")
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
	SubEventGUI_Add(Condition, ConditionGUI, "Text", "Desc", "This condition checks if a fullscreen window is active (such as a game or a movie).")
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "UseIncludeList", "Use include list","","","","","","","The include list is specified in Misc settings. All window classes on this list are always recognized as fullscreen.")
	SubEventGUI_Add(Condition, ConditionGUI, "Checkbox", "UseExcludeList", "Use exclude list","","","","","","","The exclude list is specified in Misc settings. All window classes on this list are never recognized as fullscreen.")
}

Condition_IsFullScreen_GuiSubmit(Condition, ConditionGUI)
{
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 