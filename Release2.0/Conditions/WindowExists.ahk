Condition_WindowExists_Init(Condition)
{
	Condition.Category := "Window"
	WindowFilter_Init(Condition)
}
Condition_WindowExists_ReadXML(Condition, ConditionFileHandle)
{
	WindowFilter_ReadXML(Condition, ConditionFileHandle)
}
Condition_WindowExists_Evaluate(Condition)
{
	if(Condition.WindowMatchType = "Program")
	{
		filter := Condition.Filter
		Process, Exist, %Filter%
		if(Errorlevel)
			return WinExist("ahk_pid " Errorlevel) != 0
		else
			return false
	}
	else if(Condition.WindowMatchType = "Class")
		return WinExist("ahk_class " Condition.Filter) != 0
	else if(Condition.WindowMatchType = "Title")
		return WinExist(Condition.Filter) != 0
	else if(Condition.WindowMatchType = "Active") ;Active window always exists
		return true
	else if(Condition.WindowMatchType = "UnderMouse") ;Window under mouse always exists
		return true
	return WindowFilter_Matches(Condition, "A")
}
Condition_WindowExists_DisplayString(Condition)
{
	return "Window Exists: " WindowFilter_DisplayString(Condition)
}

Condition_WindowExists_GuiShow(Condition, ConditionGUI)
{
	WindowFilter_GuiShow(Condition, ConditionGUI)
}

Condition_WindowExists_GuiSubmit(Condition, ConditionGUI)
{
	WindowFilter_GuiSubmit(Condition, ConditionGUI)
} 