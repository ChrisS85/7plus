Action_Run_ReadXML(Action, ActionFileHandle)
{
	outputdebug read run
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