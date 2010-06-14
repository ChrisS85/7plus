#if UseTabs && hwnd:=WinActive("ahk_group ExplorerGroup")
^t::CreateTab(hwnd)
#if
#if UseTabs && hwnd:=IsTabbedWindow(WinActive("ahk_group ExplorerGroup"))
^Tab Up::CycleTabs(hwnd,1)
^+Tab Up::CycleTabs(hwnd,-1)
^w::CloseTab(TabContainerList.active)
#if
#t::TabContainerList.Print()

IsTabbedWindow(hwnd)
{
	global TabContainerList
	if(TabContainerList.active && TabContainerList.active=hwnd)
		return hwnd
	return false
}
IsMouseOverTabButton()
{
	global
	local window,control,TabContainer,MouseHwnd,hwnd,controlhwnd
	MouseGetPos,,,window, control
	if(window && window=TabWindow && strStartsWith(control,"Tab"))
	{
		TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
		ControlGet, MouseHwnd, Hwnd,, %control%, ahk_id %window%
		if(TabContainer)
		{
			Loop % TabContainer.tabs.len()
			{
				hwnd:=TabContainer.tabs[A_Index]
				GuiControlGet, controlhwnd,%TabNum%:Hwnd,Tab%hwnd%
				if(ControlHWND=MouseHWND)
					return hwnd ;Returns hwnd associated to the tab
			}
		}
	}
	return false
}
MouseCloseTab()
{	
	global TabClose
	TabClose:=true
	SetTimer, CheckActiveTabClose,-30 ;Start a timer to see if user tries to close active tab, since it doesn't fire an event
	Send {LButton}
}
CheckActiveTabClose:
if(TabClose)
	GoSub TabEvent
return

/*
 * Closes the tab hwnd (only called when window is about to close anyway)
*/
CloseTab(hwnd,TabContainer=0)
{
	global TabContainerList,TabNum, NoTabUpdate, OnTabClose
	DetectHiddenWindows, On	
	NoTabUpdate:=true
	Folder:=GetCurrentFolder(hwnd)
	outputdebug close %hwnd% %folder%
	TabContainerList.print()
	if(!TabContainer)
		TabContainer:=TabContainerList.ContainsHWND(hwnd)
		
	if(hwnd=TabContainerList.active)
	{	
		if(OnTabClose=1)
			CycleTabs(hwnd,-1)
		else if(OnTabClose=2)
			CycleTabs(hwnd,1)
	}
	if(!TabContainer)
	{
		Msgbox CloseTab():Tab Container not found!
		return
	}
	if(TabContainer.tabs.len()=2)
	{
		TabContainerList.Delete(TabContainerList.indexOf(TabContainer))
		TabContainerList.Active:=0
		Gui %TabNum%:Hide
		;Gui %TabNum%:Destroy
	}
	Else
		TabContainer.tabs.Delete(TabContainer.tabs.indexOf(hwnd))			
	DisableMinimizeAnim(1)
	WinClose ahk_id %hwnd%	
	DisableMinimizeAnim(0)
	outputdebug update closed
	NoTabUpdate:=false
	UpdateTabs()
}

CreateTabWindow()
{
global
local backup
;Critical
backup:=SuppressTabEvents
SuppressTabEvents:=true
TabNum:=3
Gui, %TabNum%:+LastFound +ToolWindow -Border -Resize +alwaysontop
Gui, %TabNum%:Add,Tab2, +Theme -Wrap x0 w2000 h20 HwndTabHWND vTabControl gTabEvent +AltSubmit, %A_Space%
Gui, %TabNum%:Show , NA x50 y50
TabWindow := WinExist()
WinGetPos,x,y,w,h, ahk_id %TabHWND%
x:=x+500 ;This method is not very reliable, as there might be painting issues outside of the screen!
y:=y+h-2
PixelGetColor,TabColor,%x%,%y%,RGB
Gui, %TabNum%: Color, %TabColor%
WinSet, TransColor, %TabColor%
Gui, %TabNum%:-Caption
SuppressTabEvents:=false
GuiControl, %TabNum%:MoveDraw, TabControl
DllCall("InvalidateRect",UInt, TabWindow, UInt, 0, UInt, 1)
UpdateTabs()
UpdatePosition(TabNum, TabWindow)
SuppressTabEvents:=backup
;Dock(c0, "T x(0,0,24) y(0,0,0) w(1,-135)")
;Critical, Off
Return
}

;Called when a tab is activated
TabEvent:
outputdebug activate tab %TabControl%, previous exp window is %hwnd%
NoTabUpdate:=true
OldTab:=TabControl
Gui, %TabNum%:Submit
if(TabClose)
{	
	TabClose:=false
	hwnd:=TabContainerList.Active
	class:=WinGetClass("ahk_id " hwnd)
	TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
	CloseTab(TabContainer.tabs[TabControl],TabContainer)
	outputdebug current tab: %class%
	WinActivate ahk_id %hwnd%
}
else
	ActivateTab(TabControl)
NoTabUpdate:=false
UpdateTabs()
return

ExplorerActivated(hwnd)
{
	global TabContainerList, TabNum, TabWindow,SuppressTabEvents
	if(SuppressTabEvents)
		return
	if(TabContainerList.active=hwnd) ;If active hwnd is set to this window already, activation shall be handled elsewhere
		return
	DecToHex(hwnd)
	outputdebug ExplorerActivated(%hwnd%)
	if(TabContainer:=TabContainerList.ContainsHWND(hwnd))
	{
		TabContainerOld:=TabContainerList.ContainsHWND(TabContainerList.active)
		;outputdebug set active
		OldTab:=TabContainer.active
		TabContainerList.active:=hwnd
		TabContainer.active:=hwnd
		
		if(TabContainer!=TabContainerOld)
		{
			outputdebug update activated
			UpdateTabs()
		}
		UpdatePosition(TabNum, TabWindow)
		
		;SetTimer, UpdatePosition, 100
	}
}
/*
ExplorerDeactivated:
ExplorerDeactivated()
return
*/
ExplorerDeactivated(hwnd)
{
	global TabContainerList, TabNum, TabWindow,SuppressTabEvents
	outputdebug ExplorerDeactivated1(%hwnd%, %TabWindow%)
	if(SuppressTabEvents)
		return
	outputdebug ExplorerDeactivated2(%hwnd%, %TabWindow%)
	hwnd:=WinExist("A")
	if(hwnd=TabWindow)
		return
	outputdebug ExplorerDeactivated3(%hwnd%, %TabWindow%)
	if(hwnd!=TabWindow)
	{
		outputdebug clear active
		TabContainerList.active:=0
	}
	UpdatePosition(TabNum, TabWindow)
	;SetTimer, UpdatePosition, Off
}
ExplorerDestroyed(hwnd)
{
	global TabContainerList,TabWindowClose
	outputdebug ExplorerDestroyed()
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(!TabContainer)
		return
	if(TabWindowClose = 0)
		CloseTab(hwnd,TabContainer)
	else if(TabWindowClose = 1)
		TabContainer.CloseAllTabs()
	return
}
TabContainerList_CloseAllInactiveTabs(TabContainerList)
{
	Critical
	len := TabContainerList.len()
	loop %len% ;Fixed length for delete loop
	{
		TabContainer := TabContainerList[1]
		TabContainer.CloseInactiveTabs()
	}
}
TabContainer_CloseInactiveTabs(TabContainer)
{
	global TabContainerList
	Critical
	TabContainerList.Delete(TabContainerList.indexOf(TabContainer))
	DetectHiddenWindows, On
	loop % TabContainer.tabs.len()
	{
		hwnd := TabContainer.tabs[A_Index]
		if(hwnd!=TabContainer.active)
			WinClose, ahk_id %hwnd%
	}
}
TabContainer_CloseAllTabs(TabContainer)
{
	global TabContainerList
	Critical
	NoTabUpdate:=true
	SuppressTabEvents:=true
	outputdebug close all tabs
	TabContainerList.Print()
	index:=TabContainerList.indexOf(TabContainer)
	TabContainerList.Delete(index)
	outputdebug index %index%
	outputdebug after deletion:
	TabContainerList.Print()
	DetectHiddenWindows, On
	loop % TabContainer.tabs.len()
	{
		hwnd := TabContainer.tabs[A_Index]
		WinClose, ahk_id %hwnd%
	}	
	NoTabUpdate:=false
	SuppressTabEvents:=false
}
/*
TabContainerList_indexOf(TabContainerList,TabContainer)
{
	Loop % TabContainerList.len()
	{
		tc:=TabContainerList[A_Index]
		if(tc.ContainsHWND(TabContainer.active))
			return A_Index
	}
}
*/
UpdatePosition(TabNum, TabWindow)
{
	global SuppressTabEvents, TabContainerList, TabControl, NoTabUpdate
	static gid=0   ;fid & gid are function id and global id. I use them to see if the function interupted itself. 
	SetWinDelay -1
	/*
	if(SuppressTabEvents)
	{
		outputdebug update suppressed
		return
	}
	*/
	if(NoTabUpdate)
		return
	fid:=gid+=1
	;SuppressTabEvents:=true
	hwnd:=WinActive("ahk_group ExplorerGroup")
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	class:=WinGetClass("A")
	if( hwnd && TabContainer)
	{
		;Get restored-state coordinates
		WinGetPlacement(hwnd,x,y,w,h)
		;Update stored position so we can restore it if a tab is closed		
		WinGet, state, minmax, ahk_id %hwnd%
		TabContainer.state := state
		TabContainer.x := x
		TabContainer.y := y
		TabContainer.w := w
		TabContainer.h := h
		;Now get current coordinates for tab window placement
		WinGetPos, x,y,w,h,ahk_id %hwnd%
		x+=24
		w-=135
		h:=30
		;if(w=25) ;Strange fix for restore from minimize causing too small sizing until next update
		; 	return
		
		;y:=max(y,0)
		if (fid != gid) 				;some newer instance of the function was running, so just return (function was interupted by itself). Without this, older instance will continue with old host window position and clients will jump to older location. This is not so visible with WinMove as it is very fast, but SetWindowPos shows this in full light. 
			return
		;DllCall("SetWindowPos", "uint", TabWindow, "uint", explorer, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 19 | 0x4000 | 0x40)
		;WinSetPlacement(TabWindow,x,y,w,h,1)
		WinMove, ahk_id %TabWindow%,,%x%,%y%,%w%,%h%
		;outputdebug updateposition() tab control: w%w%
		GuiControl, %TabNum%:Move, TabControl, w%w%
		WinGet, style, style, ahk_id %TabWindow%
		if(!(style & 0x10000000))
		{
			outputdebug show
			Gui %TabNum%: Show, NA
		}
		;WinShow ahk_id %TabWindow%
	}
	else if (class && (WinExist("A")!=TabWindow || WinGet("minmax","ahk_id " TabContainerList.active)=-1))
	{
		WinGet, style, style, ahk_id %TabWindow%
		if(style & 0x10000000)
		{
			outputdebug hide %class% id %TabWindow%
			WinHide ahk_id %TabWindow%
		}
	}
	;SuppressTabEvents:=false
}

/*
 * Recreates Tabs
*/
UpdateTabs()
{
	global
	local TabContainer, hwnd,tabhwnd,folder,tabs
	Critical
	if(SuppressTabEvents)
		return
	if(NoTabUpdate)
		return
	SuppressTabEvents:=true
	hwnd:=WinActive("ahk_group ExplorerGroup")
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(hwnd && TabContainer)
	{
		tabs:="|"
		Loop % TabContainer.tabs.len()
		{
			if(TabContainerList.Active = TabContainer.tabs[A_Index])
				tabs .= GetCurrentFolder(TabContainer.tabs[A_Index],1) "||"
			else
				tabs .= GetCurrentFolder(TabContainer.tabs[A_Index],1) "|"
		}
		if(!strEndsWith(tabs,"||"))
			tabs:=strStripRight(tabs,"|")
		GuiControl, %TabNum%:,TabControl,%tabs%
	}
	SuppressTabEvents:=false
}

/*
 * Cycles through tabs in order indicated by dir
*/
CycleTabs(hwnd,dir)
{
	global TabContainerList
	SetWinDelay,-1
	DecToHex(hwnd)
	outputdebug cycletabs %hwnd%
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(!TabContainer)
		msgbox CycleTabs():Tab container not found!
	if(TabContainer.tabs.len()>1)
	{
		pos:=TabContainer.ContainsHWND(TabContainer.active)
		pos+=dir
		if(pos<1)
			pos+=TabContainer.tabs.len()
		Else if(pos>TabContainer.tabs.len())
			pos-=TabContainer.tabs.len()
		outputdebug activate tab %pos%
		ActivateTab(pos)
	}
	Else
		msgbox tabcontainer is too small!
}
CreateTab(hwnd,path=-1,Activate=-1)
{
	global TabContainerList, TabContainerBase, SuppressTabEvents, TabNum, TabWindow,TabControl,TabStartupPath,ActivateTab,NewTabPosition
	Critical
	hwnd:=hwnd ? hwnd : WinActive("ahk_group ExplorerGroup")
	if(!hwnd)
	{
		Msgbox CreateTab(): No active tab!
		Return
	}
	Activate := Activate = -1 ? ActivateTab : Activate
	path := path = -1 ? TabStartupPath : path
	if(path="")
		path:=GetCurrentFolder(hwnd)
	SuppressTabEvents:=true
	DecToHex(hwnd)
	outputdebug CreateTab(%hwnd%)	
	TabContainerList.Print()
	if(!TabContainer:=TabContainerList.ContainsHWND(hwnd)) ;Create new Tab Container if it doesn't exist yet
	{
		outputdebug ---------------------
		outputdebug add new tab container
		outputdebug ---------------------
		TabContainerBase := Object("tabs", Array(), "active", 0, "x", 0, "y", 0, "w", 0, "h", 0,"state",0
		, "CloseAllTabs", "TabContainer_CloseAllTabs", "CloseInactiveTabs", "TabContainer_CloseInactiveTabs"
		, "ContainsHWND", "TabContainer_ContainsHWND", "print", "TabContainer_Print")
		TabContainer:=Object("base",TabContainerBase)
		TabContainer.tabs.append(hwnd)
		TabContainer.active:=hwnd
		TabContainerList.append(TabContainer)
		;UpdateTabs()
	}
	DetectHiddenWindows, On
	DisableMinimizeAnim(1)	
	;msgbox tab path: %path%
	;msgbox A_ProgramFiles: %A_ProgramFiles%
	Run(A_WinDir "\explorer.exe /n,/e," path)
	;Run, Explore %path%
	WinWaitNotActive ahk_id %hwnd%
	WinWaitNotActive ahk_id %TabWindow%	
	WinWaitNotActive ahk_id %hwnd%
	
	Loop ;Make sure new window is really active
	{ 
        Sleep 10 
        hwndnew := WinActive("ahk_group ExplorerGroup")
		if(hwndnew)
		{
			TabContainerList.active:=hwndnew		;Set it to avoid ExplorerActivated function
			outputdebug 1st loop %hwndnew% %hwnd%
			If (hwndnew <> hwnd )
			   Break 
		}
    }
	Loop ;Wait until new window is visible
	{
		Sleep 10
		WinGet,visible,style, ahk_id %hwndnew%
		if(visible & 0x10000000)
			break
	}
	if(!Activate)
	{
		Loop ;and hide it until it is invisible again
		{
			Sleep 10
			WinGet,visible,style, ahk_id %hwndnew%
			WinGetPos,x,y,w,h,ahk_id %hwndnew%
			outputdebug 2nd loop x%x% y%y% w%w% h%h%
			if(visible & 0x10000000) ;WS_VISIBLE
			{
				outputdebug hide style %visible% title %title%
				WinHide ahk_id %hwndnew%
			}
			Else
				break
		}		
		outputdebug hide tab %hwndnew%
	}
	
	DisableMinimizeAnim(0)
	WinGetPlacement(hwnd,x,y,w,h,state)
	WinSetPlacement(hwndnew,x,y,w,h,state)
	if(!Activate)
		WinHide ahk_id %hwndnew% ;Hide again because WinSetPlacement unhides it, but is required for max/restore state
	
	;WinMove ahk_id %hwndnew%,,%x%,%y%,%w%,%h%
	;if(state = 1)
	;	WinMaximize ahk_id %hwndnew%
	if(!Activate)
	{
		TabContainerList.active:=hwnd 	;Set it to avoid ExplorerActivated function
		WinActivate ahk_id %hwnd%
	}
	Else
	{
		TabContainerList.active:=hwndnew
		TabContainer.active:=hwndnew
		WinHide ahk_id %hwnd%
		outputdebug hide old tab
	}
	if(NewTabPosition=1)
		TabContainer.tabs.insert(TabContainer.tabs.indexOf(hwnd)+1,hwndnew) ;Add new tab to list
	else if(NewTabPosition=2)
		TabContainer.tabs.append(hwndnew) ;Add new tab to list
		
	;AddTabButton(TabContainer, hwndnew)
	TabContainerList.Print()
	DetectHiddenWindows, Off
	if(!WinExist("ahk_id " TabWindow))
		Gui %TabNum%:Show, NA
	SuppressTabEvents:=false	
	UpdateTabs()
	UpdatePosition(TabNum, TabWindow)
	GuiControl, %TabNum%:MoveDraw, TabControl
}


ActivateTab(pos)
{
	global TabContainerList, SuppressTabEvents
	Critical
	outputdebug ActivateTab(%pos%)
	SetWinDelay,-1
	if(TabContainer:=TabContainerList.ContainsHWND(TabContainerList.Active))
	{		
		hwnd:=TabContainer.tabs[pos]
		DisableMinimizeAnim(1)
		SuppressTabEvents:=true
		OldTab:=TabContainer.active
		x:=TabContainer.x
		y:=TabContainer.y
		w:=TabContainer.w
		h:=TabContainer.h
		state:=TabContainer.state
		WinHide, ahk_id %OldTab%
		DetectHiddenWindows, On
		if(w!=0)
		{
			path:=GetCurrentFolder(hwnd)
			outputdebug move window %path% to:
			TabContainer.print()
			if(state=1)
				WinSetPlacement(hwnd,x,y,w,h,3)
			else
				WinSetPlacement(hwnd,x,y,w,h,1)
			;WinMove ahk_id %hwnd%,,%x%,%y%,%w%,%h%
		}
		/*
		if(state = 1)
			WinMaximize ahk_id %hwnd%
		else if(state = 0)
			WinRestore ahk_id %hwnd%
			*/
		WinShow, ahk_id %hwnd%
		WinActivate, ahk_id %hwnd%
		TabContainer.active:=hwnd
		TabContainerList.active:=hwnd
		SuppressTabEvents:=false	
		DisableMinimizeAnim(0)
		UpdateTabs()
	}
	Else
	{
		MsgBox Activating invalid tab!
	}
}
;Slide Window array constructor with some additional functions
TabContainerList(p1="N", p2="N", p3="N", p4="N", p5="N", p6="N"){ 
   static TabContainerList
   If !TabContainerListBase
      TabContainerListBase := Object("len", "Array_Length", "indexOf", "Array_indexOf", "join", "Array_Join" 
      , "append", "Array_Append", "insert", "Array_Insert", "delete", "Array_Delete" 
      , "sort", "Array_sort", "reverse", "Array_Reverse", "unique", "Array_Unique" 
      , "extend", "Array_Extend", "copy", "Array_Copy", "pop", "Array_Pop", "ContainsHWND", "TabContainerList_ContainsHWND"
	  , "CloseAllInactiveTabs", "TabContainerList_CloseAllInactiveTabs", "Print","TabContainerList_Print"
	  , "active", 0) 
   TabContainerList := Object("base", TabContainerListBase) 
   While (_:=p%A_Index%)!="N" && A_Index<=6 
      TabContainerList[A_Index] := _ 
   Return TabContainerList 
}
TabContainer_ContainsHWND(TabContainer,hwnd)
{
	;DecToHex(hwnd)
	return TabContainer.tabs.IndexOf(hwnd)
}
TabContainer_Print(TabContainer)
{
	active:=TabContainer.active
	x:=TabContainer.x
	y:=TabContainer.y
	w:=TabContainer.w
	h:=TabContainer.h
	state:=TabContainer.state
	outputdebug Active: %active%
	outputdebug state: %state%
	outputdebug x: %x%
	outputdebug y: %y%
	outputdebug w: %w%
	outputdebug h: %h%
	Loop % TabContainer.tabs.len()
	{
		path:=GetCurrentFolder(TabContainer.tabs[A_Index])
		hwnd:=TabContainer.tabs[A_Index]
		outputdebug %A_Tab%%A_Index% %hwnd%: %path%
	}
}
TabContainerList_ContainsHWND(TabContainerList,hwnd)
{
	;DecToHex(hwnd)
	;outputdebug TabContainerList_ContainsHWND(%hwnd%)
	Loop % TabContainerList.len()
	{		
		TabContainer:=TabContainerList[A_Index]
		if(TabContainer.ContainsHWND(hwnd))
		{	
			return TabContainer
		}
	}
	return false
}
TabContainerList_Print(TabContainerList)
{
	outputdebug --------------------------------------------
	active:=TabContainerList.active
	outputdebug Active: %active%
	count:=TabContainerList.len()
	outputdebug tab container count: %count%
	loop % TabContainerList.len()
	{
		count:=TabContainerList[A_Index].tabs.len()
		outputdebug %A_Index%: %count% entries
		TabContainerList[A_Index].Print()
	}
	outputdebug --------------------------------------------
}