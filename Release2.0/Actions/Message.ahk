Action_Message_ReadXML(Action, ActionFileHandle)
{
	Action.Text := xpath(ActionFileHandle, "/Text/Text()")
	Action.Title := xpath(ActionFileHandle, "/Title/Text()")
	Action.Timeout := xpath(ActionFileHandle, "/Timeout/Text()")
}
Action_Message_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Text[+1]/Text()", Action.Text)
	xpath(ActionFileHandle, Path "Title[+1]/Text()", Action.Title)
	xpath(ActionFileHandle, Path "TimeOut[+1]/Text()", Action.Timeout)
}
Action_Message_Execute(Action)
{
	MsgBox2(Action.Title, Action.Text, Action.Timeout)
} 