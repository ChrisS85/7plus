Trigger_Hotkey_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
	SetTimer, RefreshHotkeyState, 200 ;Should be quick enough I suppose
}
HotkeyTrigger:
HotkeyTrigger(A_ThisHotkey)
return
HotkeyTrigger(key)
{
	Trigger := EventSystem_CreateSubEvent("Trigger", "Hotkey")	
	Trigger.Key := StringReplace(key,"$") ;Remove $ because it is not stored
	OnTrigger(Trigger)
}
RefreshHotkeyState:
RefreshHotkeyState()
return
RefreshHotkeyState()
{
	global HotkeyArrays, EventSchedule
	if(!isObject(HotkeyArrays)) ;First run
		RefreshHotkeyArrays()
	enum := HotkeyArrays._newEnum()
	while enum[key,array]
	{		
		AnyEnabled := false
		Loop % array.len()
		{
			Event := array[A_Index]
			enable := Event.Enabled ; Enabled state is checked here separately opposed to triggering
			ConditionPos := 1
			if(enable)
			{
				Loop % Event.Conditions.len()
				{
					Condition := Event.Conditions[ConditionPos]
					result := Condition.Evaluate()
					if(result = -1)
					{
						Msgbox % Condition.DisplayString() ": Hotkey Conditions must not block! This means that conditions which take a while to evaluate, such as conditions that query input from the user, must not be used. This condition is deleted."
						Event.Conditions.Delete(A_Index)
						continue
					}
					else if(Condition.Negate)
						result := 1 - result
					
					if(result = 0)
					{
						enable := false
						break
					}
					ConditionPos++
				}
			}
			;Don't swallow hotkey if event only allows one instance and it is already running
			if(enable)
			{
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
			}
			if(enable)
			{
				AnyEnabled := true
				break
			}
		}
		key := "$" key ;Add $ so key can not be triggered through script to prevent loops
		Hotkey, %key%, HotkeyTrigger, On ;Activate first so it exists
		if(!AnyEnabled)
			Hotkey, %key%, Off
	}
}
;This function updates the hotkey events stored separately for quicker state check
RefreshHotkeyArrays()
{
	global HotkeyArrays, Events
	HotkeyArrays := object()
	Loop % Events.len()
	{
		if(Events[A_Index].Trigger.Type = "Hotkey")
		{
			Event := Events[A_Index]
			if(!isObject(HotkeyArrays[Event.Trigger.Key]))
				HotkeyArrays[Event.Trigger.Key] := Array(Event)
			else
				HotkeyArrays[Event.Trigger.Key].append(Event)
		}
	}
}
Trigger_Hotkey_ReadXML(Trigger, TriggerFileHandle)
{
	Trigger.Key := xpath(TriggerFileHandle, "/Key/Text()")
}

Trigger_Hotkey_Enable(Trigger)
{
	key := Trigger.Key
	key := "$" key ;Add $ so key can not be triggered through script to prevent loops
	Hotkey, %key%, HotkeyTrigger, On
}
Trigger_Hotkey_Disable(Trigger)
{
	key := Trigger.Key
	key := "$" key ;Add $ so key can not be triggered through script to prevent loops
	Hotkey, %key%, Off
}
;When hotkey is deleted, it needs to be removed from hotkeyarrays
Trigger_Hotkey_Delete(Trigger)
{
	global HotkeyArrays
	array := HotkeyArrays[Trigger.key]
	Loop % array.len()
	{		
		if(array[A_Index].Trigger.Key = Trigger.Key)
		{
			array.Delete(A_Index)
			break
		}
	}
}

Trigger_Hotkey_Matches(Trigger, Filter)
{
	return Trigger.Key = Filter.Key
}

Trigger_Hotkey_DisplayString(Trigger)
{
	return "Hotkey " Trigger.Key
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