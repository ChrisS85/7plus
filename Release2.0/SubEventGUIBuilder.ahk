;Adds a row of controls to a SubEvent GUI. Control handles are stored in SubEventGUI, and can be stored back and have the controls delete by SubEventGUI_GUISubmit
SubEventGUI_Add(SubEvent, SubEventGUI, type, name, text, glabel="", description="", Button1Text="", Button1gLabel = "", Button2Text="", Button2gLabel = "")
{
	x := SubEventGUI.x
	y := SubEventGUI.y
	w := 200
	if(description != "")
	{
		y += 4
		Gui, Add, Text, x%x% y%y% hwndDesc_%name%, %description%
		SubEventGUI["Desc_" name] := Desc_%name%
		x += 70
		y -= 4
	}
	if(type = "Text")
	{
		y += 4
		if(description = "") ;No description, more space for text
			w += 100
		Gui, Add, Text, x%x% y%y% w%w% hwndText_%name%, %text%
		SubEventGUI["Text_" name] := Text_%name%
		if(description = "")
			w -= 100
		y -= 4
		y += 20
	}	
	else if(type = "Checkbox")
	{
		if(SubEvent[name] = 1)
			Gui, Add, Checkbox, x%x% y%y% hwndCheck_%name% Checked, %text%
		else if(SubEvent[name] = 0)
			Gui, Add, Checkbox, x%x% y%y% hwndCheck_%name%, %text%
		else
			Msgbox SubEventGUI_Add(%type%,%name%, %text%, %description%) has wrong checkbox value!
		y += 30
		SubEventGUI["Check_" name] := Check_%name%
	}
	else if(type = "Edit")
	{
		y += 1
		text := SubEvent[name]
		Gui, Add, Edit, x%x% y%y% w%w% hwndEdit_%name%, %text%
		y -= 1
		y += 30
		SubEventGUI["Edit_" name] := Edit_%name%
	}
	else if(type = "Button")
	{
		Gui, Add, Button, x%x% y%y% w%w% hwndButton_%name% g%gLabel%, %text%
		y += 30
		SubEventGUI["Button_" name] := Button_%name%
	}
	else if(type = "DropDownList")
	{
		;Construct options
		Loop, Parse, text, |
			text1 .= A_LoopField (A_LoopField = SubEvent[name] ? "||" : "|")
		if(!strEndsWith(text1,"||"))
			text1 := SubStr(text1, 1, -1)
		options = x%x% y%y% w%w% hwndDropDown_%name%
		if(gLabel != "")
			options .= " g" gLabel
		Gui, Add, DropDownList, %options%, %text1%
		SubEventGUI["DropDown_" name] := DropDown_%name%
		y += 30
	}
	if(Button1Text != "")
	{				
		x += 210
		y := SubEventGUI.y
		w := 50
		Gui, Add, Button, x%x% y%y% w%w% hwndButton1_%name% g%Button1gLabel%, %Button1Text%
		y += 30
		SubEventGUI["Button1_" name] := Button1_%name%
		if(Button2Text != "")
		{		
			x += 60
			y := SubEventGUI.y
			Gui, Add, Button, x%x% y%y% w%w% hwndButton2_%name% g%Button2gLabel%, %Button2Text%
			y += 30
			SubEventGUI["Button2_" name] := Button2_%name%
		}
	}
	SubEventGUI.y := y
	z := SubEventGUI.y
	outputdebug post add %type% y%z%
}
SubEventGUI_GUISubmit(SubEvent, SubEventGUI)
{
	outputdebug sub guisubmit
	;Loop over all controls added to SubEventGUI, and store their results and delete them
	enum := SubEventGUI._newEnum()
	while enum[key,value]
	{
		outputdebug loop %key% %value%
		if(strStartsWith(key, "Desc_") || strStartsWith(key, "Text_") || strStartsWith(key, "Button"))
		{
			WinKill, ahk_id %value%
		}
		else if(strStartsWith(key, "Check_"))
		{
			name := SubStr(key,7)
			ControlGet, Checked, Checked, , ,ahk_id %value%
			SubEvent[name] := Checked
			outputdebug save %name% %checked%
			WinKill, ahk_id %value%
		}
		else if(strStartsWith(key, "Edit_"))
		{
			name := SubStr(key, 6)
			ControlGetText, text, , ahk_id %value%
			SubEvent[name] := text
			outputdebug save %name% %text%
			WinKill, ahk_id %value%
		}
		else if(strStartsWith(key, "DropDown_"))
		{
			name := SubStr(key, 10)
			ControlGetText, text, , ahk_id %value%
			outputdebug save %name% %text%
			SubEvent[name] := text
			WinKill, ahk_id %value%
		}
	}
}

SubEventGUI_Browse(SubEventGUI,name,Title="Select Folder",Options=0)
{
	Gui +OwnDialogs
	path:=COM_CreateObject("Shell.Application").BrowseForFolder(0, Title, Options).Self.Path
	if(path!="")
	{
		enum := SubEventGUI._newEnum()
		while enum[key,value]
		{
			if(InStr(key,"_" name) && !InStr(key, "Button1_") && !InStr(key, "Button2_") && !InStr(key, "Desc_"))
			{
				ControlSetText, , %path%, ahk_id %value%
				break
			}
		}
	}
}
SubEventGUI_SelectFile(SubEventGUI, name, Title = "", Filter = "")
{
	if(Title = "")
		Title := "Select File"
	Gui +OwnDialogs
	FileSelectFile, path , 3, , %Title%, %Filter%
	if(path != "")
	{
		enum := SubEventGUI._newEnum()
		while enum[key,value]
		{
			outputdebug key %key% name %name%
			if(InStr(key,"_" name) && !InStr(key, "Button1_") && !InStr(key, "Button2_") && !InStr(key, "Desc_"))
			{
				ControlSetText, , "%path%", ahk_id %value%
				break
			}
		}
	}
}
SubEventGUI_Placeholders(SubEventGUI, name, ClickedMenu="")
{
	static sSubEventGUI,sname
	if(ClickedMenu = "")
	{
		sSubEventGUI := SubEventGUI
		sname := name
		
		Menu, Placeholders, add, 1,PlaceholderHandler
		Menu, Placeholders, DeleteAll
		
		Menu, Placeholders_FilePaths, add, 1,PlaceholderHandler
		Menu, Placeholders_FilePaths, DeleteAll
		Menu, Placeholders_DateTime, add, 1,PlaceholderHandler
		Menu, Placeholders_DateTime, DeleteAll		
		Menu, Placeholders_Explorer, add, 1,PlaceholderHandler
		Menu, Placeholders_Explorer, DeleteAll
		Menu, Placeholders_Mouse, add, 1,PlaceholderHandler
		Menu, Placeholders_Mouse, DeleteAll
		Menu, Placeholders_System, add, 1,PlaceholderHandler
		Menu, Placeholders_System, DeleteAll
		Menu, Placeholders_Windows, add, 1,PlaceholderHandler
		Menu, Placeholders_Windows, DeleteAll
		
		Menu, Placeholders, add, Date and Time, :Placeholders_DateTime
		Menu, Placeholders, add, Explorer, :Placeholders_Explorer
		Menu, Placeholders, add, File Paths, :Placeholders_FilePaths
		Menu, Placeholders, add, Mouse, :Placeholders_Mouse
		Menu, Placeholders, add, System, :Placeholders_System
		Menu, Placeholders, add, Windows, :Placeholders_Windows
		
		Menu, Placeholders_DateTime, add, ${DateTime} - Language-specific time and date (4:55 PM Saturday`, November 27`, 2010), PlaceholderHandler
		Menu, Placeholders_DateTime, add, ${DateTimeLongDate} - Language-specific long date (Friday`, April 23`, 2010), PlaceholderHandler
		Menu, Placeholders_DateTime, add, ${DateTimeShortDate} - Language-specific short date (02/29/10), PlaceholderHandler
		Menu, Placeholders_DateTime, add, ${DateTimeTime} - Language-specific time (5:26 PM), PlaceholderHandler
		Menu, Placeholders_DateTime, add, ${DateTime[Format]} - Other [Format]`, see here, PlaceholderHandler
		
		Menu, Placeholders_Explorer, add, ${P} - Path of last active explorer window, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${PP} - Previous path of explorer window, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${Sel1} - Filepath of first selected file, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${Sel2DQ} - Directory of second selected file`, quoted, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${Sel3N} - Filename of third selected file`, no extension, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${Sel4NE} - Filename of fourth selected file`, including extension, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${SelN} - Filepaths of all selected files`, separated by spaces, PlaceholderHandler
		Menu, Placeholders_Explorer, add, ${SelNNEM} - Filenames+extensions of all selected files`, separated by new lines, PlaceholderHandler
		Menu, Placeholders_Explorer, add, Feel free to combine those expressions!, PlaceholderHandler
		
		Menu, Placeholders_FilePaths, add, `%ProgramFiles`% - Program Files Directory, PlaceholderHandler
		Menu, Placeholders_FilePaths, add, `%AppData`% - AppData Directory, PlaceholderHandler
		Menu, Placeholders_FilePaths, add, `%Desktop`% - Desktop Directory, PlaceholderHandler
		Menu, Placeholders_FilePaths, add, `%MyDocuments`% - My Documents Directory, PlaceholderHandler
		Menu, Placeholders_FilePaths, add, `%Temp`% - Temp Directory, PlaceholderHandler
		
		Menu, Placeholders_Mouse, add, ${U} - Handle of window under mouse, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MX} - Mouse X Coordinate, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MY} - Mouse Y Coordinate, PlaceholderHandler		
		Menu, Placeholders_Mouse, add, ${MXA} - Mouse X Coordinate`, relative to active window, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MYA} - Mouse Y Coordinate`, relative to active window, PlaceholderHandler		
		Menu, Placeholders_Mouse, add, ${MXU} - Mouse X Coordinate`, relative to window under mouse, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MYU} - Mouse Y Coordinate`, relative to window under mouse, PlaceholderHandler
		
		Menu, Placeholders_System, add, ${Clip} - Clipboard Contents, PlaceholderHandler
		
		Menu, Placeholders_Windows, add, ${A} - Active Window Handle, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${T} - File Path in active window title, PlaceholderHandler
		
		Menu, Placeholders, Show
	}
	else
	{
		if(ClickedMenu = "${DateTime[Format]} - Other [Format], see here")
		{
			run http://www.autohotkey.com/docs/commands/FormatTime.htm
			return
		}
		else if(ClickedMenu = "Feel free to combine those expressions!")
			return
		else if(InStr(ClickedMenu, "-"))
			placeholder := SubStr(ClickedMenu, 1, InStr(ClickedMenu, " -") - 1)
		
		enum := sSubEventGUI._newEnum()
		while enum[key,value]
		{
			if(InStr(key,"_" sname) && !InStr(key, "Button1_") && !InStr(key, "Button2_") && !InStr(key, "Desc_"))
			{
				ControlGetText, text, , ahk_id %value%
				ControlSetText, , %text%%placeholder%, ahk_id %value%
				break
			}
		}
	}
}
PlaceholderHandler:
SubEventGUI_Placeholders("","",A_ThisMenuItem)
return