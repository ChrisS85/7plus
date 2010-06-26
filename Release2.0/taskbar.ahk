IsMouseOverStartButton()
{
	MouseGetPos,,,win
	WinGetClass,class,ahk_id %win%
	return class="button"
}

GetTaskbarDirection()
{
	WinGetPos X, Y, Width, Height, ahk_class Shell_TrayWnd
	x:=(x+x+width)/2
	y:=(y+y+height)/2
	if(x<0.1*A_ScreenWidth)
		return 1
	if(x>0.9*A_ScreenWidth)
		return 2
	if(y<0.1*A_ScreenHeight)
		return 3
	if(y>0.9*A_ScreenHeight)
		return 4
	if(IsFullscreen("A",false,false))
		return -1
	return 0
}

IsMouseOverTaskList()
{
	WinGetPos , X, Y,,, ahk_class Shell_TrayWnd
	if(A_OSVersion="WIN_7")
		ControlGetPos , TaskListX, TaskListY, TaskListWidth, TaskListHeight, MSTaskListWClass1, ahk_class Shell_TrayWnd
	else
		ControlGetPos , TaskListX, TaskListY, TaskListWidth, TaskListHeight, MSTaskSwWClass1, ahk_class Shell_TrayWnd
	;Transform to screen coordinates
	TaskListX+=X
	TaskListY+=Y
	MouseGetPos,x,y
	z:=GetTaskBarDirection()
	if(z=2||z=4)
		return IsMouseOverTaskbar() && IsInArea(x,y,TaskListX,TaskListY,TaskListWidth,TaskListHeight)
	if(z=1||z=3)
		return IsMouseOverTaskbar() && IsInArea(x,y,TaskListX,TaskListY,TaskListWidth,TaskListHeight)
	return false
}

IsMouseOverTray()
{
	MouseGetPos,x,y
	ControlGetPos , TrayX, TrayX, TrayWidth, TrayHeight, ToolbarWindow321, ahk_class Shell_TrayWnd
	z:=GetTaskBarDirection()
	if(z=2||z=4)
		return IsMouseOverTaskbar() && IsInArea(x,y,TrayX,TrayY,TrayWidth,TrayHeight)
	if(z=1||z=3)
		return IsMouseOverTaskbar() && IsInArea(x,y,TrayX,TrayY,TrayWidth,TrayHeight)
	return false
}

IsMouseOverClock()
{
	MouseGetPos, , , , ControlUnderMouse   
  outputdebug control under mouse: %ControlUnderMouse%
  result:=false
  if(ControlUnderMouse="TrayClockWClass1")
		result:=true
	outputdebug IsMouseOverClock()? %result%
	return result
}

IsMouseOverShowDesktop()
{
	MouseGetPos,x,y
	z:=GetTaskBarDirection()
	ControlGetPos , ShowDesktopX, ShowDesktopY, ShowDesktopWidth, ShowDesktopHeight, TrayShowDesktopButtonWClass1, ahk_class Shell_TrayWnd
	if(z=2||z=4)
		return IsMouseOverTaskbar() && IsInArea(x,y,ShowDesktopX,ShowDesktopY,ShowDesktopWidth,ShowDesktopHeight)
	if(z=1||z=3)
		return IsMouseOverTaskbar() && IsInArea(x,y,ShowDesktopX,ShowDesktopY,ShowDesktopWidth,ShowDesktopHeight)
	return false
}

IsMouseOverTaskbar()
{
	MouseGetPos, , , WindowUnderMouseID 
  WinGetClass, winclass , ahk_id %WindowUnderMouseID%
  result:=false
  if(winclass="Shell_TrayWnd")
  	result:=true
	return result
}

IsMouseOverFreeTaskListSpace()
{
	global result,IsRunning
	SetWinDelay 0
	SetKeyDelay 0
	SetMouseDelay 0
	if(!IsMouseOverTaskList())
	{
		IsRunning:=false
		return false
	}
	if(A_OSVersion!="WIN_7")
	{
		x:=HitTest()
		outputdebug x %x%
		return x<0
	}
	IsRunning:=true
	Send {RButton}
	result:=0
	x:=0
	while(x<50)
	{
		if(WinExist("ahk_class #32768"))
		{
			result:=true
			outputdebug break
			break
		}
		else if(WinActive("ahk_id DV2ControlHost"))
		{
			result:=false
			outputdebug break
			break
		}
		outputdebug sleep %x%
		x+=10
		sleep 10
	}
	outputdebug return with %result% and send esc
	while(WinExist("ahk_class #32768")||WinActive("ahk_class DV2ControlHost"))
		Send {Esc}
	IsRunning:=false
	return %result%
}
