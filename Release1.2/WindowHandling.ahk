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
DllCall("Dwmapi.dll\DwmIsCompositionEnabled","IntP",Aero_On)
if(Aero_On)
	Send ^#{Tab} 
Else
	Send ^!{Tab}
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

;Alt + MouseWheel Min/Max
#if HKAltMinMax && !MouseMinMaxRunning
!WheelDown::MouseMin()
#if
#if HKAltMinMax && !MouseMinMaxRunning
!WheelUp::MouseMax()
#if
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
	if(HKMiddleClose && IsMouseOverTaskList())
	{
		/*
		if(A_OSVersion="WIN_7")
			Send {Shift down}
		*/
		click right
		while(!IsContextMenuActive() && A_OSVersion!="WIN_7")
			sleep 10
		if(A_OsVersion="WIN_7") ;wait until the menu has slided out
		{
			prevx:=0
			prevy:=0
			x:=1
			y:=1
			while(true)
			{
				if(IsContextMenuActive())
				{
					Send {Esc}
					return true
				}
				if(WinActive("ahk_class DV2ControlHost"))
					break
				Sleep 10
			}
			while(prevx!=x || prevy!=y)
			{
				prevx:=x
				prevy:=y
				WinGetPos x,y,,,ahk_class DV2ControlHost
				Sleep 10
			}
		}
		/*
		if(A_OSVersion="WIN_7")
			Send {Shift up}
		*/
		Send {up}{enter}
		return true
	}
	return false
}

;Flash Windows activation
;Current/Previous Window toggle
#if (HKFlashWindow||HKToggleWindows) && !IsFullscreen()
Capslock::FlashWindows()
#if

FlashWindows()
{ 
	global BlinkingWindows,HKToggleWindows,PreviousWindow
	outputdebug capslock!	
	if(z:=FindWindow("","",0x16CF0000,0x00000188,"trillian.exe")) ;Trillian isn't needed usually, but if tabs are used, clicking the window is preferred
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=5
		outputdebug click trillian %x% %y%
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
		outputdebug click opera
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
		outputdebug click firefox/thunderbird %x% %y% %w% %h%
		MouseGetPos,mx,my
		ControlClick,,ahk_id %z%
		MouseMove %mx%,%my%,0
	}	
	else if(z:=FindWindow("","",0x96000000,0x00000088,"Steam.exe"))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		outputdebug click steam %x% %y%
		MouseGetPos,mx,my
		Click %x% %y%
		MouseMove %mx%,%my%,0
	}
	else if(z:=FindWindow("TTrayAlert"))
	{
		WinGetPos x,y,w,h,ahk_id %z%
		x+=w/2
		y+=h/2
		outputdebug click skype %x% %y%
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

;RButton on title bar -> toggle always on top
#if ((z:=MouseHittest())=2 && HKToggleAlwaysOnTop) || (z=20 && HKKillWindows)|| (z=8 && HKTrayMin)
~RButton::
;If we hit something, we swallow the click, and need that toggle var therefore
If (z=2)
{  
	MouseGetPos, , , z
	WinActivate ahk_id %z%
	WinSet, AlwaysOnTop, toggle, ahk_id %z%
	if(IsContextMenuActive())
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
