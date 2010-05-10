#if hwnd:=WinActive("ahk_group ExplorerGroup")
^t::CreateTab(hwnd)
#if
#if hwnd:=IsTabbedWindow(WinActive("ahk_group ExplorerGroup"))
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
	outputdebug window %window% tabWindow %TabWindow% control %control%
	if(window && window=TabWindow && strStartsWith(control,"Button"))
	{
		TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
		ControlGet, MouseHwnd, Hwnd,, %control%, ahk_id %window%
		if(TabContainer)
		{
			outputdebug start loop
			Loop % TabContainer.tabs.len()
			{
				hwnd:=TabContainer.tabs[A_Index]
				GuiControlGet, controlhwnd,%TabNum%:Hwnd,Tab%hwnd%
				outputdebug controlhwnd %controlhwnd% mousehwnd %mousehwnd%
				if(ControlHWND=MouseHWND)
				{
					return hwnd ;Returns hwnd associated to the tab
				}
			}
		}
	}
	return false
}
/*
 * Closes the tab hwnd (only called when window is about to close anyway)
*/
CloseTab(hwnd,TabContainer=0)
{
	global TabContainerList,TabNum
	DetectHiddenWindows, On	
	Folder:=GetCurrentFolder(hwnd)
	outputdebug close %hwnd% %folder%
	TabContainerList.print()
	if(!TabContainer)
		TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(!TabContainer)
	{
		Msgbox CloseTab():Tab Container not found!
		return
	}
	if(hwnd=TabContainerList.active)
		CycleTabs(hwnd,1)
	if(TabContainer.tabs.len()=2)
	{
		TabContainerList.Delete(TabContainerList.indexOf(TabContainer))
		TabContainerList.Active:=0
		Gui %TabNum%:Destroy
	}
	Else
		TabContainer.tabs.Delete(TabContainer.tabs.indexOf(hwnd))		
	DisableMinimizeAnim(1)
	WinClose ahk_id %hwnd%	
	DisableMinimizeAnim(0)
	outputdebug update closed
	UpdateTabs(1)
}
CreateTabWindow()
{
global
Critical
outputdebug CreateTabWindow()
/*
run, explorer,,,pid1
WinWait, ahk_pid %pid1%
hwnd:=WinExist("ahk_pid " pid1) + 0
WinHide, ahk_id %hwnd%
*/
TabNum:=3
Gui, %TabNum%:+LastFound +ToolWindow -Border -Resize -Caption +alwaysontop
 
Gui, %TabNum%: Color, FFFFFF
WinSet, TransColor, FFFFFF
TabWindow := WinExist()
UpdatePosition(TabNum, TabWindow)
Gui, %TabNum%:Show, NA
;Dock(c0, "T x(0,0,24) y(0,0,0) w(1,-135)")
Return
}

;Called when a TabButton was clicked
TabButton:
outputdebug -------------button click--------------
hwnd:=strTrimLeft(A_GuiControl, "Tab")
ActivateTab(hwnd)
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
		outputdebug set active
		OldTab:=TabContainer.active
		TabContainerList.active:=hwnd
		TabContainer.active:=hwnd
		
		if(TabContainer!=TabContainerOld)
		{
			outputdebug update activated
			UpdateTabs()
		}
		Else
			SetPressedButtonStyle(hwnd,OldTab)
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
	if(SuppressTabEvents)
		return
	hwnd:=WinExist("A")
	if(hwnd=TabWindow)
		return
	outputdebug ExplorerDeactivated(%hwnd%, %TabWindow%)
	outputdebug unset active
	TabContainerList.active:=0
	UpdatePosition(TabNum, TabWindow)
	;SetTimer, UpdatePosition, Off
}
ExplorerDestroyed(hwnd)
{
	global TabContainerList
	outputdebug ExplorerDestroyed()
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(!TabContainer)
		return
	CloseTab(hwnd,TabContainer)
	return
}
UpdatePosition(TabNum, TabWindow)
{
	global SuppressTabEvents, TabContainerList
	static gid=0   ;fid & gid are function id and global id. I use them to see if the function interupted itself. 
	/*
	if(SuppressTabEvents)
	{
		outputdebug update suppressed
		return
	}
	*/
	fid:=gid+=1
	;SuppressTabEvents:=true
	;outputdebug UpdatePosition(%TabNum%,%TabWindow%)
	hwnd:=WinActive("ahk_group ExplorerGroup")
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	class:=WinGetClass("A")
	if( hwnd && TabContainer)
	{
		;outputdebug show tabs
		WinGetPos, x,y,w,h,ahk_id %hwnd%
		;Update stored position so we can restore it if a tab is closed
		TabContainer.x := x
		TabContainer.y := y
		TabContainer.w := w
		TabContainer.h := h
		x+=24
		w-=135
		h:=30
		y:=max(y,0)
		if (fid != gid) 				;some newer instance of the function was running, so just return (function was interupted by itself). Without this, older instance will continue with old host window position and clients will jump to older location. This is not so visible with WinMove as it is very fast, but SetWindowPos shows this in full light. 
			return
		;DllCall("SetWindowPos", "uint", TabWindow, "uint", explorer, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 19 | 0x4000 | 0x40)
		WinMove ahk_id %TabWindow%,,%x%,%y%,%w%,%h%
		WinGet, style, style, ahk_id %TabWindow%
		if(!(style & 0x10000000))
		{
			outputdebug show
			Gui %TabNum%: Show, NA
		}
		;WinShow ahk_id %TabWindow%
	}
	else if (class && (class!="AutohotkeyGUI" || WinGet("minmax","ahk_id " TabContainerList.active)=-1))
	{
		WinGet, style, style, ahk_id %TabWindow%
		if(style & 0x10000000)
		{
			outputdebug hide %class%
			WinHide ahk_id %TabWindow%
		}
	}
	;SuppressTabEvents:=false
}

/*
 * Recreates Tab GUI
*/
UpdateTabs(force=0)
{
	global
	local TabContainer, hwnd,tabhwnd,folder,text
	Critical
	if(SuppressTabEvents)
		return
	SuppressTabEvents:=true
	hwnd:=WinActive("ahk_group ExplorerGroup")
	TabContainer:=TabContainerList.ContainsHWND(hwnd)
	if(hwnd && TabContainer)
	{
		if(!force)
		{
			recreate:=0
			Loop % TabContainer.tabs.len()
			{
				tabhwnd:=TabContainer.tabs[A_Index]
				folder:=GetCurrentFolder(tabhwnd,1)
				GuiControlGet, text,%tabnum%:,tab%tabhwnd%
				if(!text || !folder || text!=folder)
				{
					recreate:=1
					break
				}
			}
		}
		if(force || recreate)
		{
			outputdebug recreate gui
			;Recreate GUI since buttons aren't deleteable yet
			Gui %TabNum%:+LastFoundExist
			IfWinExist
				Gui %TabNum%:Destroy
			CreateTabWindow()
			;Loop over all tabs and create buttons for them
			Loop % TabContainer.tabs.len()
			{
				hwnd:=TabContainer.tabs[A_Index]
				AddTabButton(TabContainer,hwnd)
			}
		}
		SetPressedButtonStyle(TabContainer.active,0)
	}
	SuppressTabEvents:=false
}

/*
 * Marks the tab representing hwnd as active
*/
SetPressedButtonStyle(hwnd,OldTab)
{
	global
	outputdebug Setdefault button %hwnd% old: %OldTab%
	GuiControl, %TabNum%:+default, Tab%hwnd%	
	Gui, %TabNum%:Font, norm	
	GuiControl, %TabNum%:Font, Tab%OldTab%
	Gui, %TabNum%:Font, Underline
	GuiControl, %TabNum%:Font, Tab%hwnd%
}

/*
 * Cycles through tabs in order indicated by dir
*/
CycleTabs(hwnd,dir)
{
	global TabContainerList
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
		ActivateTab(TabContainer.tabs[pos])
	}
	Else
		msgbox tabcontainer is too small!
}
CreateTab(hwnd)
{
	global TabContainerList, TabContainerBase, SuppressTabEvents, TabNum, TabWindow
	Critical
	if(!hwnd)
	{
		Msgbox CreateTab(): No active tab!
		Return
	}
	SuppressTabEvents:=true
	DecToHex(hwnd)
	outputdebug CreateTab(%hwnd%)	
	TabContainerList.Print()
	if(!WinExist("ahk_id " TabWindow))
		CreateTabWindow()
	if(!TabContainer:=TabContainerList.ContainsHWND(hwnd)) ;Create new Tab Container if it doesn't exist yet
	{
		outputdebug ---------------------
		outputdebug add new tab container
		outputdebug ---------------------
		TabContainerBase := Object("tabs", Array(), "active", 0, "x", 0, "y", 0, "w", 0, "h", 0, "ContainsHWND", "TabContainer_ContainsHWND", "print", "TabContainer_Print")
		TabContainer:=Object("base",TabContainerBase)
		TabContainer.tabs.append(hwnd)
		TabContainer.active:=hwnd
		TabContainerList.append(TabContainer)
		AddTabButton(TabContainer, hwnd)
	}
	DetectHiddenWindows, On
	DisableMinimizeAnim(1)
	
	Run %A_WinDir%\explorer.exe 
	WinWaitNotActive ahk_id %hwnd%
	WinWaitNotActive ahk_id %TabWindow%	
	WinWaitNotActive ahk_id %hwnd%
	
	Loop ;Make sure new window is really active
	{ 
        Sleep 10 
        WinGet,PID2,PID, A 
        hwndnew := WinActive("ahk_group ExplorerGroup") 	
		TabContainerList.active:=hwndnew		;Set it to avoid ExplorerActivated function
		outputdebug 1st loop %hwndnew% %hwnd%
        If (hwndnew <> hwnd ) 
           Break 
    }
	Loop ;Wait until new window is visible
	{
		Sleep 10
		WinGet,visible,style, ahk_id %hwndnew%
		if(visible & 0x10000000)
			break
	}
	Loop ;and hide it until it is invisible again
	{
		Sleep 10
		WinGet,visible,style, ahk_id %hwndnew%
		WinGetPos,x,y,w,h,ahk_id %hwndnew%
		outputdebug 2nd loop x%x% y%y% w%w% h%h%
		if(visible & 0x10000000)
		{
			outputdebug hide
			WinHide ahk_id %hwndnew%
		}
		Else
			break
	}
	outputdebug hide tab %hwndnew%
	
	DisableMinimizeAnim(0)
	WinGetPos x,y,w,h,ahk_id %hwnd%
	WinMove ahk_id %hwndnew%,,%x%,%y%,%w%,%h%
	TabContainerList.active:=hwnd 	;Set it to avoid ExplorerActivated function
	WinActivate ahk_id %hwnd%
	TabContainer.tabs.append(hwndnew) ;Add new tab to list
	AddTabButton(TabContainer, hwndnew)
	TabContainerList.Print()
	SuppressTabEvents:=false
	UpdatePosition(TabNum, TabWindow)
}
AddTabButton(TabContainer, hwnd)
{
	global
	local name
	name := GetCurrentFolder(hwnd,1)
	Gui, %TabNum%:add, button, y0 vTab%hwnd% gTabButton , %name%
}
ActivateTab(hwnd)
{
	global TabContainerList, SuppressTabEvents
	Critical
	outputdebug ActivateTab(%hwnd%)
	if(TabContainer:=TabContainerList.ContainsHWND(hwnd))
	{		
		DisableMinimizeAnim(1)
		SuppressTabEvents:=true
		OldTab:=TabContainer.active
		x:=TabContainer.x
		y:=TabContainer.y
		w:=TabContainer.w
		h:=TabContainer.h
		WinHide, ahk_id %OldTab%
		WinMove ahk_id %hwnd%,,%x%,%y%,%w%,%h%
		WinShow, ahk_id %hwnd%
		WinActivate, ahk_id %hwnd%
		TabContainer.active:=hwnd
		TabContainerList.active:=hwnd
		SetPressedButtonStyle(hwnd,OldTab)
		SuppressTabEvents:=false	
		DisableMinimizeAnim(0)		
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
      , "extend", "Array_Extend", "copy", "Array_Copy", "pop", "Array_Pop", "ContainsHWND", "TabContainerList_ContainsHWND","Print","TabContainerList_Print", "active", 0) 
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
	outputdebug Active: %active%
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