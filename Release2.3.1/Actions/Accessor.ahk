Class CAccessorAction Extends CAction
{
	static Type := RegisterType(CAccessorAction, "Show Accessor")
	static Category := RegisterCategory(CAccessorAction, "Window")
	static FlashingWindows := 1
	static InitialQuery := ""
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
		result := CAccessor.Instance.Show(this, Event.ExpandPlaceholders(this.InitialQuery))
		return true
	}

	DisplayString()
	{
		return "Show accessor"
	}

	GuiShow(ActionGUI, GoToLabel = "")
	{
		static sActionGUI
		if(!GoToLabel)
		{
			sActionGUI := ActionGUI
			this.AddControl(ActionGUI, "Checkbox", "FlashingWindows", "Activate flashing windows first")
			this.AddControl(ActionGUI, "Edit", "InitialQuery", "", "", "Initial Query:", "Placeholders", "Action_InitialQuery_Placeholders", "", "", "The text of the query text field when Accessor is opened")
		}
		else if(GoToLabel = "InitialQuery_Placeholders")
			ShowPlaceholderMenu(sActionGUI, "InitialQuery")
	}
}

Action_InitialQuery_Placeholders:
GetCurrentSubEvent().GuiShow("", "InitialQuery_Placeholders")
return