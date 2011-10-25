Class CRestart7plusAction Extends CAction
{
	static Type := RegisterType(CRestart7plusAction, "Restart 7plus")
	static Category := RegisterCategory(CRestart7plusAction, "7plus")
	Execute(Event)
	{
		OnExit(1)
		return 1
	} 
	DisplayString()
	{
		return "Restart 7plus"
	}
}   