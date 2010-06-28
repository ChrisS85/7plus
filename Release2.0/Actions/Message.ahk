Action_Message_Init(Action)
{
	Action.Category := "System"
}	
Action_Message_ReadXML(Action, ActionFileHandle)
{
	Action.Text := xpath(ActionFileHandle, "/Text/Text()")
	Action.Title := xpath(ActionFileHandle, "/Title/Text()")
	Action.Timeout := xpath(ActionFileHandle, "/Timeout/Text()")
}
Action_Message_WriteXML(Action, ByRef ActionFileHandle, Path)
{
	xpath(ActionFileHandle, Path "Text[+1]/Text()", Action.Text)
	xpath(ActionFileHandle, Path "Title[+1]/Text()", Action.Title)
	xpath(ActionFileHandle, Path "TimeOut[+1]/Text()", Action.Timeout)
}
Action_Message_Execute(Action,Event)
{
	global EventSchedule
	if(!Action.GuiNum)
	{
		result := CustomMsgBox(Event.ExpandPlaceHolders(Action.Title), Event.ExpandPlaceHolders(Action.Text))
		if(result) ;
		{
			Action.GuiNum := result
			Action.Time := A_TickCount
			return -1
		}
		else
			return 0 ;Msgbox wasn't created
	}
	else
	{
		GuiNum := Action.GuiNum
		;outputdebug waiting for messagebox close %guinum%
		Gui,%GuiNum%:+LastFound 
		WinGet, Msgbox_hwnd,ID
		DetectHiddenWindows, Off
		;outputdebug %A_IsCritical%
		If(WinExist("ahk_id " Msgbox_hwnd)) ;Box not closed yet, need more processing time
		{
			if(Action.Timeout > 0 && A_TickCount - Action.Time > Action.Timeout)
			{
				Gui, %GuiNum%:Destroy 
				return 0
			}
			return -1
		}
		else
			return 1 ;Box closed, all fine
	}
} 
Action_Message_DisplayString(Action)
{
	return "Message " Action.Text
}

Action_Message_GuiShow(Action, ActionGUI)
{
	x := ActionGui.x
	y := ActionGui.y
	y += 4
	Gui, Add, Text, x%x% y%y% hwndhwndtext1, Text:
	y += 30
	Gui, Add, Text, x%x% y%y% hwndhwndtext2, Window Title:
	y += 30
	Gui, Add, Text, x%x% y%y% hwndhwndtext3, Timeout:
	x += 70
	y -= 64
	w := 200
	text := Action.Text
	title := Action.Title
	timeout := Action.Timeout
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndText, %text%
	y += 30
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndTitle, %title%
	y += 30
	Gui, Add, Edit, x%x% y%y% w%w% hwndhwndTimeout, %timeout%
	
	ActionGUI.Text1 := hwndtext1
	ActionGUI.Text2 := hwndtext2
	ActionGUI.Text3 := hwndtext3
	ActionGUI.Text := hwndText
	ActionGUI.Title := hwndTitle
	ActionGUI.Timeout := hwndTimeout
}
Action_Message_GuiSubmit(Action, ActionGUI)
{
	text1 := ActionGUI.Text1
	text2 := ActionGUI.Text2
	text3 := ActionGUI.Text3
	hwndText := ActionGUI.Text
	hwndTitle := ActionGUI.Title
	hwndTimeout := ActionGUI.Timeout
	
	ControlGetText, Text, , ahk_id %hwndText%
	Action.Text := Text
	ControlGetText, Title, , ahk_id %hwndTitle%
	Action.Title := Title
	ControlGetText, Timeout, , ahk_id %hwndTimeout%
	Action.Timeout := Timeout
	
	WinKill, ahk_id %text1%
	WinKill, ahk_id %text2%
	WinKill, ahk_id %text3%
	WinKill, ahk_id %hwndText%
	WinKill, ahk_id %hwndTitle%
	WinKill, ahk_id %hwndTimeout%
}

;Non blocking message box (can wait for closing in event system though)
CustomMsgBox(Title,Message) 
{
	Critical, Off
	l_GUI:=10
    loop
	{
		;-- Window available?
		gui %l_GUI%:+LastFoundExist
		IfWinNotExist
			break

		;-- Nothing available?
		if l_GUI=99
		{
			MsgBox 262160
				,HotkeyGUI Error
				,Unable to create Msgbox window. GUI windows 10 to 99 are already in use.
			ErrorLevel=9999
			return ""
		}

		;-- Increment window
		l_GUI++
	}

	Gui,%l_GUI%:Destroy 
	Gui,%l_GUI%:Add,Text,,%Message% 

	Gui,%l_GUI%:Add,Button,% "Default y+10 w75 gCustomMsgboxOK xp+" (TextW / 2) - 38 ,OK 

	Gui,%l_GUI%:-MinimizeBox -MaximizeBox +LabelCustomMsgbox +AlwaysOnTop
	SoundPlay,*-1
	Gui,%l_GUI%:Show,,%Title% 
	
	;return Gui number to indicate that the message box is still open
	return l_GUI
}

CustomMsgboxClose:
CustomMsgboxEscape:
CustomMsgboxOK: 
Gui, Destroy 
return