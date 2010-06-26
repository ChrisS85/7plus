Trigger_Hotkey_Init(Trigger)
{
	Trigger.Category := "Hotkeys"
	SetTimer, RefreshHotkeyState, 1000
}
HotkeyTrigger:
HotkeyTrigger(A_ThisHotkey)
return
HotkeyTrigger(key)
{
	Trigger := EventSystem_CreateSubEvent("Trigger", "Hotkey")
	Trigger.Key := key
	OnTrigger(Trigger)
}
RefreshHotkeyState:
RefreshHotkeyState()
return
RefreshHotkeyState()
{
	global Events
	Loop % Events.len()
	{
		Event := Events[A_Index]
		if(Event.Trigger.Type != "Hotkey")
			continue
		key := Event.Trigger.Key
		enable := true
		ConditionPos := 1
		Loop % Event.Conditions.len()
		{
			Condition := Event.Conditions[ConditionPos]
			result := Condition.Evaluate()
			if(result = -1)
			{
				Msgbox % Condition.DisplayString() ": Hotkey Conditions must not block! This means that conditions which take a while to evaluate, such as conditions that query input from the user, must not be used. This condition is deleted."
				Event.Conditions.Delete(A_Index)
				ConditionPos--
			}
			else if(result = 0)
			{
				enable := false
				break
			}
			ConditionPos++
		}
		if(enable)
			Hotkey, %key%, HotkeyTrigger, On
		else
			Hotkey, %key%, Off
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
	Hotkey, %key%, HotkeyTrigger, On
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