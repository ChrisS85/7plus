;Adds a row of controls to a SubEvent GUI. Control handles are stored in SubEventGUI, and can be stored back and have the controls delete by SubEventGUI_GUISubmit
SubEventGUI_Add(SubEvent, SubEventGUI, type, name, text, glabel="", description="", Button1Text="", Button1gLabel = "", Button2Text="", Button2gLabel = "")
{
	global Settings_Events
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
		if(!Button1Text)
		{
			w += 60
			if(!Button2Text)
				w += 60
		}
		Gui, Add, Text, x%x% y%y% w%w% hwndText_%name% r1, %text%
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
		else
		{
			Gui, Add, Checkbox, x%x% y%y% hwndCheck_%name%, %text%
			if(SubEvent[name] != 0)
				Msgbox SubEventGUI_Add(%type%,%name%, %text%, %description%) has wrong checkbox value!
		}
		y += 30
		SubEventGUI["Check_" name] := Check_%name%
	}
	else if(type = "Edit")
	{
		y += 1
		text := SubEvent[name]
		options = x%x% y%y% w%w% hwndEdit_%name% -Multi R1
		options .= InStr(name, "password") ? " Password" : ""
		Gui, Add, Edit, %options% , %text%
		y -= 1
		y += 30
		SubEventGUI["Edit_" name] := Edit_%name%
	}
	else if(type = "Button")
	{
		Gui, Add, Button, x%x% y%y% w%w% hwndButton_%name% g%gLabel% r1 -Wrap, %text%
		y += 30
		SubEventGUI["Button_" name] := Button_%name%
	}
	else if(type = "DropDownList")
	{
		;Select event dropdownlist
		if(strStartsWith(text, "TriggerType:"))
		{
			Triggertype := SubStr(text, 13)
			text := ""
			Loop % Settings_Events.len()
			{
				if(!TriggerType || Settings_Events[A_Index].Trigger.Type = TriggerType)
					text .= Settings_Events[A_Index].ID ": " Settings_Events[A_Index].Name "|"
			}
		}
		;Construct options
		Loop, Parse, text, |
		{
			if(A_LoopField)
				if(InStr(A_LoopField, ": "))
					text1 .= A_LoopField (SubStr(A_LoopField, 1, InStr(A_LoopField, ": ") - 1) = SubEvent[name] ? "||" : "|")
				else
					text1 .= A_LoopField (A_LoopField = SubEvent[name] ? "||" : "|")
		}
		if(!strEndsWith(text1,"||"))
			text1 := SubStr(text1, 1, -1)
		options = x%x% y%y% w%w% hwndDropDown_%name%
		if(gLabel != "")
			options .= " g" gLabel
		Gui, Add, DropDownList, %options%, %text1%
		SubEventGUI["DropDown_" name] := DropDown_%name%
		y += 30
	}
	else if(type = "Time")
	{
		text := SubEvent[name]
		outputdebug time %text%
		Gui, Add, DateTime, x%x% y%y% hwndTime_%name% Choose20100101%text%, Time
		y += 30
		SubEventGUI["Time_" name] := Time_%name%
	}
	if(Button1Text != "")
	{				
		x += 210
		y := SubEventGUI.y
		w := 70
		if(Button2Text != "")
			Gui, Add, Button, x%x% y%y% w%w% hwndButton1_%name% g%Button1gLabel% r1 -Wrap, %Button1Text%
		else
			Gui, Add, Button, x%x% y%y% hwndButton1_%name% g%Button1gLabel% r1 -Wrap, %Button1Text%
		y += 30
		SubEventGUI["Button1_" name] := Button1_%name%
		if(Button2Text != "")
		{		
			x += 76
			y := SubEventGUI.y
			Gui, Add, Button, x%x% y%y% w%w% hwndButton2_%name% g%Button2gLabel% r1 -Wrap, %Button2Text%
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
	;Loop over all controls added to SubEventGUI, and store their results and delete them
	enum := SubEventGUI._newEnum()
	while enum[key,value]
	{
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
			if(InStr(text, ": "))
				text := SubStr(text, 1, InStr(text, ": ") - 1)
			outputdebug save %name% %text%
			SubEvent[name] := text
			WinKill, ahk_id %value%
		}
		else if(strStartsWith(key, "Time_"))
		{
			name := SubStr(key, 6)
			ControlGetText, text, , ahk_id %value%
			StringReplace, text, text, :,,All
			outputdebug store %text% in %name%
			SubEvent[name] := text
			WinKill, ahk_id %value%
		}
	}
}

SubEventGUI_Browse(SubEventGUI, name, Title="Select Folder",Options=0, Quote=0)
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
				if(Quote)
					path := Quote(path)
				ControlSetText, , %path%, ahk_id %value%
				break
			}
		}
	}
}
SubEventGUI_SelectFile(SubEventGUI, name, Title = "Select File", Filter = "", Quote=0, options = 3)
{
	Gui +OwnDialogs
	FileSelectFile, path , %options%, , %Title%, %Filter%
	if(path != "")
	{
		enum := SubEventGUI._newEnum()
		while enum[key,value]
		{
			if(InStr(key,"_" name) && !InStr(key, "Button1_") && !InStr(key, "Button2_") && !InStr(key, "Desc_"))
			{
				if(Quote)
					path := Quote(path)
				ControlSetText, , %path%, ahk_id %value%
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
		Menu, Placeholders_Mouse, add, ${MX} - Mouse X coordinate, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MY} - Mouse Y coordinate, PlaceholderHandler		
		Menu, Placeholders_Mouse, add, ${MXA} - Mouse X coordinate`, relative to active window, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MYA} - Mouse Y coordinate`, relative to active window, PlaceholderHandler		
		Menu, Placeholders_Mouse, add, ${MXU} - Mouse X coordinate`, relative to window under mouse, PlaceholderHandler
		Menu, Placeholders_Mouse, add, ${MYU} - Mouse Y coordinate`, relative to window under mouse, PlaceholderHandler
		
		Menu, Placeholders_System, add, ${Clip} - Clipboard contents, PlaceholderHandler
		Menu, Placeholders_System, add, ${Input} - Result of previous input action, PlaceholderHandler
		Menu, Placeholders_System, add, ${MessageResult} - Result of previous SendMessage action (Send only!), PlaceholderHandler
		Menu, Placeholders_System, add, ${wParam} - wParam value if this condition/action was triggered by OnMessage trigger, PlaceholderHandler
		Menu, Placeholders_System, add, ${lParam} - lParam value if this condition/action was triggered by OnMessage trigger, PlaceholderHandler
		
		Menu, Placeholders_Windows, add, ${A} - Active window handle, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${Class} - Active window class, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${Title} - Active window title, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${Control} - Focussed control ClassNN, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${TitlePath} - Path in active window title, PlaceholderHandler
		Menu, Placeholders_Windows, add, ${TitleFilename} - Path and filename in active window title, PlaceholderHandler
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