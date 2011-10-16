;Main function to expand placeholders. Placeholders are marked by ${key} and by %PATH%
Event_ExpandPlaceHolders(Event,text)
{
	global Events
	if(IsObject(text)) ;Internally arrays may be supplied as parameters which mustn't be expanded here
		return text
	;Expand local dynamic placeholders (for example ${MessageResult} defined by SendMessage action)
	for key, value in Event.Placeholders
	{
		if(InStr(text,"${" key "}"))
			text := StringReplace(text, "${" key "}", value, 1)
	}
	;Expand dynamic placeholders with global scope (for example the result of an Input action)
	for key, value in Events.GlobalPlaceholders
	{
		if(InStr(text,"${" key "}"))
			text := StringReplace(text, "${" key "}", value, 1)
	}
	return ExpandInternalPlaceHolders(text)
}

;Expands internal placeholders found inside text
ExpandInternalPlaceholders(text)
{
	text := ExpandPathPlaceholders(text)
	len := strLen(text)
	pos := 1	
	Loop % len
	{
		2chars := SubStr(text, pos, 2)
		if(2chars = "${")
		{
			end := InStr(text, "}",0,pos + 2)
			if(end)
			{
				placeholder := SubStr(text, pos + 2, end - (pos + 2))
				expanded := ExpandPlaceholder(placeholder)
				text := SubStr(text, 1, pos - 1) expanded SubStr(text, end + 1)
				pos += strLen(expanded)
				continue
			}
		}
		pos++
	}
	return text
}

;Expand path placeholders like %ProgramFiles% or %TEMP%
ExpandPathPlaceholders(text)
{
	static sProgramFiles, sWinDir, sTemp, sAppData, sDesktop, sMyDocuments, sStartMenu, sStartMenuCommon, s7plusDrive
	if(!sProgramFiles)
	{
		sProgramFiles := GetFullPathName(A_ProgramFiles)
		sWinDir := GetFullPathName(A_WinDir)
		sTemp := GetFullPathName(A_Temp)
		sAppData := GetFullPathName(A_AppData)
		sDesktop := GetFullPathName(A_Desktop)
		sMyDocuments := GetFullPathName(A_MyDocuments)
		sStartMenu := GetFullPathName(A_StartMenu)
		sStartMenuCommon := GetFullPathName(A_StartMenuCommon)
		SplitPath, A_ScriptDir,,,,,s7plusDrive
	}
	StringReplace, text, text, `%ProgramFiles`%, %sProgramFiles%, All
	StringReplace, text, text, `%Windir`%, %sWindir%, All
	StringReplace, text, text, `%Temp`%, %sTemp%, All
	StringReplace, text, text, `%AppData`%, %sAppData%, All
	StringReplace, text, text, `%Desktop`%, %sDesktop%, All
	StringReplace, text, text, `%MyDocuments`%, %sMyDocuments%, All
	StringReplace, text, text, `%StartMenu`%, %sStartMenu%, All
	StringReplace, text, text, `%StartMenuCommon`%, %sStartMenuCommon%, All
	StringReplace, text, text, `%7plusDrive`%, %s7plusDrive%, All
	StringReplace, text, text, `%7plusDir`%, %A_ScriptDir%, All
	return text
}
;Expands a single placeholder. Placeholder argument contains only the name, without ${}
ExpandPlaceholder(Placeholder)
{
	global Vista7
	if(Placeholder = "Clip")
		return ReadClipboardText()
	else if(Placeholder = "A")
		return WinExist("A")
	else if(Placeholder = "Class")
		return WinGetClass("A")
	else if(Placeholder = "Title")
		return WinGetTitle("A")
	else if(Placeholder = "Control")
	{
		if(Vista7)
			ControlGetFocus focussed, A
		else
			focussed:=XPGetFocussed()
		return focussed
	}
	else if(Placeholder = "WinVer")
		return A_OSVersion
	else if(Placeholder = "U" || strStartsWith(Placeholder,"M")) ;Mouse submenu
	{
		if(strlen(Placeholder > 1) && InStr(Placeholder, "A") = 2)
			CoordMode, Mouse, Relative
		MouseGetPos,x,y,UnderMouse, Control
		if(strlen(Placeholder > 1) && InStr(Placeholder, "U") = 2)
		{
			WinGetPos, wx, wy, , ,ahk_id %UnderMouse%
			x -= wx
			y -= wy
		}
		if(Placeholder = "U")
			return UnderMouse
		else if(InStr(Placeholder, "X") = 2)
			return x
		else if(InStr(Placeholder, "Y") = 2)
			return y
		else if(InStr(Placeholder, "NN") = 2)
			return Control
		else if(InStr(Placeholder, "C") = 2)
			return WinGetClass("ahk_id " UnderMouse)
	}
	else if(strStartsWith(Placeholder, "DateTime"))
	{
		Placeholder := SubStr(Placeholder, 9)
		FormatTime, Placeholder ,, %Placeholder%
		return Placeholder
	}
	else if(Placeholder = "TitleFilename")
	{
		;Extract filename from active window title
		RegExMatch(WinGetTitle("A"),"([a-zA-Z]:\\[^/:\*\?<>\|]+\.\w{2,6})|(\\\\[^/:\*\?<>\|]+\.\w{2,6})",titlepath)
		return titlepath
	}
	else if(Placeholder = "TitlePath")
	{
		;Extract filename from active window title
		RegExMatch(WinGetTitle("A"),"([a-zA-Z]:\\[^/:\*\?<>\|]+\.\w{2,6})|(\\\\[^/:\*\?<>\|]+\.\w{2,6})",titlepath)
		SplitPath, titlepath,,titlepath
		return titlepath
	}
	else if(Placeholder = "P")
		return Settings.Explorer.CurrentPath
	else if(Placeholder = "T")
		return Settings.Explorer.PreviousPath
	else if(strStartsWith(Placeholder, "Sel") && (WinActive("ahk_group ExplorerGroup") || WinActive("ahk_group DesktopGroup") || IsDialog()))
	{
		files:=GetSelectedFiles()
		RegExMatch(Placeholder,"Sel\d+",number)
		array := Array()
		if(number)
		{
			number := SubStr(number, 4)
			StringSplit, files, files, `n
			if(files0 >= number)
				array.append(files%number%)
		}
		else if(strStartsWith(Placeholder, "SelN"))
			Loop, Parse, files, `n, %A_Space%
				array.append(A_LoopField)
		if(array.len() = 0)
			return ""
		Placeholder := SubStr(Placeholder, 4+max(strLen(number), 1))
		quote := InStr(Placeholder, "Q")
		Filename := InStr(Placeholder, "NE")
		FilenameNoExt := !Filename && InStr(Placeholder, "N")
		Extension := !Filename && InStr(Placeholder, "E")
		FilePath := InStr(Placeholder, "D")
		NewLine := InStr(Placeholder, "M")
		output := ""
		Loop % array.len()
		{
			file := array[A_Index]
			SplitPath, file, name, path, ext, namenoext
			if(Filename)
				file := name
			else if(FilenameNoExt)
				file := namenoext
			else if(Extension)
				file := ext
			else if(FilePath)
				file := path
			if(quote)
				file := """" file """"
			output .= file (NewLine ? "`n" : " ")
		}
		return SubStr(output,1,-1)
	}
}