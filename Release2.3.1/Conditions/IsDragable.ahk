Condition_IsDragable_Init(Condition)
{
	Condition.Category := "Window"
}
Condition_IsDragable_ReadXML(Condition, XMLCondition)
{
}
Condition_IsDragable_Evaluate(Condition)
{
	MouseGetPos,,,win
	WinGet,style,style,ahk_id %win%
	if(style & 0x80000000 && !(style & 0x00400000 || style & 0x00800000 || style & 0x00080000)) ;WS_POPUP && !WS_DLGFRAME && !WS_BORDER && !WS_SYSMENU
		return false
	WinGet, State, MinMax, ahk_id %win% 
	if(State != 0)
		return false
	class := WinGetClass("ahk_id " win)
	if(class = "Notepad++" || class = "SciTEWindow") ;Notepad++ and SciTE use Alt+LButton for rectangular text selection
		return false
	if(IsFullScreen())
		return false
	return true
}
Condition_IsDragable_DisplayString(Condition)
{
	return "Window under mouse is dragable/resizeable"
}

Condition_IsDragable_GuiShow(Condition, ConditionGUI)
{
}

Condition_IsDragable_GuiSubmit(Condition, ConditionGUI)
{
} 