;Generic Window Filter
WindowFilter_ReadXML(WindowFilterObject, WindowFilterFileHandle)
{
	WindowFilterObject.WindowMatchType := xpath(WindowFilterFileHandle, "/WindowMatchType/Text()")
	WindowFilterObject.Filter := xpath(WindowFilterFileHandle, "/Filter/Text()")
}

WindowFilter_WriteXML(WindowFilterObject, ByRef WindowFilterFileHandle, Path)
{
	xpath(WindowFilterFileHandle, Path "WindowMatchType[+1]/Text()", WindowFilterObject.WindowMatchType)
	xpath(WindowFilterFileHandle, Path "Filter[+1]/Text()", WindowFilterObject.Filter)
}
;Generic Window Filter match function. Filter is optional, it is used to check if the trigger is correct if used on a trigger window filter
WindowFilter_Matches(WindowFilter, TargetWindow, TriggerFilter = "")
{
	if(!TriggerFilter || WindowFilter.type = TriggerFilter.type)
	{
		if(TargetWindow = "A")
			TargetWindow := WinExist("A")
		else if(TargetWindow = "UnderMouse")
			MouseGetPos,,,TargetWindow
		if(WindowFilter.WindowMatchType = "Program")
		{
			if(GetProcessName(TargetWindow) = WindowFilter.Filter)
				return true
		}
		else if(WindowFilter.WindowMatchType = "Class")
		{
			if(WinGetClass("ahk_id " TargetWindow) = WindowFilter.Filter)
				return true
		}
		else if(WindowFilter.WindowMatchType = "Title")
		{
			if(strStartsWith(WinGetTitle("ahk_id " TargetWindow),WindowFilter.Filter))
				return true			
		}
	}
	return false
}