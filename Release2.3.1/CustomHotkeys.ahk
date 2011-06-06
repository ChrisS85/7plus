CollisionCheck(key1,filter1,exclude)
{
	global CustomHotkeys
	7PlusHotkeys := "#e,^i,^t,^Tab,^+Tab,^w,#Delete,!LButton"
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