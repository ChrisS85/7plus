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
Action_Message_Execute(Action)
{
	global EventSchedule
	if(!Action.GuiNum)
	{
		result := CustomMsgBox(Action.Title, Action.Text, Action.Timeout)
		if(result) ;
		{
			outputdebug pre set guinum %result%
			loop % EventSchedule.len()
			{
				outputdebug(EventSchedule[A_Index].Actions[1].GuiNum)
			}
			Action.GuiNum := result
			outputdebug post set guinum %result%
			loop % EventSchedule.len()
			{
				outputdebug(EventSchedule[A_Index].Actions[1].GuiNum)
			}
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
			return -1
		else
			return 1 ;Box closed, all fine
	}
} 
Action_Message_DisplayString(Action)
{
	return "Message " Action.Text
}

CustomMsgBox(Title,Message,Timeout) 
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

	Gui,%l_GUI%:-MinimizeBox 
	Gui,%l_GUI%:-MaximizeBox 
	Gui,%l_GUI%:+LabelCustomMsgbox
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