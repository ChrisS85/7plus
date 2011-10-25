Class CDoubleClickTaskbarTrigger Extends CTrigger
{
	static Type := RegisterType(CDoubleClickTaskbarTrigger, "Double click on taskbar")
	static Category := RegisterCategory(CDoubleClickTaskbarTrigger, "Hotkeys")
	Matches(Filter)
	{
		return true ;type is checked elsewhere
	}
	DisplayString()
	{
		return "Double click on empty taskbar area"
	}
}