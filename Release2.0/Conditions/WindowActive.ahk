Condition_WindowActive_ReadXML(Condition, ConditionFileHandle)
{
	WindowFilter_ReadXML(Condition, ConditionFileHandle)
}
Condition_WindowActive_WriteXML(Condition, ByRef ConditionFileHandle, Path)
{
	WindowFilter_WriteXML(Condition, ConditionFileHandle, Path)
}
Condition_WindowActive_Evaluate(Condition)
{
	return WindowFilter_Matches(Condition, "A")
}
Condition_WindowActive_DisplayString(Condition)
{
	return "Window Active: " WindowFilter_DisplayString(Condition)
}