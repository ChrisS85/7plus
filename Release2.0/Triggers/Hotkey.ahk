Trigger_Hotkey_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
	outputdebug(" enable " Trigger.key)
	Trigger.Enable() ; Hotkeys are enabled/disabled dynamically all the time, but they need to be initialized once at first
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
			enable := Event.Enabled
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
		if(AnyEnabled)
			Hotkey, %key%, HotkeyTrigger, On
		else
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
	Key := xpath(TriggerFileHandle, "/Key/Text()")
	StringReplace, Key, Key, &lt;,<
	StringReplace, Key, Key, &gt;,>
	Trigger.Key := Key
}

Trigger_Hotkey_WriteXML(Trigger, ByRef TriggerFileHandle, Path)
{	
	Key := Trigger.Key
	StringReplace, Key, Key, <,&lt;
	StringReplace, Key, Key, >,&gt;
	xpath(TriggerFileHandle, Path "Key[+1]/Text()", Key)
}

Trigger_Hotkey_Enable(Trigger)
{
	key := Trigger.Key
	key := "$" key ;Add $ so key can not be triggered through script to prevent loops
	Hotkey, %key%, HotkeyTrigger, On
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
		x := TriggerGui.x
		y := TriggerGui.y
		y += 4
		Gui, Add, Text, x%x% y%y% hwndhwndtext1, Hotkey:
		x += 50
		key := Trigger.Key
		Gui, Add, Text, x%x% y%y% w200 hwndhwndtext2, %key%
		x += 210
		y -= 4
		w := 100	
		Gui, Add, Button, x%x% y%y% w%w% hwndhwndButton gEditHotkeyTrigger, Edit Hotkey
		
		TriggerGUI.Text1 := hwndtext1
		TriggerGUI.Text2 := hwndtext2
		TriggerGUI.Button:= hwndButton
	}
	else if(GoToLabel = "EditHotkey")
	{
		key:=HotKeyGui("",4, "Select Hotkey", 0,"","","","")
		if(key)
		{
			hwndHotkey := sTriggerGUI.Text2
			ControlSetText, , %key%, ahk_id %hwndHotkey%
		}
	}
}
EditHotkeyTrigger:
Trigger_Hotkey_GuiShow("", "", "EditHotkey")
return

Trigger_Hotkey_GuiSubmit(Trigger, TriggerGUI)
{
	text1 := TriggerGUI.Text1
	text2 := TriggerGUI.Text2
	hwndButton := TriggerGUI.Button
	ControlGetText, key, , ahk_id %text2%
	Trigger.Key := key
	WinKill, ahk_id %text1%
	WinKill, ahk_id %text2%
	WinKill, ahk_id %hwndButton%
} 