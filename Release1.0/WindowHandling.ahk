;Check screen borders/corners for Aero Flip 3D and Slide Windows
hovercheck: 
HoverCheck()
return

HoverCheck()
{
	global HKSlideWindows,Vista7,MouseX,MouseY,AeroFlipTime
	static lastx,lasty
	MouseGetPos, MouseX,MouseY,win,control
	WinGetClass, class, ahk_id %win%
	x:=IsFullscreen("A",false,false)
	if(!x)
	{
    if(MouseX != lastx || MouseY != lasty)
    	SlideWindows_OnMouseMove(MouseX,MouseY)
    SlideWindows_CheckWindowState()
	}
  if (Vista7 && !x && (MouseX != lastx || MouseY != lasty) && MouseX=0 && MouseY=0 && !WinActive("ahk_class Flip3D"))
  { 
  	z:=-(AeroFlipTime*1000+1)
    SetTimer, hovering, %z%
  } 
  lastx := MouseX
  lasty := MouseY
	return
}

;Hovering timer for Aero Flip 3D
hovering: 	
	if (GetKeyState("LButton") || GetKeyState("RButton") || WinActive("ahk_class Flip3D")) 
      return 
  if(MouseX!=0||MouseY!=0)
		return 
	if(IsFullscreen("A",false,false))
		return
  Send ^#{Tab} 
	SetTimer, hovering, off
  return

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

;ctrl+v in cmd->paste, alt+F4 in cmd->close
#if HKImproveConsole && WinActive("ahk_class ConsoleWindowClass")
^v::
	Coordmode,Mouse,Relative
	MouseGetPos, MouseX, MouseY
	Click right 40,40
	Send {Down 3}
	send {Enter}
	MouseMove MouseX,MouseY
	return
!F4::
	WinClose, A
	return
#If

;Alt+F5: Kill active window
#if HKKillWindows
!F5::
	CloseKill()
	return
#if

;Force kill program on Alt+F5 and on right click close button
CloseKill()
{
	WinGet, pid, pid, A
	WinKill A, , 1
	WinGet, pid1 , pid, A
	if(pid=pid1)
		Process close, %pid1%
}

;Close on middle click titlebar
TitleBarClose()
{
	global
	if(!HKTitleClose)
		return false
	x:=MouseHittest()
	if(x=2)
		WinClose, A
	else
		return false
	return true
}

;Middle click on taskbutton->close task
TaskButtonClose()
{
	global
	outputdebug taskbuttonclose
	if(HKMiddleClose && IsMouseOverTaskList())
	{
		/*
		if(A_OSVersion="WIN_7")
			Send {Shift down}
		*/
		click right
		while(!IsContextMenuActive() && A_OSVersion!="WIN_7")
			sleep 10
		Sleep 300
		/*
		if(A_OSVersion="WIN_7")
			Send {Shift up}
		*/
		Send {up}{enter}
		return true
	}
	outputdebug not handled
	return false
}

;Flash Windows activation
#if HKFlashWindow && BlinkingWindows.len()>0 && !IsFullscreen()
Capslock::
	z:=BlinkingWindows[1]
	WinActivate ahk_id %z%
	return
#if

;Current/Previous Window toggle
#if HKToggleWindows && (!HKFlashWindow || BlinkingWindows.len()=0) && !IsFullscreen()
Capslock::WinActivate ahk_id %PreviousWindow%
#if

;RButton on title bar -> toggle always on top
#if ((z:=MouseHittest())=2 && HKToggleAlwaysOnTop) || (z=20 && HKKillWindows)|| (z=8 && HKTrayMin)
~RButton::
;If we hit something, we swallow the click, and need that toggle var therefore
If (z=2)
{  
	MouseGetPos, , , z
	WinActivate ahk_id %z%
	WinSet, AlwaysOnTop, toggle, ahk_id %z%
	SendInput {Escape} ;Escape is needed to suppress the annoying menu on titlebar right click     
}
else if(z=20)
	CloseKill()  	
else if(z=8)
{
	MouseGetPos, , , z
	WinTraymin(z)
}
	
Return
#if

; Alt+LButton Window dragging, slightly modified by Fragman

; This script modified from the original: http://www.autohotkey.com/docs/scripts/EasyWindowDrag.htm
; by The How-To Geek
; http://www.howtogeek.com

#if HKAltDrag && IsDraggable()
!LButton::EWD_StartDrag()
#if

IsDraggable()
{
	MouseGetPos,,,win
	WinGet,style,style,ahk_id %win%
	if(style & 0x80000000 && !(style & 0x00400000 || style & 0x00800000 || style & 0x00080000)) ;WS_POPUP && !WS_DLGFRAME && !WS_BORDER && !WS_SYSMENU
		return false
	if(WinGetClass("ahk_id " win)="Notepad++") ;Notepad++ uses Alt+LButton for rectangular text selection
		return false
	return true
}

EWD_StartDrag()
{
	global
	local EWD_WinState
	MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
	WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
	WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
	if EWD_WinState = 0  ; Only if the window isn't maximized 
	    SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
}

EWD_WatchMouse:
EWD_WatchMouse()
return

EWD_WatchMouse()
{
	global EWD_MouseWin, EWD_OriginalPosX,EWD_OriginalPosY,EWD_MouseStartX,EWD_MouseStartY
	GetKeyState, EWD_LButtonState, LButton, P
	if EWD_LButtonState = U  ; Button has been released, so drag is complete.
	{
	    SetTimer, EWD_WatchMouse, off
	    return
	}
	GetKeyState, EWD_EscapeState, Escape, P
	if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
	{
	    SetTimer, EWD_WatchMouse, off
	    WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
	    return
	}
	
	; Otherwise, reposition the window to match the change in mouse coordinates
	; caused by the user having dragged the mouse:
	CoordMode, Mouse
	MouseGetPos, EWD_MouseX, EWD_MouseY
	WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
	SetWinDelay, -1   ; Makes the below move faster/smoother.
	WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
	EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
	EWD_MouseStartY := EWD_MouseY
}
