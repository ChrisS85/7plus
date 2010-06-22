Action_SendKeys_ReadXML(Action, ActionFileHandle)
{
	Action.Keys := xpath(ActionFileHandle, "/Keys/Text()")
}
Action_SendKeys_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Keys[+1]/Text()", Action.Keys)

Action_SendKeys_Execute(Action)
{
	keys := Action.Keys
	Send %keys%
} 