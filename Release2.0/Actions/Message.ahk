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

Action_Message_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Text", "", "", "Text:", "Placeholders", "Action_Message_Text_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Title", "", "", "Window Title:", "Placeholders", "Action_Message_Title_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Timeout", "", "", "Timeout:")
	}
	else if(GoToLabel = "Text_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Text")
	else if(GoToLabel = "Title_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Title")
}
Action_Message_Text_Placeholders:
Action_Message_GuiShow("", "", "Text_Placeholders")
return

Action_Message_Title_Placeholders:
Action_Message_GuiShow("", "", "Title_Placeholders")
return

Action_Message_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
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