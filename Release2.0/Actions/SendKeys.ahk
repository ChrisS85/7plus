Action_SendKeys_ReadXML(Action, ActionFileHandle)
{
	Action.Keys := xpath(ActionFileHandle, "/Keys/Text()")
}
Action_SendKeys_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Keys[+1]/Text()", Action.Keys)
}
Action_SendKeys_Execute(Action)
{
	keys := Action.Keys
	Send %keys%
} 
Action_SendKeys_DisplayString(Action)
{
	return "SendKeys " Action.Keys
}

Action_SendKeys_Init(Action)
{
	Action.Category := "Input"
}
Action_SendKeys_GuiShow(Action, ActionGUI)
{
	x := ActionGui.x
	y := ActionGui.y
	y += 4
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, Keys to send:
	x += 70
	w := 200
	keys := Action.Keys
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndKeys, %keys%
	
	ActionGUI.Text1 := hwndtext1
	ActionGUI.Keys := hwndKeys
}

Action_SendKeys_GuiSubmit(Action, ActionGUI)
{
	text1 := ActionGUI.Text1
	hwndKeys := ActionGUI.Keys
	ControlGetText, keys, , ahk_id %hwndKeys%
	Action.Keys := keys
	WinKill, ahk_id %text1%
	WinKill, ahk_id %hwndKeys%
}