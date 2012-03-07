Class CAccessorAction Extends CAction
{
	static Type := RegisterType(CAccessorAction, "Show Accessor")
	static Category := RegisterCategory(CAccessorAction, "Window")
	static FlashingWindows := 1
	
	__New()
	{
	}
	Execute(Event)
	{
		if(this.FlashingWindows)
		{
			result:=FlashingWindows(this) ;Since FlashingWindows function also uses an object value called FlashingWindows, it can straightly use this action here
			if(result)
				return 1
		}
		result := CAccessor.Instance.Show(this)
		return true
	}

	DisplayString()
	{
		return "Show accessor"
	}

	GuiShow(ActionGUI, GoToLabel = "")
	{
		this.AddControl(ActionGUI, "Checkbox", "FlashingWindows", "Activate flashing windows first")
	}
}
