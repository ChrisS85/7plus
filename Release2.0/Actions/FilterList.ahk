Action_FilterList_Init(Action)
{
	Action.Category := "7plus"
	Action.Operator := "that end with"
	Action.List := "${SelNQ}"
	Action.Filter := ".exe"
	Action.Separator := "``n"
	Action.ExitOnEmptyList := 1
	Action.Action := "Keep list entries from"
}
Action_FilterList_ReadXML(Action, XMLAction)
{
	Action.Operator := XMLAction.Operator
	Action.List := XMLAction.List
	Action.Filter := XMLAction.Filter
	Action.Separator := XMLAction.Separator
	Action.ExitOnEmptyList := XMLAction.ExitOnEmptyList
	Action.Action := XMLAction.Action
}
Action_FilterList_Execute(Action,Event)
{
	key := SubStr(Action.List, InStr(Action.List, "${") + 2, InStr(Action.List, "}",InStr(Action.List, "${") + 2) - InStr(Action.List, "${") - 2)
	outputdebug key %key%
	List := Event.ExpandPlaceholders(Action.List)
	Filter := Event.ExpandPlaceholders(Action.Filter)
	Filter := StringReplace(Filter, "``n", "`n")
	Separator := Action.Separator
	array := ToArray(List, Separator, wasQuoted)
	outputdebug separator: "%separator%"
	newarray := Array()
	Loop % array.len()
	{
		result := (	Action.Operator = "that are equal to" && array[A_Index] = Filter
				|| 	Action.Operator = "that are greater than" && array[A_Index] > Filter
				|| 	Action.Operator = "that are lower than" && array[A_Index] > Filter
				|| 	Action.Operator = "that contain" && InStr(array[A_Index], Filter) > 0
				|| 	Action.Operator = "that match regular expression" && RegexMatch(array[A_Index], "i)" Filter) > 0
				|| 	Action.Operator = "that start with" && strStartsWith(array[A_Index], Filter)
				|| 	Action.Operator = "that end with" && strEndsWith(array[A_Index], Filter))
		if(	(Action.Action = "Keep list entries from" && result)
		||  (Action.Action = "Remove list entries from" && !result))
		
			newarray.append(array[A_Index])
		outputdebug % "Action: " Action.Operator " result: " result " len: " newarray.len()
	}
	
	if(Action.ExitOnEmptyList && newarray.len() = 0)
		return 0
	newlist := ArrayToList(newarray, Separator, wasQuoted)
	Event.Placeholders[key] := newlist
	return 1
}
Action_FilterList_DisplayString(Action)
{
	return Action.Action " " Action.List " " Action.Operator " " Action.Filter
}
Action_FilterList_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Text", "This action removes list entries from a placeholder")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Keep list entries from|Remove list entries from","","Action:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "List", "", "", "List:", "Placeholders","Action_FilterList_Placeholders_List")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Operator", "that are equal to|that are greater than|that are lower than|that contain|that match regular expression|that start with|that end with","","Operator:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Filter", "", "", "Filter:", "Placeholders","Action_FilterList_Placeholders_Filter")
		SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "List separator character. Not needed if list items are quoted. Use ``n for newline separator.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Separator", "", "", "Separator:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "ExitOnEmptyList", "Stop action if all list entries were removed")
	}
	else if(GoToLabel = "Placeholders_List")
		SubEventGUI_Placeholders(sActionGUI, "List")
	else if(GoToLabel = "Placeholders_Filter")
		SubEventGUI_Placeholders(sActionGUI, "Filter")
}

Action_FilterList_Placeholders_List:
Action_FilterList_GuiShow("", "","Placeholders_List")
return
Action_FilterList_Placeholders_Filter:
Action_FilterList_GuiShow("", "","Placeholders_Filter")
return

Action_FilterList_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}