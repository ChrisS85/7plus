#if UseTabs && hwnd:=WinActive("ahk_group ExplorerGroup")
^t::CreateTab(hwnd)
#if
#if UseTabs && hwnd:=IsTabbedWindow(WinActive("ahk_group ExplorerGroup"))
^Tab Up::CycleTabs(hwnd,1)
^+Tab Up::CycleTabs(hwnd,-1)
^w::CloseTab(TabContainerList.active)
#if
;#t::TabContainerList.Print()
#if UseTabs && IsMouseOverTabButton()
LButton::MouseActivateTab()
MButton::MouseCloseTab()
#if
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
	local window,TabContainer,x,y
	CoordMode, Mouse, Screen
	MouseGetPos,x,y,window
	if(window && window=TabWindow)
	{
		WinGetPos,WinX,WinY,,,ahk_id %TabWindow%
		;Tab Coords are relative
		x-=WinX
		y-=WinY
		outputdebug correct window x%x% y%y%
		TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
		if(TabContainer)
		{
			outputdebug tab container
			Loop % TabContainer.tabs.len()
			{
				if(IsInArea(x,y,TabContainer.tabs[A_Index].x,TabContainer.tabs[A_Index].y,TabContainer.tabs[A_Index].width,TabContainer.tabs[A_Index].height))
					return A_Index
			}
			outputdebug not found
		}
	}
	return false
}

MouseActivateTab()
{
	global TabContainerList
	TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
	index := IsMouseOverTabButton()
	if(index && TabContainer && TabContainer.tabs[index].hwnd != TabContainer.active)
		ActivateTab(index)
}
MouseCloseTab()
{	
	global TabContainerList
	TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
	index := IsMouseOverTabButton()
	if(index)
		CloseTab(TabContainer.tabs[index].hwnd)
	return index > 0
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
		outputdebug hide single tab
		;Gui %TabNum%:Destroy
	}
	Else
		TabContainer.tabs.Delete(TabContainer.ContainsHWND(hwnd))
	WinMove, ahk_id %hwnd%,,-10000,-10000
	WinClose ahk_id %hwnd%	
	outputdebug update closed
	NoTabUpdate:=false
	UpdateTabs()
}
DrawTabWindow()
{
	global TabContainerList,TabWindow
	TabContainerList.print()
	TabContainer:=TabContainerList.ContainsHWND(TabContainerList.active)
	if(TabContainer)
	{
		WinGetPos x,y,w,h,ahk_id %TabWindow%
		count:=TabContainer.tabs.len()
		desiredwidth:=0
		loop % count
		{
			desiredwidth += TabContainerList.TabWidth
			totalpadding += 2*TabContainerList.hPadding
		}
		if(desiredwidth + totalpadding > w)
		{
			scale := max((w-totalpadding),0)/desiredwidth
			Loop % count
			{
				TabContainer.tabs[A_Index].width := floor(TabContainerList.TabWidth * scale)
				CalculateTabText(TabContainer.tabs[A_Index])
			}
		}
		else
		{
			Loop % count
			{
				TabContainer.tabs[A_Index].width := TabContainerList.TabWidth
				CalculateTabText(TabContainer.tabs[A_Index])
			}
		}
		CalculateHorizontalTabPositions(TabContainer)
		; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
		hbm := CreateDIBSection(w, h)

		; Get a device context compatible with the screen
		hdc := CreateCompatibleDC()

		; Select the bitmap into the device context
		obm := SelectObject(hdc, hbm)

		; Get a pointer to the graphics of the bitmap, for use with drawing functions
		G := Gdip_GraphicsFromHDC(hdc)
		
		Font := TabContainerList.Font
		FontSize:=TabContainerList.FontSize
		
		; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
		Gdip_SetSmoothingMode(G, 4)

		; Create brushes
		pBrushActive := Gdip_BrushCreateSolid(0xFFFAFAFA)
		;Create pen for border liens
		pPenBorder := Gdip_CreatePen(0xFF808080, 1)
		;Draw all tabs
		Loop % TabContainer.tabs.len()
		{
			tab := TabContainer.tabs[A_Index]
			Gdip_SetSmoothingMode(G, 4)
			; Draw background
			if(tab.hwnd = TabContainer.active)
				Gdip_FillRectangle(G, pBrushActive, tab.x, tab.y, tab.width, tab.height)
			else
			{
				if(Vista7)
					pBrushGradient := Gdip_CreateLineBrushFromRect(0,0, tab.width, tab.height, 0xFFF8F8F8, 0x22222222)
				else
					pBrushGradient := Gdip_CreateLineBrushFromRect(0,0, tab.width, tab.height, 0xFFF8F8F8, 0xFFAAAAAA)
				Gdip_FillRectangle(G, pBrushGradient, tab.x, tab.y, tab.width, tab.height)
				Gdip_DeleteBrush(pBrushGradient)
			}
			Gdip_SetSmoothingMode(G, 1)
			Gdip_DrawLine(G, pPenBorder, tab.x, tab.y, tab.x+tab.width, tab.y)
			Gdip_DrawLine(G, pPenBorder, tab.x, tab.y, tab.x, tab.y+tab.height)
			Gdip_DrawLine(G, pPenBorder, tab.x+tab.width, tab.y, tab.x+tab.width, tab.y+tab.height)
			Gdip_SetSmoothingMode(G, 4)
			
			Gdip_TextToGraphics(G, tab.drawtext, "x" (tab.x+TabContainerList.hPadding) " y" TabContainerList.vPadding " cff000000 r5 Centre s" FontSize, Font,tab.width - 2*TabContainerList.hPadding,tab.height)
		}
		UpdateLayeredWindow(TabWindow, hdc, x, y, w, h)
		
		; Delete the brush as it is no longer needed and wastes memory
		Gdip_DeleteBrush(pBrushActive)
		Gdip_DeletePen(pPenBorder)
		; Select the object back into the hdc
		SelectObject(hdc, obm)
		
		; Now the bitmap may be deleted
		DeleteObject(hbm)

		; Also the device context related to the bitmap may be deleted
		DeleteDC(hdc)

		; The graphics may now be deleted
		Gdip_DeleteGraphics(G)
	}
}
TabContainer_Add(TabContainer,hwnd,position="")
{
	global TabContainerList
	outputdebug TabContainer_Add(TabContainer,%hwnd%,%position%)
	tab := Object("hwnd",hwnd)
	tab.path := GetCurrentFolder(hwnd)
	CalculateTabText(tab)
	tab.y := TabContainerList.InActiveHeightDifference
	tab.height := TabContainerList.height - TabContainerList.InActiveHeightDifference
	if(position="")
	{
		TabContainer.tabs.append(tab)
		CalculateHorizontalTabPositions(TabContainer,TabContainer.tabs.len())
	}
	else
	{
		TabContainer.tabs.insert(position,tab)
		CalculateHorizontalTabPositions(TabContainer,position)
	}
}

CalculateHorizontalTabPositions(TabContainer,start=1)
{
	i:=start
	if(start>1)
		x:=TabContainer.tabs[start-1].x+TabContainer.tabs[start-1].width
	else
		x:=0
	Loop
	{
		if(i>TabContainer.tabs.len())
			break
		TabContainer.tabs[i].x:=x
		x+=TabContainer.tabs[i].width
		i++
	}
}
CalculateVerticalTabPosition(TabContainer,index)
{
	global TabContainerList
	tab := TabContainer.tabs[index]
	if(tab)
	{
		if(tab.hwnd = TabContainer.active)
		{
			tab.y := 0
			tab.height := TabContainerList.height
		}
		else
		{
			tab.y := TabContainerList.InActiveHeightDifference
			tab.height := TabContainerlist.height - TabContainerList.InActiveHeightDifference
		}
	}
}
CalculateTabText(tab)
{
	global TabWindow,TabContainerList
	WinGetPos x,y,w,h,ahk_id %TabWindow%
	
	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm := CreateDIBSection(w, h)

	; Get a device context compatible with the screen
	hdc := CreateCompatibleDC()

	; Select the bitmap into the device context
	obm := SelectObject(hdc, hbm)

	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G := Gdip_GraphicsFromHDC(hdc)
	
	Font := TabContainerList.Font
	FontSize:=TabContainerList.FontSize
			
	;Measure the spaces
	RectF:=Gdip_TextToGraphics(G, tab.path, " s" FontSize " r4", Font,"","",1)
	StringSplit, RectF, RectF, |
	DrawText := tab.path
	drawcharcount := strlen(tab.path)
	while(RectF3 > (tab.width-2*TabContainerList.hPadding))
	{
		oldcount := drawcharcount
		drawcharcount := max(min(oldcount-1,floor(strlen(tab.path) * (Tab.Width -2*TabContainerList.hPadding)/ RectF3)),0)
		if(drawcharcount = 0)
		{
			drawtext := ""
			break
		}
		drawtext := SubStr(tab.path,1, drawcharcount) "..."		
		RectF:=Gdip_TextToGraphics(G, drawtext, " s" FontSize " r4", Font,"","",1)
		StringSplit, RectF, RectF, |
	}
	tab.DrawText := drawtext
	; Select the object back into the hdc
	SelectObject(hdc, obm)
	
	; Now the bitmap may be deleted
	DeleteObject(hbm)

	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc)

	; The graphics may now be deleted
	Gdip_DeleteGraphics(G)
	
	
}
CreateTabWindow()
{
	global
	local backup
	;Critical
	outputdebug Create tab window
	backup:=SuppressTabEvents
	SuppressTabEvents:=true
	TabNum:=3
	Gui, %TabNum%:+LastFound +ToolWindow -Border -Resize +alwaysontop -Caption +E0x80000	
	TabWindow := WinExist()
	/*
	Gui, %TabNum%:Add,Tab2, +Theme -Wrap x0 w2000 h20 HwndTabHWND vTabControl gTabEvent +AltSubmit, %A_Space%
	Gui, %TabNum%:Show , NA x50 y50
	WinGetPos,x,y,w,h, ahk_id %TabHWND%
	x:=x+500 ;This method is not very reliable, as there might be painting issues outside of the screen!
	y:=y+h-2
	PixelGetColor,TabColor,%x%,%y%,RGB
	Gui, %TabNum%: Color, %TabColor%
	WinSet, TransColor, %TabColor%
	Gui, %TabNum%:-Caption
	*/
	SuppressTabEvents:=false
	;GuiControl, %TabNum%:MoveDraw, TabControl
	;DllCall("InvalidateRect","Ptr", TabWindow, UInt, 0, UInt, 1)
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

TabContainerList_CloseAllInactiveTabs(TabContainerList)
{
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
	TabContainerList.Delete(TabContainerList.indexOf(TabContainer))
	DetectHiddenWindows, On
	loop % TabContainer.tabs.len()
	{
		hwnd := TabContainer.tabs[A_Index].hwnd
		if(hwnd!=TabContainer.active)
			WinClose, ahk_id %hwnd%
	}
}
TabContainer_CloseAllTabs(TabContainer)
{
	global TabContainerList
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
		hwnd := TabContainer.tabs[A_Index].hwnd
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
		changed := wTabContainer.x != x || TabContainer.y != y || TabContainer.w != w || TabContainer.h != h || TabContainer.state != state
		changedsize := TabContainer.w != w || TabContainer.h != h
		if(changed)
		{
			TabContainer.state := state
			TabContainer.x := x
			TabContainer.y := y
			TabContainer.w := w
			TabContainer.h := h
			;Now get current coordinates for tab window placement
			WinGetPos, x,y,w,h,ahk_id %hwnd%
			x+=24
			y+=4
			w-=135
			h:=TabContainerList.height			
			WinMove, ahk_id %TabWindow%,,%x%,%y%,%w%,%h%
			
			;Limit drawing rate to make resizing more smoother
			if(changedsize)
				SetTimer, DrawTabWindow, -20
		
			if (fid != gid) 				;some newer instance of the function was running, so just return (function was interupted by itself). Without this, older instance will continue with old host window position and clients will jump to older location. This is not so visible with WinMove as it is very fast, but SetWindowPos shows this in full light. 
				return		
		}
		;outputdebug updateposition() tab control: w%w%
		;GuiControl, %TabNum%:Move, TabControl, w%w%
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
			;DllCall("AnimateWindow","Ptr",TabWindow,UInt,0,UInt,0x00010000)
		}
	}
	;SuppressTabEvents:=false
}
DrawTabWindow:
DrawTabWindow()
return
/*
 * Recreates Tabs
*/
UpdateTabs()
{
	global
	local TabContainer, hwnd,tabhwnd,folder,tabs
	WasCritical := A_IsCritical
	Critical
	if(!SuppressTabEvents && !NoTabUpdate)
	{
		hwnd:=WinActive("ahk_group ExplorerGroup")
		TabContainer:=TabContainerList.ContainsHWND(hwnd)
		if(hwnd && TabContainer)
		{
			Loop % TabContainer.tabs.len()
			{
				path := GetCurrentFolder(TabContainer.tabs[A_Index].hwnd,1)
				if(path != TabContainer.tabs[A_Index].path)
				{
					TabContainer.tabs[A_Index].path := path
					CalculateTabText(TabContainer.tabs[A_Index])
				}			
			}
			CalculateHorizontalTabPositions(TabContainer)
		}
		SuppressTabEvents:=false
		DrawTabWindow()
	}
	if(!WasCritical)
		Critical, Off
	return
	/*
	SuppressTabEvents:=true
	
	*/
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
	hwnd:=hwnd ? hwnd : WinActive("ahk_group ExplorerGroup")
	if(!hwnd)
	{
		Msgbox CreateTab(): No active tab!
		Return
	}
	WasCritical := A_IsCritical
	Critical
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
		, "ContainsHWND", "TabContainer_ContainsHWND", "print", "TabContainer_Print","add", "TabContainer_Add")
		TabContainer:=Object("base",TabContainerBase)
		TabContainer.add(hwnd)
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
				;DllCall("AnimateWindow","Ptr",hwndnew,UInt,0,UInt,0x00010000)
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
		WinHide ahk_id %hwndnew%
		;DllCall("AnimateWindow","Ptr",hwndnew,UInt,0,UInt,0x00010000) ;Hide again because WinSetPlacement unhides it, but is required for max/restore state
	
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
		;DllCall("AnimateWindow","Ptr",hwnd,UInt,0,UInt,0x00010000)
		outputdebug hide old tab
	}
	if(NewTabPosition=1)
		TabContainer.add(hwndnew,TabContainer.ContainsHWND(hwnd)+1) ;Add new tab right to the current tab
	else if(NewTabPosition=2)
		TabContainer.add(hwndnew) ;Add new tab to end of list
		
	;AddTabButton(TabContainer, hwndnew)
	TabContainerList.Print()
	DetectHiddenWindows, Off
	if(!WinExist("ahk_id " TabWindow))
		Gui %TabNum%:Show, NA
	CalculateVerticalTabPosition(TabContainer,TabContainer.ContainsHWND(hwnd))
	CalculateVerticalTabPosition(TabContainer,TabContainer.ContainsHWND(hwndnew))
	SuppressTabEvents:=false	
	UpdateTabs()
	UpdatePosition(TabNum, TabWindow)
	GuiControl, %TabNum%:MoveDraw, TabControl
	if(!WasCritical)
		Critical, Off
}


ActivateTab(pos)
{
	global TabContainerList, SuppressTabEvents
	outputdebug ActivateTab(%pos%)
	SetWinDelay,-1
	time1 := A_TickCount
	if(TabContainer:=TabContainerList.ContainsHWND(TabContainerList.Active))
	{		
		time2 := A_TickCount
		outputdebug("time2 " time2-time1)
		hwnd:=TabContainer.tabs[pos].hwnd
		;DisableMinimizeAnim(1)
		SuppressTabEvents:=true
		OldTab:=TabContainer.active
		x:=TabContainer.x
		y:=TabContainer.y
		w:=TabContainer.w
		h:=TabContainer.h
		state:=TabContainer.state
		SuppressTabEvents := true
		
		;To hide the old tab without showing the hide anim, it is moved outside of the screen first
		WinMove,ahk_id %OldTab%,,-10000,-10000
		WinHide,ahk_id %OldTab%
		SuppressTabEvents := false
		DetectHiddenWindows, On		
		time3 := A_TickCount
		outputdebug("time3 " time3-time2)
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
		time4 := A_TickCount
		outputdebug("time4 " time4-time3)
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
		;DisableMinimizeAnim(0)
		CalculateVerticalTabPosition(TabContainer,TabContainer.ContainsHWND(hwnd))
		CalculateVerticalTabPosition(TabContainer,TabContainer.ContainsHWND(OldTab))
		
		time5 := A_TickCount
		outputdebug("time5 " time5-time4)
		UpdateTabs()
		
		time6 := A_TickCount
		outputdebug("time6 " time6-time5)
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
	Loop % TabContainer.tabs.len()
	{
		if(TabContainer.tabs[A_Index].hwnd = hwnd)
			return A_Index
	}
	return 0
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
		path:=GetCurrentFolder(TabContainer.tabs[A_Index].hwnd)
		hwnd:=TabContainer.tabs[A_Index].hwnd
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