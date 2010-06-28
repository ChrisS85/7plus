Event_ExpandPlaceHolders(Event,text)
{
	outputdebug expand %text%
	Loop % Event.Placeholders.len()
	{
		Placeholder := Event.Placeholders[A_Index].Placeholder
		if(InStr(text,Placeholder))
			text := StringReplace(text, Placeholder, Event.Placeholders[A_Index].value)
	}
	return ExpandGlobalPlaceHolders(text)
}

ExpandGlobalPlaceholders(text)
{
	global ExplorerPath,PreviousExplorerPath
	text := StringReplace(text, "%ProgramFiles%", A_ProgramFiles, 1)
	text := StringReplace(text, "%Windir%", A_WinDir, 1)
	text := StringReplace(text, "%Temp%", A_Temp, 1)
	text := StringReplace(text, "%AppData%", A_AppData, 1)
	text := StringReplace(text, "%Desktop%", A_Desktop, 1)
	text := StringReplace(text, "%MyDocuments%", A_MyDocuments, 1)
	text := StringReplace(text, "${Clip}", Clipboard, 1)
	text := StringReplace(text, "${A}", WinExist("A"), 1)
	MouseGetPos,x,y,UnderMouse
	text := StringReplace(text, "${U}", UnderMouse, 1)
	text := StringReplace(text, "${MX}", x, 1)
	text := StringReplace(text, "${MX}", y, 1)
	while(RegExMatch(text, "\$\{DateTime[^}]+}", match))
	{
		match := SubStr(SubStr(match,11),1,-1)
		FormatTime, match ,, %match%
		text := RegExReplace(text, "\$\{DateTime[^}]+}", match,"",1)
	}
	;Extract filename from active window title
	RegExMatch(WinGetTitle("A"),"([a-zA-Z]:\\[^/:\*\?<>\|]+\.\w{2,6})|(\\\\[^/:\*\?<>\|]+\.\w{2,6})",titlepath)
	StringReplace, text, text, ${T}, "%titlepath%"
	If(WinActive("ahk_group ExplorerGroup")) ;Supported placeholders: ${P} - Current Path, ${Sel\d+} - selectedfile[i], ${N} - All selected files separated by spaces
	{
		StringReplace, text, text, ${P}, "%ExplorerPath%"		
		StringReplace, text, text, ${PP}, "%PreviousExplorerPath%"
		if(InStr(text,"${Sel"))
		{
			files:=GetSelectedFiles()
			Loop, Parse, files, `n, %A_Space%
			{
				StringReplace, text, text, ${Sel%A_Index%}, "%A_LoopField%"
			}
			text := RegExReplace(text, "\$\{Sel\d+}") ;remove placeholders for no selected files
			files2 := ""
			Loop, Parse, files, `n
				files2 .= """" A_LoopField """ "
			files2 := strTrimRight(files2," ")
			
			StringReplace, text, text, ${SelN}, %files2%
		}
	}
	return text
}