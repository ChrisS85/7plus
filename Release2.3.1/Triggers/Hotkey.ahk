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
	outputdebug, % "key: " A_ThisHotkey ", Event key: " Trigger.key
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
	return FormatHotkey(Trigger.Key)
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
	formatted := StringReplace(formatted, "LButton", "Left Mouse")
	formatted := StringReplace(formatted, "MButton", "Middle Mouse")
	formatted := StringReplace(formatted, "RButton", "Right Mouse")
	return formatted
}
Trigger_Hotkey_GuiShow(Trigger, TriggerGUI, GoToLabel = "")
{
	static sTriggerGUI
	if(GoToLabel = "")
	{
		sTriggerGUI := TriggerGUI
		CreateHotkeyGUI(Trigger, sTriggerGUI)
		;~ formatted := FormatHotkey(Trigger.Key)
		;~ SubEventGUI_Add(Trigger, TriggerGUI, "Text", "Hotkey", Trigger.Key (formatted = "" ? "" : " (" FormatHotkey(Trigger.Key) ")"), "", "Hotkey:")
		;~ SubEventGUI_Add(Trigger, TriggerGUI, "Button", "Edit", "Edit Hotkey", "EditHotkeyTrigger", "")
	}
	;~ else if(GoToLabel = "EditHotkey")
	;~ {
		;~ key:=HotKeyGui("",4, "Select Hotkey", 0,"","","","")
		;~ if(key)
		;~ {
			;~ Text_Hotkey := sTriggerGUI.Text_Hotkey
			;~ ControlSetText, , % Key " (" FormatHotkey(Key) ")", ahk_id %Text_Hotkey%
		;~ }
	;~ }
	else if(GoToLabel = "UpdateHotkey")
	{
		;Get values from GUI
		ControlGet, Key, Choice,,, % "ahk_id " sTriggerGUI.tmphKeyList
		ControlGet, CtrlModifier, Checked,,, % "ahk_id " sTriggerGUI.tmphCtrlModifier
		ControlGet, ShiftModifier, Checked,,, % "ahk_id " sTriggerGUI.tmphShiftModifier
		ControlGet, WinModifier, Checked,,, % "ahk_id " sTriggerGUI.tmphWinModifier
		ControlGet, AltModifier, Checked,,, % "ahk_id " sTriggerGUI.tmphAltModifier
		
		ControlGet, NativeOption, Checked,,, % "ahk_id " sTriggerGUI.tmphNativeOption
		ControlGet, WildcardOption, Checked,,, % "ahk_id " sTriggerGUI.tmphWildcardOption
		ControlGet, LeftPairOption, Checked,,, % "ahk_id " sTriggerGUI.tmphLeftPairOption
		ControlGet, RightPairOption, Checked,,, % "ahk_id " sTriggerGUI.tmphRightPairOption
		ControlGet, UpOption, Checked,,, % "ahk_id " sTriggerGUI.tmphUpOption
		;-- Substitute Pause|Break for CtrlBreak?
		if Key in Pause,Break
			if(CtrlModifier)
				Key := "CtrlBreak"


		;-- Substitute CtrlBreak for Pause (Break would work OK too)
		if(Key = "CtrlBreak")
			if(!CtrlModifier)
				Key := "Pause"

		;-- Initialize
		Hotkey := ""
		Desc := ""

		;-- Options
		if(NativeOption)
			Hotkey .= "~"

		if(WildcardOption)
			Hotkey .= "*"

		if(LeftPairOption)
			Hotkey .= "<"

		if(RightPairOption)
			Hotkey .= ">"
		
		;-- Modifiers
		if(CtrlModifier)
		{
			Hotkey .= "^"
			Desc .= "Ctrl + "
		}

		if(ShiftModifier)
		{
			Hotkey .= "+"
			Desc .= "Shift + "
		}

		if(WinModifier)
		{
			Hotkey .= "#"
			Desc .= "Win + "
		}

		if(AltModifier)
		{
			Hotkey .= "!"
			Desc .= "Alt + "
		}

		Hotkey .= Key
		Desc .= Key
		if(UpOption)
		{
			Hotkey .= " UP"
			Desc .= " UP"
		}
		ControlSetText,,%Desc%,% "ahk_id " sTriggerGUI.tmphHotkey
		sTriggerGUI.tmpHotkey := Hotkey
		return
	}
	else if(GoToLabel = "LeftPair")
	{
		ClassNN := HWNDToClassNN(sTriggerGUI.tmphRightPairOption)
		GuiControl,,%ClassNN%,0
		GoSub HotkeyGUI_UpdateHotkey
	}
	else if(GoToLabel = "RightPair")
	{
		ClassNN := HWNDToClassNN(sTriggerGUI.tmphLeftPairOption)
		GuiControl,,%ClassNN%,0
		GoSub HotkeyGUI_UpdateHotkey
	}
	else if(GoToLabel = "UpdateKeyList")
	{
		;Get values from GUI
		ControlGet, StandardKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphStandardKeysView
		ControlGet, FunctionKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphFunctionKeysView
		ControlGet, NumpadKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphNumpadKeysView
		ControlGet, MouseKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphMouseKeysView
		ControlGet, MultimediaKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphMultimediaKeysView
		ControlGet, SpecialKeysView, Checked,,, % "ahk_id " sTriggerGUI.tmphSpecialKeysView
		Gui, +DelimiterÉ
		;-- Standard
		if(StandardKeysView)
			KeyList := "AÉBÉCÉDÉEÉFÉGÉHÉIÉJÉKÉLÉMÉNÉOÉPÉQÉRÉSÉTÉUÉVÉWÉXÉYÉZÉ0É1É2É3É4É5É6É7É8É9É0É``É-É=É[É]É\É;É'É,É.É/ÉSpaceÉTabÉEnterÉEscapeÉBackspaceÉDeleteÉScrollLockÉCapsLockÉNumLockÉPrintScreenÉCtrlBreakÉPauseÉBreakÉInsertÉHomeÉEndÉPgUpÉPgDnÉUpÉDownÉLeftÉRightÉ"
				
		;-- Function keys
		if(FunctionKeysView)
			KeyList := "F1ÉF2ÉF3ÉF4ÉF5ÉF6ÉF7ÉF8ÉF9ÉF10ÉF11ÉF12ÉF13ÉF14ÉF15ÉF16ÉF17ÉF18ÉF19ÉF20ÉF21ÉF22ÉF23ÉF24É"
		
		;-- Numpad
		if(NumpadKeysView)
			KeyList := "NumLockÉNumpadDivÉNumpadMultÉNumpadAddÉNumpadSubÉNumpadEnterÉNumpadDelÉNumpadInsÉNumpadClearÉNumpadUpÉNumpadDownÉNumpadLeftÉNumpadRightÉNumpadHomeÉNumpadEndÉNumpadPgUpÉNumpadPgDnÉNumpad0ÉNumpad1ÉNumpad2ÉNumpad3ÉNumpad4ÉNumpad5ÉNumpad6ÉNumpad7ÉNumpad8ÉNumpad9ÉNumpadDotÉ"
		
		;-- Mouse
		if(MouseKeysView)
			KeyList := "LButtonÉRButtonÉMButtonÉWheelDownÉWheelUpÉXButton1ÉXButton2É"
		
		;-- Multimedia
		if(MultimediaKeysView)
			KeyList := "Browser_BackÉBrowser_ForwardÉBrowser_RefreshÉBrowser_StopÉBrowser_SearchÉBrowser_FavoritesÉBrowser_HomeÉVolume_MuteÉVolume_DownÉVolume_UpÉMedia_NextÉMedia_PrevÉMedia_StopÉMedia_Play_PauseÉLaunch_MailÉLaunch_MediaÉLaunch_App1ÉLaunch_App2É"
		
		;-- Special
		if(SpecialKeysView)
			KeyList := "HelpÉSleepÉ"
		Key := ExtractKey(sTriggerGUI.tmpHotkey)
		if(Key)
			KeyList := StringReplace(KeyList, "É" Key "É", "É" Key "ÉÉ")
		if(!InStr(KeyList, "ÉÉ"))
			KeyList := StringReplace(KeyList, "É", "ÉÉ")
		GUIControl ,,ListBox1,É%KeyList%
		Gui, +Delimiter|
		;--- Reset Hotkey and HKDesc
		gosub HotkeyGUI_UpdateHotkey
	}
}
HotkeyGUI_UpdateHotkey:
Trigger_Hotkey_GuiShow("","","UpdateHotkey")
return
HotkeyGUI_LeftPair:
Trigger_Hotkey_GuiShow("","","LeftPair")
return
HotkeyGUI_RightPair:
Trigger_Hotkey_GuiShow("","","RightPair")
return
HotkeyGUI_UpdateKeyList:
Trigger_Hotkey_GuiShow("","","UpdateKeyList")
return
ExtractKey(Hotkey)
{
	Key := StringReplace(Hotkey, "*", "")
	Key := StringReplace(Key, "~", "")
	Key := StringReplace(Key, "<", "")
	Key := StringReplace(Key, ">", "")
	Key := StringReplace(Key, " UP", "")
	Key := StringReplace(Key, "^", "")
	Key := StringReplace(Key, "+", "")
	Key := StringReplace(Key, "#", "")
	Key := StringReplace(Key, "!", "")
	return Key
}
CreateHotkeyGUI(Trigger, TriggerGUI)
{
	Critical, Off    
    ;-- Modifier
	x := TriggerGUI.x
	y := TriggerGUI.y
	CtrlModifier := InStr(Trigger.Key, "^") > 0
	ShiftModifier := InStr(Trigger.Key, "+") > 0
	WinModifier := InStr(Trigger.Key, "#") > 0
	AltModifier := InStr(Trigger.Key, "!") > 0
	LeftPairOption := InStr(Trigger.Key, "<") > 0
	RightPairOption := InStr(Trigger.Key, ">") > 0
	WildcardOption := InStr(Trigger.Key, "*") > 0
	NativeOption := InStr(Trigger.Key, "~") > 0
	UpOption := InStr(Trigger.Key, " UP") > 0 
	Key := ExtractKey(Trigger.Key)
	FunctionKeys := InStr("ÉF1ÉF2ÉF3ÉF4ÉF5ÉF6ÉF7ÉF8ÉF9ÉF10ÉF11ÉF12ÉF13ÉF14ÉF15ÉF16ÉF17ÉF18ÉF19ÉF20ÉF21ÉF22ÉF23ÉF24É", "É" Key "É") > 0
	NumpadKeys := InStr("ÉNumLockÉNumpadDivÉNumpadMultÉNumpadAddÉNumpadSubÉNumpadEnterÉNumpadDelÉNumpadInsÉNumpadClearÉNumpadUpÉNumpadDownÉNumpadLeftÉNumpadRightÉNumpadHomeÉNumpadEndÉNumpadPgUpÉNumpadPgDnÉNumpad0ÉNumpad1ÉNumpad2ÉNumpad3ÉNumpad4ÉNumpad5ÉNumpad6ÉNumpad7ÉNumpad8ÉNumpad9ÉNumpadDotÉ", "É" Key "É") > 0
	MouseKeys := InStr("ÉLButtonÉRButtonÉMButtonÉWheelDownÉWheelUpÉXButton1ÉXButton2É", "É" Key "É") > 0
	MultimediaKeys := InStr("ÉBrowser_BackÉBrowser_ForwardÉBrowser_RefreshÉBrowser_StopÉBrowser_SearchÉBrowser_FavoritesÉBrowser_HomeÉVolume_MuteÉVolume_DownÉVolume_UpÉMedia_NextÉMedia_PrevÉMedia_StopÉMedia_Play_PauseÉLaunch_MailÉLaunch_MediaÉLaunch_App1ÉLaunch_App2É", "É" Key "É") > 0
	SpecialKeys := InStr("ÉHelpÉSleepÉ", "É" Key "É") > 0
	StandardKeys := !FunctionKeys && !NumpadKeys && !MouseKeys && !MultimediaKeys && !SpecialKeys
    Gui, Add, GroupBox, x%x% y%y% w120 h140 hwndhModifier Section, Modifier
    TriggerGUI.tmphModifier := hModifier
	
    Gui, Add, CheckBox, xs+10 ys+20 h20 hwndhCtrlModifier gHotkeyGUI_UpdateHotkey Checked%CtrlModifier%, Ctrl
    TriggerGUI.tmphCtrlModifier := hCtrlModifier
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_UpdateHotkey hwndhShiftModifier Checked%ShiftModifier%, Shift
    TriggerGUI.tmphShiftModifier := hShiftModifier
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_UpdateHotkey hwndhWinModifier Checked%WinModifier%, Win
    TriggerGUI.tmphWinModifier := hWinModifier
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_UpdateHotkey hwndhAltModifier Checked%AltModifier%, Alt
    TriggerGUI.tmphAltModifier := hAltModifier    
    
	;-- Optional Attributes
    Gui, Add, GroupBox, xs+120 ys w140 h140 hwndhOptionalAttributes, Optional Attributes
    TriggerGUI.tmphOptionalAttributes := hOptionalAttributes
	
    Gui, Add, CheckBox, xs+130 ys+20 h20 gHotkeyGUI_UpdateHotkey hwndhNativeOption Checked%NativeOption%, ~ (Native)
    TriggerGUI.tmphNativeOption := hNativeOption
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_UpdateHotkey hwndhWildcardOption Checked%WildcardOption%, * (Wildcard)
    TriggerGUI.tmphWildcardOption := hWildcardOption
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_LeftPair hwndhLeftPairOption Checked%LeftPairOption%, < (Left pair only)
    TriggerGUI.tmphLeftPairOption := hLeftPairOption
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_RightPair hwndhRightPairOption Checked%RightPairOption%, > (Right pair only)
    TriggerGUI.tmphRightPairOption := hRightPairOption
	
    Gui, Add, CheckBox, y+0 h20 gHotkeyGUI_UpdateHotkey hwndhUpOption Checked%UpOption%, UP (Key release)
	TriggerGUI.tmphUpOption := hUpOption
	
    ;-- Keys
    Gui, Add, GroupBox, xs ys+140 w260 h180 hwndhKeys, Keys
    TriggerGUI.tmphKeys := hKeys
	
    Gui, Add, Radio, xs+10 ys+160 w100 h20 gHotkeyGUI_UpdateKeyList Checked%StandardKeys% hwndhStandardKeysView, Standard
    TriggerGUI.tmphStandardKeysView := hStandardKeysView
	
    Gui, Add, Radio, y+0 w100 h20 gHotkeyGUI_UpdateKeyList Checked%FunctionKeys% hwndhFunctionKeysView, Function keys
    TriggerGUI.tmphFunctionKeysView := hFunctionKeysView
	
    Gui, Add, Radio, y+0 w100 h20 gHotkeyGUI_UpdateKeyList Checked%NumpadKeys% hwndhNumpadKeysView, Numpad
    TriggerGUI.tmphNumpadKeysView := hNumpadKeysView
	
    Gui, Add, Radio, y+0 w100 h20 gHotkeyGUI_UpdateKeyList Checked%MouseKeys% hwndhMouseKeysView, Mouse
    TriggerGUI.tmphMouseKeysView := hMouseKeysView
	
    Gui, Add, Radio, y+0 w100 h20 gHotkeyGUI_UpdateKeyList Checked%MultimediaKeys% hwndhMultimediaKeysView, Multimedia
    TriggerGUI.tmphMultimediaKeysView := hMultimediaKeysView
	
    Gui, Add, Radio, y+0 w100 h20 gHotkeyGUI_UpdateKeyList Checked%SpecialKeys% hwndhSpecialKeysView, Special
    TriggerGUI.tmphSpecialKeysView := hSpecialKeysView
	
    Gui, Add, ListBox, xs+130 ys+160 w120 h150 gHotkeyGUI_UpdateHotkey hwndhKeyList
    TriggerGUI.tmphKeyList := hKeyList
	
    ;-- Hotkey Display
    Gui, Add, Text, xs ys+332 w40 h20 hwndhHotkeyLabel, Hotkey:
	TriggerGUI.tmphHotkeyLabel := hHotkeyLabel
	
    Gui, Add, Edit, x+5 ys+330 w215 h20 +ReadOnly hwndhHotkey
	TriggerGUI.tmphHotkey := hHotkey
	TriggerGUI.tmpHotkey := Trigger.Key
    gosub HotkeyGUI_UpdateKeyList
    
	return
}

Trigger_Hotkey_GuiSubmit(Trigger, TriggerGUI)
{
	;-- Any key?
	;~ ControlGetText, Hotkey, , % "ahk_id " TriggerGUI.tmphHotkey
    if(!TriggerGUI.tmpHotkey)
	{
        MsgBox 262160, Select Hotkey Error, A key must be selected.
		result := true
	}
    
	;[===================]
	;[  Collision Check  ]
	;[===================]
	if(CollisionCheck(TriggerGUI.tmpHotkey, 0, ""))
	{
		MsgBox 262160, Select Hotkey Error, This hotkey is already in use.
		result := true
	}
	Trigger.Key := TriggerGUI.tmpHotkey
	
	WinKill, % "ahk_id " TriggerGUI.tmphModifier
	WinKill, % "ahk_id " TriggerGUI.tmphCtrlModifier
	WinKill, % "ahk_id " TriggerGUI.tmphShiftModifier
	WinKill, % "ahk_id " TriggerGUI.tmphWinModifier
	WinKill, % "ahk_id " TriggerGUI.tmphAltModifier
	WinKill, % "ahk_id " TriggerGUI.tmphOptionalAttributes
	WinKill, % "ahk_id " TriggerGUI.tmphNativeOption
	WinKill, % "ahk_id " TriggerGUI.tmphWildcardOption
	WinKill, % "ahk_id " TriggerGUI.tmphLeftPairOption
	WinKill, % "ahk_id " TriggerGUI.tmphRightPairOption
	WinKill, % "ahk_id " TriggerGUI.tmphUpOption
	WinKill, % "ahk_id " TriggerGUI.tmphKeys
	WinKill, % "ahk_id " TriggerGUI.tmphStandardKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphFunctionKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphNumpadKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphMouseKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphMultimediaKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphSpecialKeysView
	WinKill, % "ahk_id " TriggerGUI.tmphKeyList
	WinKill, % "ahk_id " TriggerGUI.tmphHotkeyLabel
	WinKill, % "ahk_id " TriggerGUI.tmphHotkey
    ;-- Return to sender
    return result = true
	
	
	;~ Desc_Hotkey := TriggerGUI.Desc_Hotkey
	;~ Text_Hotkey := TriggerGUI.Text_Hotkey
	;~ Button_Edit := TriggerGUI.Button_Edit
	;~ ControlGetText, key, , ahk_id %Text_Hotkey%
	;~ Trigger.Key := SubStr(key,1,InStr(key, " (") - 1)
	;~ WinKill, ahk_id %Desc_Hotkey%
	;~ WinKill, ahk_id %Text_Hotkey%
	;~ WinKill, ahk_id %Button_Edit%
} 