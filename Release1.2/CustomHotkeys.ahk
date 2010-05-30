ReadHotkeys()
{
	global CustomHotkeys
	CustomHotkeys := Array()
	IniRead, hotkeys, %A_ScriptDir%\Settings.ini, CustomHotkeys, CustomHotkeys, %A_Space%
	Loop, Parse, hotkeys ,|, %A_Space%
	{
		if(!key)
			key := A_LoopField
		else
		{
			AddHotkey(key,A_LoopField)
			key := ""
		}
	}
}
AddHotkey(key,command)
{	
	global CustomHotkeys
	CustomHotkeys.Append(Object("key",key,"command",command))
	Hotkey, %key%, CustomHotkey, On
}
#p::
Loop % CustomHotkeys.len()
{
key:=CustomHotkeys[A_Index].key
command:=CustomHotkeys[A_Index].command
outputdebug key %key% command %command%
}
return
RemoveHotkey(key)
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if(CustomHotkeys[A_Index].key = key)
		{
			CustomHotkeys.Delete(A_Index)
			Hotkey, %key%, Off
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
		outputdeBug remove %key%
		Hotkey, %key%, Off
	}
	CustomHotkeys := Array()	
}
SaveHotkeys()
{
	global CustomHotkeys
	Loop % CustomHotkeys.len()
	{
		if(A_Index=0)
			HotkeyString := CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command
		else
			HotkeyString .= "|" CustomHotkeys[A_Index].key "|" CustomHotkeys[A_Index].command
	}
	IniWrite, %HotkeyString%, %A_ScriptDir%\Settings.ini, CustomHotkeys, CustomHotkeys
}
CollisionCheck(key1)
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
	return false
}
CustomHotkey:
Loop % CustomHotkeys.len()
{
	if(A_ThisHotkey = CustomHotkeys[A_Index].key)
	{
		temp := CustomHotkeys[A_Index].command
		if(InStr(temp,"${"))
		{
			If(WinActive("ahk_group ExplorerGroup"))
			{
				StringReplace, temp, temp, ${P}, "%ExplorerPath%"
				files:=GetSelectedFiles()
				Loop, Parse, files, `n, %A_Space%
				{
					StringReplace, temp, temp, ${%A_Index%}, "%A_LoopField%"
				}
				temp := RegExReplace(temp, "\$\{\d+}")
			}
			Else
				temp := RegExReplace(temp, "\$\{.*}")
		}
		outputdebug temp %temp%
		run %temp%
		break
	}
}
return 