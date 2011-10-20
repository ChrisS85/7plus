Class CHotkeyTrigger Extends CTrigger
{
	static Category := RegisterCategory(CHotkeyTrigger, "Hotkeys")
	static Type := RegisterType(CHotkeyTrigger, "Hotkey")
	static Key := ""

	Enable()
	{
		key := this.Key
		key := "$" key ;Add $ so key can not be triggered through script to prevent loops
		Hotkey, If, IsObject(HotkeyShouldFire(A_ThisHotkey))
		Hotkey, %key%, HotkeyTrigger, On
		Hotkey, If
	}
	Disable()
	{
		key := this.Key
		key := "$" key ;Add $ so key can not be triggered through script to prevent loops
		Hotkey, If, IsObject(HotkeyShouldFire(A_ThisHotkey))	
		Hotkey, %key%, HotkeyTrigger, On ;Do this to make sure it exists
		Hotkey, %key%, Off
		Hotkey, If
	}
	;When hotkey is deleted, it needs to be removed from hotkeyarrays
	Delete()
	{
	}

	Matches(Filter)
	{
		return (StringReplace(this.Key, "~") = StringReplace(Filter.Key, "~"))
	}

	DisplayString()
	{
		return FormatHotkey(this.Key)
	}
	GuiShow(TriggerGUI, GoToLabel = "")
	{
		static sTriggerGUI
		if(GoToLabel = "")
		{
			sTriggerGUI := TriggerGUI
			this.CreateHotkeyGUI(sTriggerGUI)
		}
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
			;Substitute Pause|Break for CtrlBreak?
			if Key in Pause,Break
				if(CtrlModifier)
					Key := "CtrlBreak"


			;Substitute CtrlBreak for Pause (Break would work OK too)
			if(Key = "CtrlBreak")
				if(!CtrlModifier)
					Key := "Pause"

			;Initialize
			Hotkey := ""
			Desc := ""

			;Options
			if(NativeOption)
				Hotkey .= "~"

			if(WildcardOption)
				Hotkey .= "*"

			if(LeftPairOption)
				Hotkey .= "<"

			if(RightPairOption)
				Hotkey .= ">"
			
			;Modifiers
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
			this.GuiShow("", "UpdateHotkey")
		}
		else if(GoToLabel = "RightPair")
		{
			ClassNN := HWNDToClassNN(sTriggerGUI.tmphLeftPairOption)
			GuiControl,,%ClassNN%,0
			this.GuiShow("", "UpdateHotkey")
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
			Gui, +Delimiterƒ
			;Standard
			if(StandardKeysView)
				KeyList := "AƒBƒCƒDƒEƒFƒGƒHƒIƒJƒKƒLƒMƒNƒOƒPƒQƒRƒSƒTƒUƒVƒWƒXƒYƒZƒ0ƒ1ƒ2ƒ3ƒ4ƒ5ƒ6ƒ7ƒ8ƒ9ƒ0ƒ``ƒ-ƒ=ƒ[ƒ]ƒ\ƒ;ƒ'ƒ,ƒ.ƒ/ƒSpaceƒTabƒEnterƒEscapeƒBackspaceƒDeleteƒScrollLockƒCapsLockƒPrintScreenƒCtrlBreakƒPauseƒBreakƒInsertƒHomeƒEndƒPgUpƒPgDnƒUpƒDownƒLeftƒRightƒ"
					
			;Function keys
			if(FunctionKeysView)
				KeyList := "F1ƒF2ƒF3ƒF4ƒF5ƒF6ƒF7ƒF8ƒF9ƒF10ƒF11ƒF12ƒF13ƒF14ƒF15ƒF16ƒF17ƒF18ƒF19ƒF20ƒF21ƒF22ƒF23ƒF24ƒ"
			
			;Numpad
			if(NumpadKeysView)
				KeyList := "NumLockƒNumpadDivƒNumpadMultƒNumpadAddƒNumpadSubƒNumpadEnterƒNumpadDelƒNumpadInsƒNumpadClearƒNumpadUpƒNumpadDownƒNumpadLeftƒNumpadRightƒNumpadHomeƒNumpadEndƒNumpadPgUpƒNumpadPgDnƒNumpad0ƒNumpad1ƒNumpad2ƒNumpad3ƒNumpad4ƒNumpad5ƒNumpad6ƒNumpad7ƒNumpad8ƒNumpad9ƒNumpadDotƒ"
			
			;Mouse
			if(MouseKeysView)
				KeyList := "LButtonƒRButtonƒMButtonƒWheelDownƒWheelUpƒXButton1ƒXButton2ƒ"
			
			;Multimedia
			if(MultimediaKeysView)
				KeyList := "Browser_BackƒBrowser_ForwardƒBrowser_RefreshƒBrowser_StopƒBrowser_SearchƒBrowser_FavoritesƒBrowser_HomeƒVolume_MuteƒVolume_DownƒVolume_UpƒMedia_NextƒMedia_PrevƒMedia_StopƒMedia_Play_PauseƒLaunch_MailƒLaunch_MediaƒLaunch_App1ƒLaunch_App2ƒ"
			
			;Special
			if(SpecialKeysView)
				KeyList := "HelpƒSleepƒ"
			Key := ExtractKey(sTriggerGUI.tmpHotkey)
			if(Key)
				KeyList := StringReplace(KeyList, "ƒ" Key "ƒ", "ƒ" Key "ƒƒ")
			if(!InStr(KeyList, "ƒƒ"))
				KeyList := StringReplace(KeyList, "ƒ", "ƒƒ")
			GUIControl ,,ListBox1,ƒ%KeyList%
			Gui, +Delimiter|
			;Reset Hotkey and HKDesc
			this.GuiShow("", "UpdateHotkey")
		}
	}
	CreateHotkeyGUI(TriggerGUI)
	{
		Critical, Off    
		;Modifier
		x := TriggerGUI.x
		y := TriggerGUI.y
		CtrlModifier := InStr(this.Key, "^") > 0
		ShiftModifier := InStr(this.Key, "+") > 0
		WinModifier := InStr(this.Key, "#") > 0
		AltModifier := InStr(this.Key, "!") > 0
		LeftPairOption := InStr(this.Key, "<") > 0
		RightPairOption := InStr(this.Key, ">") > 0
		WildcardOption := InStr(this.Key, "*") > 0
		NativeOption := InStr(this.Key, "~") > 0
		UpOption := InStr(this.Key, " UP") > 0 
		Key := ExtractKey(this.Key)
		FunctionKeys := InStr("ƒF1ƒF2ƒF3ƒF4ƒF5ƒF6ƒF7ƒF8ƒF9ƒF10ƒF11ƒF12ƒF13ƒF14ƒF15ƒF16ƒF17ƒF18ƒF19ƒF20ƒF21ƒF22ƒF23ƒF24ƒ", "ƒ" Key "ƒ") > 0
		NumpadKeys := InStr("ƒNumLockƒNumpadDivƒNumpadMultƒNumpadAddƒNumpadSubƒNumpadEnterƒNumpadDelƒNumpadInsƒNumpadClearƒNumpadUpƒNumpadDownƒNumpadLeftƒNumpadRightƒNumpadHomeƒNumpadEndƒNumpadPgUpƒNumpadPgDnƒNumpad0ƒNumpad1ƒNumpad2ƒNumpad3ƒNumpad4ƒNumpad5ƒNumpad6ƒNumpad7ƒNumpad8ƒNumpad9ƒNumpadDotƒ", "ƒ" Key "ƒ") > 0
		MouseKeys := InStr("ƒLButtonƒRButtonƒMButtonƒWheelDownƒWheelUpƒXButton1ƒXButton2ƒ", "ƒ" Key "ƒ") > 0
		MultimediaKeys := InStr("ƒBrowser_BackƒBrowser_ForwardƒBrowser_RefreshƒBrowser_StopƒBrowser_SearchƒBrowser_FavoritesƒBrowser_HomeƒVolume_MuteƒVolume_DownƒVolume_UpƒMedia_NextƒMedia_PrevƒMedia_StopƒMedia_Play_PauseƒLaunch_MailƒLaunch_MediaƒLaunch_App1ƒLaunch_App2ƒ", "ƒ" Key "ƒ") > 0
		SpecialKeys := InStr("ƒHelpƒSleepƒ", "ƒ" Key "ƒ") > 0
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
		
		;Optional Attributes
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
		
		;Keys
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
		
		;Hotkey Display
		Gui, Add, Text, xs ys+332 w40 h20 hwndhHotkeyLabel, Hotkey:
		TriggerGUI.tmphHotkeyLabel := hHotkeyLabel
		
		Gui, Add, Edit, x+5 ys+330 w215 h20 +ReadOnly hwndhHotkey
		TriggerGUI.tmphHotkey := hHotkey
		TriggerGUI.tmpHotkey := this.Key
		this.GuiShow("", "UpdateKeyList")
		
		return
	}

	GuiSubmit(TriggerGUI)
	{
		;Any key?
		if(!TriggerGUI.tmpHotkey)
		{
			MsgBox 262160, Select Hotkey Error, A key must be selected.
			Abort := true
		}
		
		;[===================]
		;[  Collision Check  ]
		;[===================]
		if(CollisionCheck(TriggerGUI.tmpHotkey, 0, ""))
		{
			MsgBox 262160, Select Hotkey Error, This hotkey is already in use.
			Abort := true
		}
		this.Key := TriggerGUI.tmpHotkey
		
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
		;Return to sender
		return Abort = true
	}
}
HotkeyGUI_UpdateHotkey:
GetCurrentSubEvent().GuiShow("", "UpdateHotkey")
return
HotkeyGUI_LeftPair:
GetCurrentSubEvent().GuiShow("","LeftPair")
return
HotkeyGUI_RightPair:
GetCurrentSubEvent().GuiShow("","RightPair")
return
HotkeyGUI_UpdateKeyList:
GetCurrentSubEvent().GuiShow("","UpdateKeyList")
return

#if IsObject(HotkeyShouldFire(A_ThisHotkey))
HotkeyTrigger:
HotkeyTrigger(A_ThisHotkey)
return
#if

HotkeyTrigger(key)
{
	outputdebug, % "Hotkey triggered, key: " A_ThisHotkey
	if(!key)
		return 0
	if(!IsObject(HotkeyShouldFire(A_ThisHotkey)))
		return 0
	Trigger := new CHotkeyTrigger()
	Trigger.Key := StringReplace(key,"$") ;Remove $ because it is not stored
	EventSystem.OnTrigger(Trigger)
}

HotkeyShouldFire(key)
{
	key := StringReplace(key,"$")
	key := StringReplace(key,"~")
	for index, Event in EventSystem.Events
	{
		if(Event.Trigger.Type != "Hotkey" || StringReplace(Event.Trigger.Key, "~") != key)
			continue
		
		if(!(enable := Event.CheckConditions(false)))
			continue
		
		;Don't swallow hotkey if event only allows one instance and it is already running
		if(Event.OneInstance)
			for index2, ScheduledEvent in EventSystem.EventSchedule
				if(ScheduledEvent.ID = Event.ID)
				{
					enable := false
					break
				}
		if(enable)
			return Event.Trigger
	}
	return 0
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