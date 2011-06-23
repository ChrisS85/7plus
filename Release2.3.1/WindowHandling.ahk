;Check screen borders/corners for Aero Flip 3D
MouseMovePolling:
MouseMovePolling()
return

MouseMovePolling()
{
	global Vista7,MouseX,MouseY,AeroFlipTime, Events, SlideWindows
	static corner, hoverstart, ScreenCornerEvents ;Corner = 1234 (upper left, upper right, lower right, lower left), other values = not in corner
	static lastx,lasty
	;Get total size of all screens
	SysGet, VirtualX, 76
	SysGet, VirtualY, 77
	SysGet, VirtualW, 78
	SysGet, VirtualH, 79
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX,MouseY,win
	if(!IsFullscreen("A",false,false))
	{
		SlideWindows.OnMouseMove(MouseX, MouseY)
		if(corner = 1 && MouseX = VirtualX && MouseY = VirtualY
		||corner = 2 && MouseX = VirtualX + VirtualW - 1 && MouseY = VirtualY
		||corner = 3 && MouseX = VirtualX + VirtualW - 1&& MouseY = VirtualY + VirtualH - 1
		||corner = 4 && MouseX = VirtualX && MouseY = VirtualY + VirtualH - 1)
		{
			index := 1
			Loop % ScreenCornerEvents.len() ;Check if any of the events belonging to this corner have reached the time limit yet
			{
				if(ScreenCornerEvents[index].Time < A_TickCount - hoverstart)
				{
					outputdebug found event
					Trigger := EventSystem_CreateSubEvent("Trigger","ScreenCorner")
					Trigger.Corner := Corner
					TriggerSingleEvent(Events.SubItem("ID", ScreenCornerEvents[index].ID), Trigger) ;Trigger the single event and remove it from the list so it only gets triggered once
					ScreenCornerEvents.Remove(index)
				}
				else
					index++
			}
		}
		else
		{
			if(MouseX = VirtualX && MouseY = VirtualY)
				corner := 1
			else if(MouseX = VirtualX + VirtualW - 1 && MouseY = VirtualY)
				corner := 2
			else if(MouseX = VirtualX + VirtualW - 1 && MouseY = VirtualY + VirtualH - 1)
				corner := 3
			else if(MouseX = VirtualX && MouseY = VirtualY + VirtualH - 1)
				corner := 4
			else
			{
				corner := ""
				ScreenCornerEvents :=""
				hoverstart := ""
			}
			if(corner != "") ;Create an array of matching events to save some cpu time on later checks
			{
				ScreenCornerEvents := Array()
				Loop % Events.len()
				{
					if(Events[A_Index].Trigger.Type = "ScreenCorner" && Events[A_Index].Trigger.Corner = Corner)
						ScreenCornerEvents.append(Object("time", Events[A_Index].Trigger.Time, "Id", Events[A_Index].ID))
				}
				hoverstart := A_TickCount
			}
		}
		; if (Vista7  && (MouseX != lastx || MouseY != lasty) && MouseX=0 && MouseY=0 && !WinActive("ahk_class Flip3D"))
		; { 
			; z:=-(AeroFlipTime*1000+1)
			; SetTimer, hovering, %z%
		; }	
	}
	else
	{
		corner := ""
	}
	lastx := MouseX
	lasty := MouseY
	return
}

#if WordDelete && IsEditControlActive() && NothingSelected() ;Special checks for edit control to support .NET and native edit control
^Backspace::ControlBackspaceFix()
^Delete::ControlDeleteFix()
#if

IsEditControlActive()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus active, A
	else
		active:=XPGetFocussed()
	if(strStartsWith(active,"edit")||RegexMatch(active,"WindowsForms\d*.EDIT."))
		return true
	return false
}
NothingSelected()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
		focussed:=XPGetFocussed()
	ControlGet, selection, Selected,,%focussed%,A
	return selection = ""
}
ControlBackspaceFix()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
		focussed:=XPGetFocussed()
	ControlGet, line,CurrentLine,,%focussed%,A
	ControlGet, col,CurrentCol,,%focussed%,A
	ControlGet, text, Line,%line%,%focussed%,A
	SpecialChars := ".,;:""`\/!§$%&/()=#'+-*~€|<>``´{[]}"
	loop ;Remove spaces and tabs first
	{
		char := Substr(text,col-1,1)
		outputdebug spacecheck %char% %col%
		if(col>1 && (char = " " || char = "`t"))
		{
			col--
			count++
		}
		else
			break
	}
	char := Substr(text,col-1,1)
	if(InStr(SpecialChars,char))
		IsSpecial := true
	outputdebug special %isspecial%
	Loop
	{
		outputdebug loop %char%
		if(col=1 || char = " ") ;break on line start or when a space is found
		{
			if(A_Index = 1)
				count++ ;Remove line if there were only spaces or at start
			break
		}
		if((IsSpecial && InStr(SpecialChars,char)) || (!IsSpecial && !InStr(SpecialChars,char))) ;break on next word
		{
			col--
			count++
			char := Substr(text,col-1,1)
		}
		else		
			break
	}
	if(count>0)
		Send {Backspace %count%} ;Send backspace to remove the last %count% letters
	return
}
    
ControlDeleteFix()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
		focussed:=XPGetFocussed()
	ControlGet, line,CurrentLine,,%focussed%,A
	ControlGet, col,CurrentCol,,%focussed%,A
	ControlGet, text, Line,%line%,%focussed%,A
	SpecialChars := ".,;:""`\/!§$%&/()=#'+-*~€|<>``´{[]}"
	length := strLen(text)
	char := Substr(text,col,1)
	if(char = "") ;Linebreak(\r\n is removed automagically), only remove if first char
		CharType := 0
	else if(char = " " || char = "`t") ;Spaces, break immediately and treat after first loop
		CharType := 1
	else if(InStr(SpecialChars,char)) ;Special characters, remove all following of this type
		CharType := 2
	else							;alphanumeric characters, remove all following of this type
		CharType := 3
	Loop
	{
		;outputdebug char %char%
		if(CharType = 0 && A_Index = 1)
		{
			outputdebug line end
			count++
			line++
			col := 1
			ControlGet, text, Line,%line%,%focussed%,A
			char := Substr(text,col,1)
			break
		}
		if(CharType = 1) ;Treat spaces later as they are always removed
			break
		/*
		if(char = "`n" || char = "`r" || char = " " || char = "`t") ;break on line end and spaces
			break
			*/
		if(char && ((CharType = 2 && InStr(SpecialChars,char))  || (CharType = 3 && char != " " && char != "`t" && !InStr(SpecialChars,char)))) ;break on next word
		{
			col++
			count++
			char := Substr(text,col,1)
		}
		else
			break
	}   
	loop ;Remove spaces and tabs
	{
		outputdebug spacechar %char%
		if(char = " " || char = "`t")
		{
			col++
			count++
			char := Substr(text,col,1)
		}
		else
			break
	}
	if(count>0)
		Send {Delete %count%} ;Send backspace to remove the last %count% letters
	return
}
;Hovering timer for Aero Flip 3D
; hovering: 	
; if (GetKeyState("LButton") || GetKeyState("RButton") || WinActive("ahk_class Flip3D")) 
	; return 
; if(MouseX!=0||MouseY!=0)
	; return 
; if(IsFullscreen("A",false,false))
	; return
; DllCall("Dwmapi.dll\DwmIsCompositionEnabled","IntP",Aero_On)
; if(Aero_On)
	; Send ^#{Tab} 
; Else
	; Send ^!{Tab}
; SetTimer, hovering, off
; return

;Key remappers for Aero Flip 3D
#IfWinActive, ahk_class Flip3D 
Space::Enter 
Left::Right 
Right::Left 
Down::Up 
Up::Down 
RButton::Esc 
RWin::Esc
LWin::Esc
WheelUp::WheelDown
WheelDown::WheelUp
#if

; Alt + MouseWheel Min/Max
; #if HKAltMinMax && !MouseMinMaxRunning
; !WheelDown::MouseMin()
; #if
; #if HKAltMinMax && !MouseMinMaxRunning
; !WheelUp::MouseMax()
; #if
MouseMin()
{	
	global MouseMinMaxRunning
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	MouseMinMaxRunning:=true
	if(WinState = 0)
		PostMessage, 0x112, 0xF020,,, ahk_id %MouseWin% ;Winminimize, but apparently more reliable
	else
		WinRestore ahk_id %MouseWin%
	Sleep 500 ;Sleep some time to prevent accidental min/max
	MouseMinMaxRunning:=false
}

MouseMax()
{
	global MouseMinMaxRunning
	MouseMinMaxRunning:=true
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	if(WinState = 0)
		WinMaximize ahk_id %MouseWin%
	Sleep 500 ;Sleep some time to prevent accidental min/max
	MouseMinMaxRunning:=false
}

; ctrl+v in cmd->paste, alt+F4 in cmd->close
; #if HKImproveConsole && WinActive("ahk_class ConsoleWindowClass")
; ^v::
	; Coordmode,Mouse,Relative
	; MouseGetPos, MouseX, MouseY
	; Click right 40,40
	; Send {Down 3}
	; send {Enter}
	; MouseMove MouseX,MouseY
	; return
; !F4::
	; WinClose, A
	; return
; #If

; Alt+F5: Kill active window
; #if HKKillWindows
; !F5::
	; CloseKill(WinExist("A"))
	; return
; #if

; Close on middle click titlebar
; TitleBarClose()
; {
	; global
	; if(!HKTitleClose)
		; return false
	; x:=MouseHittest()
	; if(x=2)
		; WinClose, A
	; else
		; return false
	; return true
; }


; Flash Windows activation
; Current/Previous Window toggle
; #if (HKFlashWindow||HKToggleWindows) && !IsFullscreen()
; Capslock::FlashWindows()
; #if

FlashWindows()
{ 
	global BlinkingWindows,HKToggleWindows,PreviousWindow
	CoordMode, Mouse, Screen
	if(z:=FindWindow("","",0x16CF0000,0x00000188,"trillian.exe")) ;Trillian isn't needed usually, but if tabs are used, clicking the window is preferred
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=5
		MouseGetPos,mx,my
		ControlClick,, ahk_id %z%
		MouseMove %mx%,%my%,0
	}
	else if (BlinkingWindows.len()>0)
	{
		z:=BlinkingWindows[1]
		WinActivate ahk_id %z%
	}
	else if(z:=FindWindow("","OpWindow", 0x96000000, 0x88))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		MouseGetPos,mx,my
		ControlClick,,ahk_id %z% ;for some reason clicking the notification window isn't enough, so we manually activate opera window
		MouseMove %mx%,%my%,0
		z:=FindWindow("","OpWindow","",0x00000110)
		WinActivate ahk_id %z%
	}
	else if(z:=FindWindow("","MozillaUIWindowClass", 0x94000000, 0x88))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		MouseGetPos,mx,my
		ControlClick,,ahk_id %z%
		MouseMove %mx%,%my%,0
	}	
	else if(z:=FindWindow("","",0x96000000,0x00000088,"Steam.exe"))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		MouseGetPos,mx,my
		Click %x% %y%
		MouseMove %mx%,%my%,0
	}
	else if(z:=FindWindow("TTrayAlert"))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		MouseGetPos,mx,my
		Click %x% %y%
		MouseMove %mx%,%my%,0
	}
	else if(z:=FindWindow("","tooltips_class32", 0x940001C2, ""))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		outputdebug click tooltip %x% %y%
		MouseGetPos,mx,my
		Click %x% %y%
		MouseMove %mx%,%my%,0
	}
	else if(HKToggleWindows)
		WinActivate ahk_id %PreviousWindow%
	return
}