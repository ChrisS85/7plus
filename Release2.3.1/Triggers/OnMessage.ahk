Trigger_OnMessage_Init(Trigger)
{
	Trigger.Category := "System"
}
Trigger_OnMessage_ReadXML(Trigger, XMLTrigger)
{
	Trigger.Message := XMLTrigger.Message
}

Trigger_OnMessage_Enable(Trigger)
{
	OnMessage(Trigger.Message,"ShellMessage")
}
Trigger_OnMessage_Disable(Trigger)
{
	;OnMessage(Trigger.Message) ;Doing this is problematic because message might be needed internally
}
;When OnMessage is deleted, it needs to be removed from OnMessagearrays
Trigger_OnMessage_Delete(Trigger)
{
	;OnMessage(Trigger.Message) ;Doing this is problematic because message might be needed internally
}

Trigger_OnMessage_Matches(Trigger, Filter, Event)
{
	global ShellHookMsgNum
	if(Trigger.Message = Filter.Message || Trigger.Message = "Shellhook" && Filter.Message = ShellHookMsgNum)
	{			
		Event.Placeholders.lParam := Filter.lParam
		Event.Placeholders.wParam := Filter.wParam
		return true
	}
	return false
}

Trigger_OnMessage_DisplayString(Trigger)
{
	return "On Message " Trigger.Message
}

Trigger_OnMessage_GuiShow(Trigger, TriggerGUI, GoToLabel = "")
{
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Desc", "This trigger allows you to react to window messages from other programs. You can use it to trigger events in 7plus from other programs that support sending messages.")
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "tmpMessageText", "Enter a message number here or ShellHook")
	SubEventGUI_Add(Trigger, TriggerGUI, "Edit", "Message", Trigger.Message, "", "Message:")
	SubEventGUI_Add(Trigger, TriggerGUI, "Text", "tmpText", "This trigger allows you to use wParam and lParam placeholders in conditions/actions")
}

Trigger_OnMessage_GuiSubmit(Trigger, TriggerGUI)
{
	SubEventGUI_GuiSubmit(Trigger,TriggerGUI)
}  