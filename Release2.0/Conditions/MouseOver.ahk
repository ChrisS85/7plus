Condition_MouseOver_Init(Condition)
{
	Condition.Category := "Mouse"
	Condition.MouseOverType := "Window"
	WindowFilter_Init(Condition)
}
Condition_MouseOver_ReadXML(Condition, ConditionFileHandle)
{
	Condition.MouseOverType := xpath(ConditionFileHandle, "/MouseOverType/Text()")
	if(Condition.MouseOverType = "Window")
	{
		WindowFilter_ReadXML(Condition, ConditionFileHandle)
	}
}
Condition_MouseOver_Evaluate(Condition)
{
	if(Condition.MouseOverType = "Window")
	{
		MouseGetPos,,,window
		return WindowFilter_Matches(Condition, window)
	}
	else
	{
		result := MouseHitTest()
		if(Condition.MouseOverType = "TitleBar")
			return result = 2
		else if(Condition.MouseOverType = "MinimizeButton")
			return result = 8
		else if(Condition.MouseOverType = "MaximizeButton")
			return result = 9
		else if(Condition.MouseOverType = "CloseButton")
			return result = 20
	}
}
Condition_MouseOver_DisplayString(Condition)
{
	string := "Mouse over: "
	if(Condition.MouseOverType = "Window")
		return string WindowFilter_DisplayString(Condition)
	else
		return string Condition.MouseOverType
}

Condition_MouseOver_GuiShow(Condition, ConditionGUI,GoToLabel="")
{
	static sConditionGUI, sCondition, PreviousSelection
	if(GoToLabel = "")
	{
		sConditionGUI := ConditionGUI
		sCondition := Condition
		PreviousSelection := ""
		SubEventGUI_Add(Condition, ConditionGUI, "DropDownList", "MouseOverType", "Window|Titlebar|MinimizeButton|MaximizeButton|CloseButton", "MouseOver_SelectionChange", "Mouse Over:")
		x := ConditionGUI.x
		y := ConditionGUI.y
		w := 200
		Condition_MouseOver_GuiShow("", "","MouseOver_SelectionChange")
	}
	else if(GoToLabel = "MouseOver_SelectionChange")
	{
		DropDown_MouseOverType := sConditionGUI.DropDown_MouseOverType
		ControlGetText, MouseOverType, , ahk_id %DropDown_MouseOverType%
		outputdebug selected %MouseOverType%
		if(MouseOverType = "Window")
		{
			if(MouseOverType != PreviousSelection)
			{
				WindowFilter_Init(sCondition)
				WindowFilter_GuiShow(sCondition, sConditionGUI)
			}
		}
		else
		{
			WindowFilter_GuiSubmit(sCondition, sConditionGUI)
			if(PreviousSelection = "Window")
				sConditionGUI.y := sConditionGUI.y - 60
		}
		PreviousSelection := MouseOverType
	}
}
MouseOver_SelectionChange:
Condition_MouseOver_GuiShow("", "","MouseOver_SelectionChange")
return

;Using WindowFilter_GUISubmit is not required, as it does the same basically
Condition_MouseOver_GuiSubmit(Condition, ConditionGUI)
{	
	SubEventGUI_GUISubmit(Condition, ConditionGUI)
} 