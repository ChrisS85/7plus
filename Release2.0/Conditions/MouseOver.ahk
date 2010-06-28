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
Condition_MouseOver_WriteXML(Condition, ByRef ConditionFileHandle, Path)
{
	xpath(ConditionFileHandle, Path "MouseOverType[+1]/Text()", Condition.MouseOverType)
	if(Condition.MouseOverType = "Window")
		WindowFilter_WriteXML(Condition, ConditionFileHandle, Path)
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
	static sConditionGUI, sCondition, hwndMouseOverType
	if(GoToLabel = "")
	{
		sConditionGUI := ConditionGUI
		sCondition := Condition
		x := ConditionGUI.x
		y := ConditionGUI.y
		y += 4
		Gui, Add, Text, x%x% y%y% hwndhwndText1, Mouse over:
		x += 70
		y -= 4
		w := 200
		outputdebug("type " Condition.MouseOverType)
		if(Condition.MouseOverType = "Window")
		{
			Gui, Add, DropDownList, x%x% y%y% w%w% hwndhwndMouseOverType gMouseOver_SelectionChange, Window||Titlebar|MinimizeButton|MaximizeButton|CloseButton
			ConditionGUI.y := ConditionGUI.y + 30
			WindowFilter_GuiShow(sCondition, sConditionGUI)
		}
		else if(Condition.MouseOverType = "Titlebar")
			Gui, Add, DropDownList, x%x% y%y% w%w% hwndhwndMouseOverType gMouseOver_SelectionChange, Window|Titlebar||MinimizeButton|MaximizeButton|CloseButton
		else if(Condition.MouseOverType = "MinimizeButton")
			Gui, Add, DropDownList, x%x% y%y% w%w% hwndhwndMouseOverType gMouseOver_SelectionChange, Window|Titlebar|MinimizeButton||MaximizeButton|CloseButton
		else if(Condition.MouseOverType = "MaximizeButton")
			Gui, Add, DropDownList, x%x% y%y% w%w% hwndhwndMouseOverType gMouseOver_SelectionChange, Window|Titlebar|MinimizeButton|MaximizeButton||CloseButton
		else if(Condition.MouseOverType = "CloseButton")
			Gui, Add, DropDownList, x%x% y%y% w%w% hwndhwndMouseOverType gMouseOver_SelectionChange, Window|Titlebar||MinimizeButton|MaximizeButton|CloseButton||
		if(Condition.MouseOverType != "Window")
			ConditionGUI.y := ConditionGUI.y + 30
		ConditionGUI.MouseOverType := hwndMouseOverType
		ConditionGUI.Text1 := hwndText1
	}
	else if(GoToLabel = "MouseOver_SelectionChange")
	{
		hwndMouseOverType := sConditionGUI.MouseOverType
		ControlGetText, MouseOverType, , ahk_id %hwndMouseOverType%
		if(MouseOverType = "Window")
		{
			WindowFilter_Init(sCondition)
			WindowFilter_GuiShow(sCondition, sConditionGUI)
		}
		else
		{
			WindowFilter_GuiSubmit(sCondition, sConditionGUI)
		}
	}
}
MouseOver_SelectionChange:
Condition_MouseOver_GuiShow("", "","MouseOver_SelectionChange")
return

Condition_MouseOver_GuiSubmit(Condition, ConditionGUI)
{	
	hwndMouseOverType := ConditionGUI.MouseOverType
	ControlGetText, MouseOverType, , ahk_id %hwndMouseOverType%
	Condition.MouseOverType := MouseOverType
	if(MouseOverType := "Window")
	{
		WindowFilter_GuiSubmit(Condition, ConditionGUI)
	}
	Text1 := ConditionGUI.Text1
	WinKill, ahk_id %hwndMouseOverType%
	WinKill, ahk_id %Text1%
} 