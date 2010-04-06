#if WinActive("ahk_group ExplorerGroup")
+Enter::
if(FileExist(a_scriptdir "\temp.search-ms"))
	FileDelete %a_scriptdir%\temp.search-ms 
files:=GetSelectedFiles()
searchString=
(
<?xml version="1.0"?>
<persistedQuery version="1.0"><viewInfo viewMode="details" iconSize="16" stackIconSize="0" autoListFlags="0"><visibleColumns><column viewField="System.ItemNameDisplay"/><column viewField="System.ItemTypeText"/><column viewField="System.Size"/><column viewField="System.ItemFolderPathDisplayNarrow"/></visibleColumns><sortList><sort viewField="System.Search.Rank" direction="descending"/><sort viewField="System.ItemNameDisplay" direction="ascending"/></sortList></viewInfo><query><attributes/><kindList><kind name="item"/></kindList><scope>

)
Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n). 
{ 
  if InStr(FileExist(A_LoopField), "D")
	{
		searchString=%searchString%<include path="%A_LoopField%"/>
	}
} 
searchString.="</scope></query></persistedQuery>"
Fileappend,%searchString%, %a_scriptdir%\temp.search-ms 
SetDirectory(a_scriptdir "\temp.search-ms")
return
#if


; Alt+LButton Window dragging, slightly modified by Fragman

; This script modified from the original: http://www.autohotkey.com/docs/scripts/EasyWindowDrag.htm
; by The How-To Geek
; http://www.howtogeek.com
#if !MouseMinMaxRunning && GetKeyState("MButton","P")
WheelDown::MouseMin()
WheelUp::MouseMax()
#if
MouseMin()
{	
	global MouseMinMaxRunning
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	MouseMinMaxRunning:=true
	while(GetKeyState("MButton","P"))
		Sleep 20
	if(WinState = 0)
		PostMessage, 0x112, 0xF020,,, ahk_id %MouseWin% ;Winminimize, but apparently more reliable
	else
		WinRestore ahk_id %MouseWin%
	MouseMinMaxRunning:=false
}

MouseMax()
{
	global MouseMinMaxRunning
	MouseMinMaxRunning:=true
	MouseGetPos, , , MouseWin
	WinGet, WinState, MinMax, ahk_id %MouseWin%
	while(GetKeyState("MButton","P"))
		Sleep 20
	if(WinState = 0)
		WinMaximize ahk_id %MouseWin%
	MouseMinMaxRunning:=false
}

!LButton::EWD_StartDrag()
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
