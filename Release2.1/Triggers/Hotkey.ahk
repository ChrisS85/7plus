Trigger_Hotkey_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
	;SetTimer, RefreshHotkeyState, 200 ;Should be quick enough I suppose
}
#if IsObject(Trigger := HotkeyShouldFire(A_ThisHotkey))
HotkeyTrigger:
HotkeyTrigger(A_ThisHotkey)
return
#if
HotkeyTrigger(key)
{
	global Events
	;outputdebug, % "key: " A_ThisHotkey ", Event key: " Trigger.key
	if(!key)
		return 0
	if(!IsObject(Trigger := HotkeyShouldFire(A_ThisHotkey)))
		return 0
	;outputdebug trigger %key%
	Trigger := EventSystem_CreateSubEvent("Trigger", "Hotkey")	
	Trigger.Key := StringReplace(key,"$") ;Remove $ because it is not stored
	OnTrigger(Trigger)
}
HotkeyShouldFire(key)
{
	global Events, EventSchedule
	;outputdebug HotkeyShouldFire(%key%)
	key := StringReplace(key,"$")
	key := StringReplace(key,"~")
	len := Events.len()
	Loop % len
	{
		Event := Events[A_Index]
		if(!enable := Event.Enabled)
			continue
		
		;outputdebug, % Event.Trigger.Type ", " key ", " StringReplace(Event.Trigger.key, "~")
		if(Event.Trigger.Type != "Hotkey" || StringReplace(Event.Trigger.Key, "~") != key)
			continue
		ConditionPos := 1
		count := Event.Conditions.len()
		Loop % count
		{
			Condition := Event.Conditions[ConditionPos]
			enable := Condition.Evaluate(Event)
			if(enable = -1)
			{
				Msgbox % Condition.DisplayString() ": Hotkey Conditions must not block! This means that conditions which take a while to evaluate, such as conditions that query input from the user, must not be used. This condition is deleted."
				Event.Conditions.Delete(A_Index)
				enable := false
				break
			}
			else if(Condition.Negate)
				enable := 1 - enable
			
			if(enable = 0)
				break
			ConditionPos++
		}
		if(!enable)
			continue
		;Don't swallow hotkey if event only allows one instance and it is already running
		if(Event.OneInstance)
		{
			Loop % EventSchedule.len()
			{
				if(EventSchedule[A_Index].ID = Event.ID)
				{
					enable := false
					break
				}
			}
		}
		if(enable)
		{
			;outputdebug should trigger
			return Event.Trigger
		}
	}
	; outputdebug should not
	return 0
}
Trigger_Hotkey_ReadXML(Trigger, XMLTrigger)
{
	Trigger.Key := XMLTrigger.Key
}

Trigger_Hotkey_Enable(Trigger)
{
	key := Trigger.Key
	key := "$" key ;Add $ so key can not be triggered through script to prevent loops
	Hotkey, If, IsObject(Trigger := HotkeyShouldFire(A_ThisHotkey))
	Hotkey, %key%, HotkeyTrigger, On
	Hotkey, If
}
Trigger_Hotkey_Disable(Trigger)
{
	key := Trigger.Key
	key := "$" key ;Add $ so key can not be triggered through script to prevent loops
	Hotkey, If, IsObject(Trigger := HotkeyShouldFire(A_ThisHotkey))	
	Hotkey, %key%, HotkeyTrigger, On ;Do this to make sure it exists
	Hotkey, %key%, Off
	Hotkey, If
}
;When hotkey is deleted, it needs to be removed from hotkeyarrays
Trigger_Hotkey_Delete(Trigger)
{
}

Trigger_Hotkey_Matches(Trigger, Filter)
{
	return (StringReplace(Trigger.Key, "~") = StringReplace(Filter.Key, "~"))
}

Trigger_Hotkey_DisplayString(Trigger)
{
	return "Key " FormatHotkey(Trigger.Key)
}

FormatHotkey(key)
{
	formatted .= InStr(key, "*") > 0 ? "Any Modifier key + " : ""
	formatted .= InStr(key, "#") > 0 ? "WIN + " : ""
	formatted .= InStr(key, "^") > 0 ? "CONTROL + " : ""
	formatted .= InStr(key, "!") > 0 ? "ALT + " : ""
	formatted .= InStr(key, "+") > 0 ? "SHIFT + " : ""
	formatted .= RegExReplace(key, "[\*\+\^#><!~]*")
	formatted .= InStr(key, "<") > 0 ? ", left modifier keys only" :""
	formatted .= InStr(key, ">") > 0 ? ", right modifier keys only" :""
	return formatted
}
Trigger_Hotkey_GuiShow(Trigger, TriggerGUI, GoToLabel = "")
{
	static sTriggerGUI
	if(GoToLabel = "")
	{
		sTriggerGUI := TriggerGUI
		SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Hotkey", Trigger.Key, "", "Hotkey:")
		SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Edit", "Edit Hotkey", "EditHotkeyTrigger", "")
	}
	else if(GoToLabel = "EditHotkey")
	{
		key:=HotKeyGui("",4, "Select Hotkey", 0,"","","","")
		if(key)
		{
			Text_Hotkey := sTriggerGUI.Text_Hotkey
			ControlSetText, , %key%, ahk_id %Text_Hotkey%
		}
	}
}
EditHotkeyTrigger:
Trigger_Hotkey_GuiShow("", "", "EditHotkey")
return

Trigger_Hotkey_GuiSubmit(Trigger, TriggerGUI)
{
	Desc_Hotkey := TriggerGUI.Desc_Hotkey
	Text_Hotkey := TriggerGUI.Text_Hotkey
	Button_Edit := TriggerGUI.Button_Edit
	ControlGetText, key, , ahk_id %Text_Hotkey%
	Trigger.Key := key
	WinKill, ahk_id %Desc_Hotkey%
	WinKill, ahk_id %Text_Hotkey%
	WinKill, ahk_id %Button_Edit%
} 