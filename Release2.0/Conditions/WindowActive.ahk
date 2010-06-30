Condition_WindowActive_Init(Condition)
{
	Condition.Category := "Window"
	WindowFilter_Init(Condition)
}
Condition_WindowActive_ReadXML(Condition, ConditionFileHandle)
{
	WindowFilter_ReadXML(Condition, ConditionFileHandle)
}
Condition_WindowActive_Evaluate(Condition)
{
	return WindowFilter_Matches(Condition, "A")
}
Condition_WindowActive_DisplayString(Condition)
{
	return "Window Active: " WindowFilter_DisplayString(Condition)
}

Condition_WindowActive_GuiShow(Condition, ConditionGUI)
{
	WindowFilter_GuiShow(Condition, ConditionGUI)
}

Condition_WindowActive_GuiSubmit(Condition, ConditionGUI)
{
	WindowFilter_GuiSubmit(Condition, ConditionGUI)
}