Action_Run_ReadXML(Action, ActionFileHandle)
{
	Action.Command := xpath(ActionFileHandle, "/Command/Text()")
	Action.WaitForFinish := xpath(ActionFileHandle, "/WaitForFinish/Text()")
}
Action_Run_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Command[+1]/Text()", Action.Command)
	xpath(ActionFileHandle, Path "WaitForFinish[+1]/Text()", Action.WaitForFinish)
}
Action_Run_Execute(Action)
{
	if(Action.WaitForFinish)
		RunWait(Action.Command)
	else
		Run(Action.Command)
}
Action_Run_DisplayString(Action)
{
	return "Run " Action.Command
}

Action_Run_Init(Action)
{
	Action.Category := "System"
}

Action_Run_GuiShow(Action, ActionGUI)
{
	x := ActionGui.x
	y := ActionGui.y
	y += 4
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, Command:
	y += 30
	if(Action.WaitForFinish)
		Gui, Add, Checkbox, x%x% y%y% hwndhwndWaitForFinish Checked, Wait for finish
	else
		Gui, Add, Checkbox, x%x% y%y% hwndhwndWaitForFinish, Wait for finish
	
	x += 70
	y -= 34
	w := 200
	command := Action.Command
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndCommand, %command%
	
	ActionGUI.Text1 := hwndtext1
	ActionGUI.WaitForFinish := hwndWaitForFinish
	ActionGUI.Command := hwndCommand
}

Action_Run_GuiSubmit(Action, ActionGUI)
{
	text1 := ActionGUI.Text1
	hwndCommand := ActionGUI.Command
	hwndWaitForFinish := ActionGUI.WaitForFinish
	ControlGetText, Command, , ahk_id %hwndCommand%
	Action.Command := Command
	ControlGet, WaitForFinish, Checked, , ,ahk_id %hwndWaitForFinish%
	outputdebug hwnd %hwndWaitForFinish% waitforfinish %waitforfinish%
	Action.WaitForFinish := WaitForFinish
	WinKill, ahk_id %text1%
	WinKill, ahk_id %hwndCommand%
	WinKill, ahk_id %hwndWaitForFinish%
}