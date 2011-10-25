Class CDoubleClickDesktopTrigger Extends CTrigger
{
	static Type := RegisterType(CDoubleClickDesktopTrigger, "Double click on desktop")
	static Category := RegisterCategory(CDoubleClickDesktopTrigger, "Hotkeys")
	
	Matches(Filter)
	{
		return true ;type is checked elsewhere
	}
}