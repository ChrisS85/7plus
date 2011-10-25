Class COnMessageTrigger Extends CTrigger
{
	static Type := RegisterType(COnMessageTrigger, "On window message")
	static Category := RegisterCategory(COnMessageTrigger, "System")
	static Message := ""
	Enable()
	{
		OnMessage(this.Message,"ShellMessage")
	}
	Disable()
	{
		;OnMessage(this.Message) ;Doing this is problematic because message might be needed internally
	}
	;When OnMessage is deleted, it needs to be removed from OnMessagearrays
	Delete()
	{
		;OnMessage(this.Message) ;Doing this is problematic because message might be needed internally
	}

	Matches(Filter, Event)
	{
		if(this.Message = Filter.Message || (this.Message = "Shellhook" && Filter.Message = ApplicationState.ShellHookMessage))
		{			
			Event.Placeholders.lParam := Filter.lParam
			Event.Placeholders.wParam := Filter.wParam
			return true
		}
		return false
	}

	DisplayString()
	{
		return "On Message " this.Message
	}

	GuiShow(GUI, GoToLabel = "")
	{
		this.AddControl(GUI, "Text", "Desc", "This trigger allows you to react to window messages from other programs. You can use it to trigger events in 7plus from other programs that support sending messages.")
		this.AddControl(GUI, "Text", "tmpMessageText", "Enter a message number here or ""ShellHook""")
		this.AddControl(GUI, "Edit", "Message", this.Message, "", "Message:")
		this.AddControl(GUI, "Text", "tmpText", "This trigger allows you to use wParam and lParam placeholders in conditions/actions")
	}
}