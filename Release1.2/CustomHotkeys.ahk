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
	CustomHotkeys.Append(Object("key",key,"command",command,"filter",filter))
	if(filter)
		Hotkey, If, GetActiveProcessName()="%filter%"
	Hotkey, %key%, CustomHotkey, On
	if(filter)
		Hotkey, If,
}
#p::
Loop % CustomHotkeys.len()
{
key:=CustomHotkeys[A_Index].key
command:=CustomHotkeys[A_Index].command
filter:=CustomHotkeys[A_Index].filter
outputdebug key %key% command %command% filter %filter%
}
return

RemoveHotkey(key,filter="")
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if((!filter && CustomHotkeys[A_Index].key = key)||(CustomHotkeys[A_Index].key = key && CustomHotkeys[A_Index].filter = filter))
		{
			CustomHotkeys.Delete(A_Index)
			if(filter)
				Hotkey, If, GetActiveProcessName()="%filter%"
			Hotkey, %key%, Off
			if(filter)
				Hotkey, If,
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
		if(filter)
			Hotkey, If, GetActiveProcessName()="%filter%"
		Hotkey, %key%, Off
		if(filter)
			Hotkey, If,
	}
	CustomHotkeys := Array()	
}
SaveHotkeys()
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if(A_Index=0)
			HotkeyString := CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command "|" CustomHotkeys[A_Index].filter
		else
			HotkeyString .= "|" CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command "|" CustomHotkeys[A_Index].filter
	}
	IniWrite, %HotkeyString%, %A_ScriptDir%\Settings.ini, CustomHotkeys, CustomHotkeys
}
CollisionCheck(key1,filter1)
{
	global CustomHotkeys
	7PlusHotkeys := "#h,#y,#v,#e,*!c,+c,+x,^i,+Enter,^t,^Tab,^+Tab,^w,^Numpad0,^Numpad1,^Numpad2,^Numpad3,^Numpad4,^Numpad5,^Numpad6,^Numpad7,^Numpad8,^Numpad9,!Numpad0,!Numpad1,!Numpad2,!Numpad3,!Numpad4,!Numpad5,!Numpad6,!Numpad7,!Numpad8,!Numpad9,^u,!Insert,#Insert,#Delete,#c,#+Left,#+Up,#+Right,#+Down,!WheelDown,!WheelUp,^v,!F4,!F5,!LButton"
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
CustomHotkey:
CustomHotkey()
return

CustomHotkey()
{
	global CustomHotkeys
	name := GetActiveProcessName()
	Loop % CustomHotkeys.len()
	{
		if(A_ThisHotkey = CustomHotkeys[A_Index].key && name = CustomHotkeys[A_Index].filter)
		{
			command := CustomHotkeys[A_Index].command
			break
		}
	}
	if(!command)
	{
		Loop % CustomHotkeys.len()
		{		
			if(A_ThisHotkey = CustomHotkeys[A_Index].key)
			{
				command := CustomHotkeys[A_Index].command
				break
			}
		}
	}
	if(command)
	{
		if(InStr(command,"${"))
		{
			If(WinActive("ahk_group ExplorerGroup"))
			{
				StringReplace, command, command, ${P}, "%ExplorerPath%"
				files:=GetSelectedFiles()
				Loop, Parse, files, `n, %A_Space%
				{
					StringReplace, command, command, ${%A_Index%}, "%A_LoopField%"
				}
				command := RegExReplace(command, "\$\{\d+}")
			}
			Else
				command := RegExReplace(command, "\$\{.*}")
		}
		run %command%
	}
	return 
}