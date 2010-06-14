ReadHotkeys()
{
	global CustomHotkeys
	CustomHotkeys := Array()
	IniRead, hotkeys, %A_ScriptDir%\Settings.ini, CustomHotkeys, CustomHotkeys, %A_Space%
	Loop, Parse, hotkeys ,|, %A_Space%
	{
		if(!key)
			key := A_LoopField
		else if(key && !command)
		{
			command := A_LoopField
		}
		else
		{
			AddHotkey(key,command,A_LoopField)
			key := ""
			command := ""
		}
	}
}
AddHotkey(key,command,filter="")
{	
	global CustomHotkeys
	outputdebug addhotkey(%key%,%command%,%filter%)
	CustomHotkeys.Append(Object("key",key,"command",command,"filter",filter))
	;if(filter)
	;	Hotkey, If, GetActiveProcessName()="%filter%"
	Hotkey, %key%, CustomHotkey, On
	;if(filter)
	;	Hotkey, If,
	ct := CustomHotkeys.len()
	outputdebug new length: %ct%
}
#p::PrintHotkeys()

PrintHotkeys()
{
	global CustomHotkeys, Settings_CustomHotkeys
	len:=CustomHotkeys.len()
	outputdebug hotkey count: %len%
	Loop % CustomHotkeys.len()
		PrintHotkey(CustomHotkeys[A_Index])
	len:=Settings_CustomHotkeys.len()
	outputdebug settings hotkey count: %len%
	Loop % Settings_CustomHotkeys.len()
		PrintHotkey(Settings_CustomHotkeys[A_Index])
	return
}
PrintHotkey(hotkey)
{
	key:=hotkey.key
	command:=hotkey.command
	filter:=hotkey.filter
	outputdebug key %key% command %command% filter %filter%
}
RemoveHotkey(key,filter="")
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if((!filter && CustomHotkeys[A_Index].key = key)||(CustomHotkeys[A_Index].key = key && CustomHotkeys[A_Index].filter = filter))
		{
			CustomHotkeys.Delete(A_Index)
			;if(filter)
			;	Hotkey, If, GetActiveProcessName()="%filter%"
			Hotkey, %key%, Off
			;if(filter)
			;	Hotkey, If,
			break
		}
	}
}

RemoveAllHotkeys()
{
	global CustomHotkeys
	count:=CustomHotkeys.len()
	outputdeBug remove %count% hotkeys
	Loop % CustomHotkeys.len()
	{
		key := CustomHotkeys[A_Index].key
		filter := CustomHotkeys[A_Index].filter
		outputdeBug remove %key% %filter%
		;if(filter)
		;	Hotkey, If, GetActiveProcessName()="%filter%"
		Hotkey, %key%, Off
		;if(filter)
		;	Hotkey, If,
	}
	CustomHotkeys := Array()	
}
SaveHotkeys()
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if(A_Index=1)
			HotkeyString := CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command "|" CustomHotkeys[A_Index].filter
		else
			HotkeyString .= "|" CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command "|" CustomHotkeys[A_Index].filter
	}
	IniWrite, %HotkeyString%, %A_ScriptDir%\Settings.ini, CustomHotkeys, CustomHotkeys
}
CollisionCheck(key1,filter1,exclude)
{
	global CustomHotkeys
	7PlusHotkeys := "#h,#y,#v,#e,*!c,+c,+x,^i,+Enter,^t,^Tab,^+Tab,^w,^Numpad0,^Numpad1,^Numpad2,^Numpad3,^Numpad4,^Numpad5,^Numpad6,^Numpad7,^Numpad8,^Numpad9,!Numpad0,!Numpad1,!Numpad2,!Numpad3,!Numpad4,!Numpad5,!Numpad6,!Numpad7,!Numpad8,!Numpad9,^u,!Insert,#Insert,#Delete,#c,#+Left,#+Up,#+Right,#+Down,!WheelDown,!WheelUp,^v,!F4,!F5,!LButton"
	if(key1 = exclude) 
		return false
	key1_Win := InStr(key1, "#") > 0
	key1_Alt := InStr(key1, "!") > 0
	key1_Control := InStr(key1, "^") > 0
	key1_Shift := InStr(key1, "+") > 0
	key1_Left := InStr(key1, "<") > 0 || !InStr(key1, ">")
	key1_Right := InStr(key1, ">") > 0 || !InStr(key1, "<")
	key1_WildCard := InStr(key1, "*") > 0
	key1_stripped := RegExReplace(key1, "[\*\+\^#><!~]*")
	Loop, parse, 7PlusHotkeys, `,,%A_Space%
	{
		key2 := A_LoopField
		key2_Win := InStr(key2, "#") > 0
		key2_Alt := InStr(key2, "!") > 0
		key2_Control := InStr(key2, "^") > 0
		key2_Shift := InStr(key2, "+") > 0
		key2_Left := InStr(key2, "<") > 0 || !InStr(key2, ">")
		key2_Right := InStr(key2, ">") > 0 || !InStr(key2, "<")
		key2_WildCard := InStr(key2, "*") > 0
		key2_stripped := RegExReplace(key2, "[\*\+\^#><!~]*")
		DirCollision:=((key1_Left = true && key1_Left = key2_Left)||(key1_Right = true && key1_Right = key2_Right))
		KeyCollision:=(key1_stripped = key2_stripped)
		StateCollision:=((key1_Win = key2_Win && key1_Alt = key2_Alt && key1_Control = key2_Control && key1_Shift = key2_Shift) || key1_WildCard || key2_WildCard)
		if(KeyCollision && StateCollision && DirCollision)
			return true
	}
    Loop % CustomHotkeys.len()
	{
		key2 := CustomHotkeys[A_Index].key
		filter2 := CustomHotkeys[A_Index].key
		key2_Win := InStr(key2, "#") > 0
		key2_Alt := InStr(key2, "!") > 0
		key2_Control := InStr(key2, "^") > 0
		key2_Shift := InStr(key2, "+") > 0
		key2_Left := InStr(key2, "<") > 0 || !InStr(key2, ">")
		key2_Right := InStr(key2, ">") > 0 || !InStr(key2, "<")
		key2_WildCard := InStr(key2, "*") > 0
		key2_stripped := RegExReplace(key2, "[\*\+\^#><!~]*")
		DirCollision:=((key1_Left = true && key1_Left = key2_Left)||(key1_Right = true && key1_Right = key2_Right))
		KeyCollision:=(key1_stripped = key2_stripped)
		StateCollision:=((key1_Win = key2_Win && key1_Alt = key2_Alt && key1_Control = key2_Control && key1_Shift = key2_Shift) || key1_WildCard || key2_WildCard)
		if(KeyCollision && StateCollision && DirCollision && filter1 = filter2)
			return true
	}
	return false
}

;Monitors the active process name and (de)activates context-sensitive hotkeys
ToggleHotkeys:
ListLines, Off
ToggleHotkeys()
ListLines, On
return

ToggleHotkeys()
{
	global CustomHotkeys
	ProcessName := GetActiveProcessName()
	Loop % CustomHotkeys.len()
	{
		key := CustomHotkeys[A_Index].key
		if(CustomHotkeys[A_Index].filter != "" && CustomHotkeys[A_Index].filter = ProcessName && !(CustomHotkeys[A_Index].filter = "explorer.exe" && !WinActive("ahk_group ExplorerGroup")))
			Hotkey, %key%, CustomHotkey, On
		Else if(CustomHotkeys[A_Index].filter != "")
		{
			i := A_Index
			found := false
			Loop % CustomHotkeys.len()
			{
				if(CustomHotkeys[A_Index].key = CustomHotkeys[i].key && CustomHotkeys[A_Index].filter = "")
				{
					found:=true
					break
				}
			}
			if(!found)
				Hotkey, %key%, Off
		}
	}
}

;Label called on all custom hotkeys
CustomHotkey:
CustomHotkey()
return

CustomHotkey()
{
	global CustomHotkeys
	outputdebug hotkey label triggered
	/*
	Shift := GetKeyState("Shift", "P")
	Alt := GetKeyState("Alt", "P")
	Control := GetKeyState("Control", "P")
	Win := GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
	*/
	name := GetActiveProcessName()
	;handled := false
	Loop % CustomHotkeys.len()
	{
		if(A_ThisHotkey = CustomHotkeys[A_Index].key && CustomHotkeys[A_Index].filter != "" && name = CustomHotkeys[A_Index].filter)
		{
			Hotkey := CustomHotkeys[A_Index]
			break
		}
		else if(A_ThisHotkey = CustomHotkeys[A_Index].key && CustomHotkeys[A_Index].filter = "")
			Hotkey := CustomHotkeys[A_Index]
	}
	if(Hotkey)
	{
		outputdebug found hotkey
		command := Hotkey.command
		if(command && (Hotkey.filter="" || Hotkey.filter = name))
		{
			if(InStr(command,"${")) ;Handle placeholders
			{
				;Try to match files in window titles
				RegExMatch(WinGetTitle("A"),"([a-zA-Z]:\\[^/:\*\?<>\|]+\.\w{2,6})|(\\\\[^/:\*\?<>\|]+\.\w{2,6})",titlepath)
				StringReplace, command, command, ${T}, "%titlepath%"
				
				If(WinActive("ahk_group ExplorerGroup")) ;Supported placeholders: ${P} - Current Path, ${\d+} - selectedfile[i], ${N} - All selected files separated by spaces
				{
					StringReplace, command, command, ${P}, "%ExplorerPath%"
					files:=GetSelectedFiles()
					Loop, Parse, files, `n, %A_Space%
					{
						StringReplace, command, command, ${%A_Index%}, "%A_LoopField%"
					}
					command := RegExReplace(command, "\$\{\d+}")
					files2 := ""
					Loop, Parse, files, `n
						files2 .= """" A_LoopField """ "
					files2 := strTrimRight(files2," ")
					
					StringReplace, command, command, ${N}, %files2%
				}
				Else ;Remove all invalid placeholders
					command := RegExReplace(command, "\$\{.*}")
			}
			outputdebug run %command%
			run %command%
			;handled := true
		}
	}
	/*
	if(!handled)
	{
		outputdebug %A_ThisHotkey% was not handled, resend it
		if(InStr(A_ThisHotkey, "+") || (InStr(A_ThisHotkey, "*") && Shift))
		{
			outputdebug shift down
			Send {Blind}{Shift down}
			SetTimer, WaitForShiftUp, 50
		}
		if(InStr(A_ThisHotkey, "!") || (InStr(A_ThisHotkey, "*") && Alt))
		{
			outputdebug alt down
			Send {Blind}{Alt down}
			SetTimer, WaitForAltUp, 50
		}
		if(InStr(A_ThisHotkey, "^") || (InStr(A_ThisHotkey, "*") && Control))
		{
			outputdebug control down
			Send {Blind}{Control down}
			SetTimer, WaitForControlUp, 50
		}
		if(InStr(A_ThisHotkey, "#") || (InStr(A_ThisHotkey, "*") && Win))
		{
			outputdebug lwin down
			Send {Blind}{LWin down}
			SetTimer, WaitForWinUp, 50
		}
		StringReplace, key, A_ThisHotkey, $
		StringReplace, key, key, *
		StringReplace, key, key, ^
		StringReplace, key, key, +
		StringReplace, key, key, !
		StringReplace, key, key, #
		StringReplace, key, key, ~,
		StringReplace, key, key, <,
		StringReplace, key, key, >,
		StringLower, key, key
		outputdebug %key% down
		controldown := GetKeyState("Control","P")
		outputdebug control before f: %controldown%
		Send {Blind}{%key% Down}
		controldown := GetKeyState("Control","P")
		outputdebug control after f: %controldown%
		KeyWait %key%
		Send {Blind}{%key% Up}
		outputdebug %key% up
	}
	*/
	return
}
WaitForShiftUp:
if(!GetKeyState("Shift", "P"))
{
	outputdebug shift up
	Send {Blind}{Shift Up}
	SetTimer, WaitForShiftUp, Off
}
return
WaitForAltUp:
if(!GetKeyState("Alt", "P"))
{
	outputdebug alt up
	Send {Blind}{Alt Up}
	SetTimer, WaitForAltUp, Off
}
return
WaitForControlUp:
if(!GetKeyState("Control", "P"))
{
	outputdebug control up
	Send {Blind}{Control Up}
	SetTimer, WaitForControlUp, Off
}
return
WaitForWinUp:
if(!GetKeyState("LWin", "P") && !GetKeyState("RWin", "P"))
{
	outputdebug lwin up
	Send {Blind}{LWin Up}
	SetTimer, WaitForWinUp, Off
}
return