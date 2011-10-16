;TODO:
;-When a 7plus dialog is shown while a slide window was activated(not through border), it mostly happens that the window doesn't slide out.
;If it does, it sometimes gets activated improperly after confirming the dialog. The window is not lost anymore however. Activating it again in taskbar makes it slide in.
;TODO on Return:
;FileOpen Dialog messes up on XP when sliding out
;Issue with window position on Clearlooks skin (offset of 3, i.e. y=3 is recognized as 0)
;Shift in key dialog showing in two lines
;
Class CSlideWindow
{
	;Slide Directions:
	;0=no/invalid direction
	;1=left, 2=top, 3=right, 4=bottom
	
	;Slide States:
	;-1: not a slide window (yet)
	;0: Hidden
	;1: Visible
	;2: Sliding in
	;3: Sliding out
	;4: Releasing
	__New(hwnd, Direction)
	{
		global SlideWindows
		if(!SlideWindows.CanAddSlideWindow(hwnd, Direction))
			return 0
		this.hwnd := hwnd
		this.SlideState := -1
		this.Direction := Direction
		; this.ParentWindows := GetParentWindows(hwnd) ;Parent windows might be used later to dynamically consider this window at screen borders
		this.GetChildWindows(0) ;Child windows are fetched when sliding takes place so they're more recent, but the always on top state is stored here the first time
		WinGet, ExStyle, ExStyle, % "ahk_id " this.hwnd
		this.WasOnTop := ExStyle & 0x8
		this.OriginalPosition := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.len()
			this.ChildWindows.OriginalPosition := WinGetPos("ahk_id " this.ChildWindows.hwnd)
		this.SlideOut()
	}
	__Delete()
	{
		if(this.SlideState = 0) ;only release windows that were not already released
			this.Release()
	}
	;This function slides a window into the screen, making it visible
	SlideIn()
	{
		DetectHiddenWindows, On
		;Disable Minimize/Restore animation
		RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		VarSetCapacity(struct, 8, 0)
		NumPut(8, struct, 0, "UInt")
		NumPut(0, struct, 4, "Int")
		DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		this.GetChildWindows(0)
		SetWinDelay 0
		this.SlideState:=2
		Loop % this.ChildWindows.len() + 1 ;Set all windows to always on top
		{
			hwnd := A_Index = 1 ? this.hwnd : this.ChildWindows[A_Index - 1].hwnd
			WinSet, AlwaysOnTop, On , ahk_id %hwnd%
			if(Settings.Windows.SlideWindows.HideSlideWindows)
			{
				if(A_Index = 1 || this.ChildWindows[A_Index - 1].WasVisible)
					WinShow ahk_id %hwnd%
			}
		}
		WinActivate % "ahk_id " this.Active
		
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualRight, VirtualBottom) ;We want the coordinates of the upper left and lower right point
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		
		;Calculate target position
		this.Position := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.len()
			this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
		if(this.Direction = 1) ;Left
		{
			this.ToX := VirtualLeft
			this.ToY := this.Position.y
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := max(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualLeft)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
		}
		else if(this.Direction = 2) ;Top
		{
			this.ToX := this.Position.x
			this.ToY := VirtualTop
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := max(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualTop)
			}
		}
		else if(this.Direction = 3) ;Right
		{
			this.ToX := VirtualRight - this.Position.w
			this.ToY := this.Position.y
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := min(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualRight - this.ChildWindows[A_Index].Position.w)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
		}
		else if(this.Direction = 4) ;Bottom
		{
			this.ToX := this.Position.x
			this.ToY := VirtualBottom - this.Position.h
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := min(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualBottom - this.ChildWindows[A_Index].Position.h)
			}
		}
		this.Move()
		this.SlideState:=1
		;Possibly activate Minimize animation again
		if(Animate=1)
		{
			NumPut(1, struct, 4, "UInt")
			DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		}
	}
	;This function slides a window outside the screen, hiding it
	SlideOut()
	{
		DetectHiddenWindows, On
		;Disable Minimize/Restore animation
		RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		VarSetCapacity(struct, 8, 0)	
		NumPut(8, struct, 0, "UInt")
		NumPut(0, struct, 4, "Int")
		DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		SetWinDelay 0
		this.SlideState:=3
		this.GetChildWindows(1) ;Update the current visibility state of child windows
		Active := WinExist("A")+0 ;Store the active slide/child window so it can be activated on next slide in
		if(this.hwnd = Active)
			this.Active := Active
		else if(this.ChildWindows.IndexOfSubItem("hwnd", Active))
			this.Active := Active
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualRight, VirtualBottom) ;We want the coordinates of the upper left and lower right point
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		
		;Calculate target position
		this.Position := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.len()
			this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
		if(this.Direction = 1) ;Left
		{
			this.ToX := VirtualLeft - this.Position.w
			this.ToY := this.Position.y
			Loop % this.ChildWindows.len() ;Correct for offset of child windows
				this.ToX := min(this.ToX, this.ToX - ((this.ChildWindows[A_Index].Position.x + this.ChildWindows[A_Index].Position.w) - (this.Position.x + this.Position.w)))
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := min(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x,VirtualLeft - this.ChildWindows[A_Index].Position.w)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
			this.SlideOutPos := this.Position.y
			this.SlideOutLen := this.Position.h
		}
		else if(this.Direction = 2) ;Top
		{
			this.ToX := this.Position.x
			this.ToY := VirtualTop - this.Position.h
			Loop % this.ChildWindows.len() ;Correct for offset of child windows
				this.ToY := min(this.ToY, this.ToY - ((this.ChildWindows[A_Index].Position.y + this.ChildWindows[A_Index].Position.h) - (this.Position.y + this.Position.h)))
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := min(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualTop - this.ChildWindows[A_Index].Position.h)
			}
			this.SlideOutPos := this.Position.x
			this.SlideOutLen := this.Position.w
		}
		else if(this.Direction = 3) ;Right
		{
			this.ToX := VirtualRight
			this.ToY := this.Position.y
			Loop % this.ChildWindows.len() ;Correct for offset of child windows
				this.ToX := max(this.ToX, this.ToX + (this.Position.x - this.ChildWindows[A_Index].Position.x))
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := max(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x,VirtualRight)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
			this.SlideOutPos := this.Position.y
			this.SlideOutLen := this.Position.h
		}
		else if(this.Direction = 4) ;Bottom
		{
			this.ToX := this.Position.x
			this.ToY := VirtualBottom
			Loop % this.ChildWindows.len() ;Correct for offset of child windows
				this.ToY := max(this.ToY, this.ToY + (this.Position.y - this.ChildWindows[A_Index].Position.y))
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := max(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y,VirtualBottom)
			}
			this.SlideOutPos := this.Position.x
			this.SlideOutLen := this.Position.w
		}
		this.Move()
		Loop this.ChildWindows.len() + 1 ;hide/minimize all child windows and main window
		{
			hwnd := A_Index = 1 ? this.hwnd : this.ChildWindows[A_Index - 1].hwnd
			
			if(Settings.Windows.SlideWindows.HideSlideWindows)
				WinHide, ahk_id %hwnd%
			else
			{
				;~ WinMinimize ahk_id %hwnd%
				PostMessage, 0x112, 0xF020,,, ahk_id %hwnd% ;Winminimize, but apparently more reliable
				;~ DllCall("ShowWindow","Ptr", hwnd, "UINT", 6) ;#define SW_MINIMIZE         6 SW_FORCEMINIMIZE    11
			}
		}
		this.SlideState:=0
		;Possibly activate Minimize animation again
		if(Animate=1)
		{
			NumPut(1, struct, 4, "UInt")
			DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		}
	}
	;This function moves all involved windows to the stored coordinates
	Move()
	{
		Moved := true
		while(Moved) ;While target position is not reached, move all child windows and the main window
		{
			Moved := false
			diffX:=this.toX-this.Position.x
			diffY:=this.toY-this.Position.y
			StepX:=Round(absmin(dirmax(diffX*2/10,10),diffX))
			StepY:=Round(absmin(dirmax(diffY*2/10,10),diffY))
			if(StepX != 0 || StepY != 0)
			{
				this.Position.x += StepX
				this.Position.y += StepY
				WinMove, % "ahk_id " this.hwnd,, % this.Position.x, % this.Position.y
				Moved := true
			}
			Loop % this.ChildWindows.len() ;Move all child windows
			{
				hwnd := this.ChildWindows[A_Index].hwnd
				diffX:=this.ChildWindows[A_Index].toX-this.ChildWindows[A_Index].Position.x
				diffY:=this.ChildWindows[A_Index].toY-this.ChildWindows[A_Index].Position.y
				StepX:=Round(absmin(dirmax(diffX*2/10,10),diffX))
				StepY:=Round(absmin(dirmax(diffY*2/10,10),diffY))
			
				WinGet, minstate , minmax, ahk_id %hwnd% ;Don't move child windows which might be hidden/minimized
				if(minstate=-1)
					continue
				if(StepX = 0 && StepY = 0)
					continue
				this.ChildWindows[A_Index].Position.x += StepX
				this.ChildWindows[A_Index].Position.y += StepY
				WinMove, ahk_id %hwnd%,, % this.ChildWindows[A_Index].Position.x, % this.ChildWindows[A_Index].Position.y
				Moved := true
			}
			Sleep 10
		}
		this.Remove("Position")
		this.Remove("ToX")
		this.Remove("ToY")
		Loop % this.ChildWindows.len()
		{
			this.ChildWindows[A_Index].Remove("Position")
			this.ChildWindows[A_Index].Remove("ToX")
			this.ChildWindows[A_Index].Remove("ToY")	
		}
	}
	;This functions removes the "Slide window" property from a window, sliding it in and showing it
	;If Soft is true, the window will not be moved. This is used for releasing because of window moving and resizing
	Release(Soft = 0)
	{
		global SlideWindows
		if(!this.hwnd) ;Make sure the slide window was actually successfully created
			return
		this.SlideState := 4
		if(!Soft)
		{
			this.Position := WinGetPos("ahk_id " this.hwnd)
			this.ToX := this.OriginalPosition.x
			this.ToY := this.OriginalPosition.y
			Loop % this.ChildWindows.len()
			{
				this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].OriginalPosition.x
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].OriginalPosition.y
			}
			this.Move()
		}
		WinSet, AlwaysOnTop, % this.WasOnTop ? "On" : "Off", % "ahk_id " this.hwnd
		Loop % this.ChildWindows.len()
			WinSet, AlwaysOnTop, % this.ChildWindows.WasOnTop ? "On" : "Off", % "ahk_id " this.ChildWindows[A_Index].hwnd
		if(index := SlideWindows.IndexOfSubItem("hwnd", this.hwnd)) ;Remove if not already done so
			SlideWindows.Remove(index)
	}
	;Calculates a bounding box around the slide window and its child windows
	CalculateBoundingBox(ByRef bLeft, ByRef bTop, ByRef bRight, ByRef bBottom)
	{
		WinGetPos, x, y, w, h, % "ahk_id " this.hwnd
		bLeft := x
		bRight := x + w
		bTop := y
		bBottom := y + h
		Loop % this.ChildWindows.len() ;Create a bounding box of all involved windows
		{
			WinGet, Style, Style, % "ahk_id " this.ChildWindows[A_Index].hwnd
			if(!(Style & 0x10000000))
				continue
			WinGetPos l,t,r,b, % "ahk_id " this.ChildWindows[A_Index].hwnd
			r += l
			b += t
			if(l < bLeft) 
				bLeft := l
			if(r > bRight)
				bRight := r
			if(t < bTop)
				bTop := t
			if(b > bBottom)
				bBottom := b
		}
	}
	;Get child windows
	GetChildWindows(UpdateVisibility)
	{
		DetectHiddenWindows, On
		WinGet, Windows, List
		if(!IsObject(this.ChildWindows))
			this.ChildWindows := Array()
		FoundChildWindows := Array()
		Loop % Windows ;Iterate over all windows, find out which ones are child windows of hwnd and add them to the list
		{
			hParent := Windows%A_Index%
			WinGetTitle, title, ahk_id %hParent%
			if(hParent = this.hwnd) ;Skip the window itself
				continue
			while(hParent && hParent != this.hwnd)
				hParent := DllCall("GetParent", "PTR", hParent)
			if(hParent = this.hwnd)
			{
				class := WinGetClass("ahk_id " Windows%A_Index%)
				classParent := WinGetClass("ahk_id " hParent) ;Some stuff here is only added for debugging, may be removed later if all really works fine.
				if(InStr("tooltips_class32,WorkerW,IME,MSCTFIME UI", class)) ;Ignore some common helper windows
					continue
				FoundChildWindows.Insert(Windows%A_Index%)
				WinGet, Style, Style, % "ahk_id " Windows%A_Index% ;Store if the child window is visible
				if(index := this.ChildWindows.IndexOfSubItem("hwnd", Windows%A_Index%)) ;By refreshing the ChildWindows array instead of replacing it, we make sure to keep the original visible and always on top states of child windows
				{
					if(UpdateVisibility)
						this.ChildWindows[index].WasVisible := Style & 0x10000000 ? 1 : 0
					continue
				}
				WinGet, ExStyle, ExStyle, % "ahk_id " Windows%A_Index% ;Also store always on top state of new child windows
				if(this.SlideState = 1) ;Make sure that newly created windows will be set to always on top when the window is already slided out
					WinSet, AlwaysOnTop, On, % "ahk_id " Windows%A_Index%
				this.ChildWindows.Insert(Object("hwnd", Windows%A_Index%, "WasOnTop", ExStyle & 0x8, "WasVisible", Style & 0x10000000, "Class", class, "ClassParent", ClassParent))
			}
		}
		index := 1
		Loop % this.ChildWindows.len() ;Delete loop for child windows which were closed
		{
			if(FoundChildWindows.IndexOf(this.ChildWindows[index].hwnd))
				index++
			else
				this.ChildWindows.Remove(index)
		}
	}
}
Class CSlideWindows
{
	__New()
	{
		this.base.base := Array()
		;Read list of window classes that were closed outside of the screen
		if(FileExist(Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"))
		{
			FileRead, xml, % Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"
			XMLObject := XML_Read(xml)
			this.ClosedWindowsOutsideScreen := XMLObject.Window.len() > 0 ? XMLObject.Window : Array(XMLObject.Window)
		}
		else
			this.ClosedWindowsOutsideScreen := Array()
	}
	__Delete()
	{
		if(this.ClosedWindowsOutsideScreen.len() > 0)
			XML_Save(Object("Window", this.ClosedWindowsOutsideScreen), Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml")
		else
			FileDelete, % Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"
	}
	CanAddSlideWindow(hwnd, Direction)
	{
		Class := WinGetClass("ahk_id " hwnd)
		if(InStr("WorkerW,Progman,Shell_TrayWnd,BaseBar,DV2ControlHost,Static", Class))
			return false
		if(IsFullScreen("A",true,true))
			return false
		if(Direction = GetTaskbarDirection())
			return false
		WinGet, maxstate , minmax, ahk_id %hwnd%
		if(maxstate=1) ;Ignore maximized windows for now
			return
		return this.IsSlideSpaceFree(hwnd, Direction)
	}
	IsSlideSpaceOccupied(px,py,width,height,dir)
	{
		if(dir=1||dir=3)
		{
			Loop % this.len() ;Check all slide windows
			{
				SlideWindow:=this[A_INDEX]
				if(SlideWindow.Direction=dir)
				{
					BorderY:=(Height-2*Settings.Windows.SlideWindows.BorderSize>0) ? Settings.Windows.SlideWindows.BorderSize : 0
					objBorderY:=(SlideWindow.SlideOutLen-2*Settings.Windows.SlideWindows.BorderSize>0) ? Settings.Windows.SlideWindows.BorderSize : 0
					Y1:=pY+borderY
					Y2:=pY+Height-borderY
					objY1:=SlideWindow.SlideOutPos+objBorderY
					objY2:=SlideWindow.SlideOutPos+SlideWindow.SlideOutLen-objBorderY
					if Y1 between %objY1% and %objY2%
						return SlideWindow
					if Y2 between %objY1% and %objY2%
						return SlideWindow
					if objY1 between %Y1% and %Y2%
						return SlideWindow
					if objY2 between %Y1% and %Y2%
						return SlideWindow
				}			
			}
		}
		else if(dir=2||dir=4)
		{
			Loop % this.len() ;Check all slide windows
			{
				SlideWindow:=this[A_INDEX]
				if(SlideWindow.Direction=dir)
				{
					borderX:=(Width-2*Settings.Windows.SlideWindows.BorderSize>0) ? Settings.Windows.SlideWindows.BorderSize : 0
					objBorderX:=(SlideWindow.SlideOutLen-2*Settings.Windows.SlideWindows.BorderSize>0) ? Settings.Windows.SlideWindows.BorderSize : 0
					X1:=pX+borderX
					X2:=pX+Width-borderX
					objX1:=SlideWindow.SlideOutPos+objBorderX
					objX2:=SlideWindow.SlideOutPos+SlideWindow.SlideOutLen-objBorderX
					if X1 between %objX1% and %objX2%
						return SlideWindow
					if X2 between %objX1% and %objX2%
						return SlideWindow
					if objX1 between %X1% and %X2%
						return SlideWindow
					if objX2 between %X1% and %X2%
						return SlideWindow
				}
			}
		}
		return 0
	}
	IsSlideSpaceFree(hwnd,dir)
	{
		if(Settings.Windows.SlideWindows.LimitToOnePerSide)
			return this.IndexOfSubItem("Direction", dir) = 0
		WinGetPos X, Y, Width, Height, ahk_id %hwnd%
		return !this.IsSlideSpaceOccupied(X,Y,Width,Height,dir)
	}
	ReleaseAll()
	{
		global CSlideWindows
		this := new CSlideWindows()
	}
	;This is called when a window gets resized to see if it needs to be released
	CheckResizeReleaseCondition(hwnd)
	{
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		SlideWindow := this.SubItem("hwnd", hwnd)
		if(!SlideWindow)
			return
		if(SlideWindow.SlideState = 0 || SlideWindow.SlideState = 1)
			SlideWindow.Release(SlideWindow.SlideState = 1)
	}
	;This is called when a window gets closed to see if a slide window needs to be released
	WindowClosed(hwnd)
	{
		global WindowList
		index := 1
		Loop % this.len()
		{
			SlideWindow:=this[index]
			if(!WinExist("ahk_id " SlideWindow.hwnd))
				SlideWindow.Release()
			else
				index++
		}
		;Check if a window was closed outside of the screen and add it to a list so it can be moved inside again when it gets opened again
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		if(RectsSeparate(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight, WindowList[hwnd].x, WindowList[hwnd].y, WindowList[hwnd].w, WindowList[hwnd].h))
		{
			class := WindowList[hwnd].class
			if(!this.ClosedWindowsOutsideScreen.IndexOf(class))
				this.ClosedWindowsOutsideScreen.Insert(class)
		}
	}
	;This is called when a window gets activated and takes care of sliding windows out/in that were (de)activated
	WindowActivated()
	{
		if(IsContextMenuActive()) ;Ignore context menus
			return
		hwnd:=WinExist("A")+0
		this.ActivatedWindow := hwnd
		SetTimer, CheckForNewChildWindows, -100
		SlideWindow:=this.GetByWindowHandle(hwnd, ChildIndex)
		if(SlideWindow.SlideState = 1)
			SlideWindow.Active := WinExist("A")+0 ;Last active slide window
		index := this.IndexOfSubItemBetween("SlideState", 1, 4)
		CurrentSlideWindow:=this[index]
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		WinGetPos, x, y, w, h, ahk_id %hwnd%
		class := WinGetClass("ahk_id " hwnd)
		;If a window outside of the screen was activated and it's stored in the list of windows that were closed while being outside of the screen, move it in
		if(!SlideWindow && index := this.ClosedWindowsOutsideScreen.indexOf(class) && RectsSeparate(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight, x, y, w, h))
		{
			WinMove, ahk_id %hwnd%,, % A_ScreenWidth / 2 - w / 2, % A_ScreenHeight / 2 - h / 2
			this.ClosedWindowsOutsideScreen.Remove(index)
		}
		if(CurrentSlideWindow && CurrentSlideWindow = SlideWindow) ;A window from the same slide window group was activated
			return
		if(CurrentSlideWindow)
		{
			WinGet, minstate , minmax, % "ahk_id " CurrentSlideWindow.hwnd
			if(minstate=-1) ;Release slide window that was minimized
				CurrentSlideWindow.Release(1)
			else if(!CurrentSlideWindow.AutoSlideOut)
				CurrentSlideWindow.SlideOut()
		}
		if(SlideWindow && SlideWindow.SlideState = 0)
		{
			WinGet, minstate , minmax, % "ahk_id " SlideWindow.hwnd
			if(minstate!=-1) ;Make sure the window is not minimized anymore
			{
				SlideWindow.AutoSlideOut := false ;Slide windows that were activated directly will only slide out when they're deactivated
				SlideWindow.SlideIn()
			}
		}
	}
	;Slide windows need to monitor window creation to update child window list when appropriate, but this does not seem to work.
	;Instead window activation is monitored with a slight delay that allows the window to set its parent state. Function is only left here for reference.
	WindowCreated(hwnd)
	{
	}
	;Finds a slide window object by one of its windows
	GetByWindowHandle(hwnd, ByRef ChildIndex)
	{
		Loop % this.len()
		{
			if(this[A_Index].hwnd = hwnd)
			{
				ChildIndex := 0
				return this[A_Index]
			}
			else if(ChildIndex := this[A_Index].ChildWindows.IndexOfSubItem("hwnd", hwnd))
				return this[A_Index]
		}
	}
	;This is called when the mouse is moved and takes care of screen border slide window activation and deactivation when the mouse leaves the window
	OnMouseMove(x,y)
	{
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		if(x=VirtualLeft)
			dir=1
		else if(y=VirtualTop)
			dir=2
		else if(x=VirtualLeft+VirtualWidth-1)
			dir=3
		else if(y=VirtualTop+VirtualHeight-1)
			dir=4
		if((z:=GetTaskbarDirection())=dir || z<=0)
			return
		if(this.indexOfSubItemBetween("SlideState", 2, 4)) ;Currently sliding a window, ignore mouse
			return
		;Check if mouse position matches a slide window border and don't slide in while other slide window is on the screen
		SlideWindow:=this.IsSlideSpaceOccupied(x,y,0,0,dir)
		if(dir > 0 && SlideWindow && (!Settings.Windows.SlideWindows.BorderActivationRequiresMouseUp || !GetKeyState("LButton", "P") || GetKeyState(Settings.Windows.SlideWindows.ModifierKey, "P")) && !this.indexOfSubItem("SlideState", 1))
		{
			this.ActiveWindow := WinExist("A")
			SlideWindow.AutoSlideOut := true
			SlideWindow.SlideIn()
			return
		}
		;Now see if mouse is currently over a shown slide window and maybe hide it
		MouseGetPos, , ,win
		win+=0
		SlideWindow:=this.SubItem("SlideState", 1)
		if(SlideWindow && SlideWindow.AutoSlideOut && SlideWindow.hwnd!=win && !SlideWindow.ChildWindows.IndexOfSubItem("hwnd", win) && !IsContextMenuActive() && !GetKeyState(Settings.Windows.SlideWindows.ModifierKey,"P"))
		{
			SlideWindow.SlideOut()
			WinActivate % "ahk_id " this.ActiveWindow
		}
	}
	CheckForNewChildWindows()
	{
		Parents := GetParentWindows(this.ActivatedWindow)
		Loop % Parents.len()
			if(SubItem := this.SubItem("hwnd", Parents[A_Index]))
			{
				SubItem.GetChildWindows(0)
				break
			}
	}
}
CheckForNewChildWindows:
SlideWindows.CheckForNewChildWindows()
return

;Get parent windows, ignoring some default windows
GetParentWindows(hwnd)
{
	Parents := Array()
	hParent := hwnd
	while(true)
	{
		hParent := DllCall("GetParent", "PTR", hParent)
		Class := WinGetClass("ahk_id " hParent)
		if(InStr("WorkerW,Progman,Shell_TrayWnd,BaseBar,DV2ControlHost,Static", Class)) ;Ignore taskbar and desktop windows
			break
		Parents.Insert(hParent)
	}
	return Parents
}

;~ #t::
;~ msgbox % exploreobj(slidewindows)
;~ return
;~ #t::
;~ msgbox % WinGetClass("ahk_id " CurrentWindow) " Previous: " WinGetClass("ahk_id " PreviousWindow)
;~ return
;~ #p::
;~ outputdebug % exploreobj(slidewindows)
;~ return
;~ #^c::
;~ MouseGetPos,,,win
;~ win+=0
;~ WinGet, Windows, List
;~ ChildWindows := Array()
;~ Loop % Windows ;Iterate over all windows, find out which ones are child windows of hwnd and add them to the list
;~ {
	;~ hParent := Windows%A_Index%
	;~ if(hParent = win)
		;~ continue
	;~ while(hParent && hParent != win)
		;~ hParent := DllCall("GetParent", "PTR", hParent)
	;~ if(hParent = win)
		;~ ChildWindows.Insert(WinGetClass("ahk_id " Windows%A_Index%))
;~ }
;~ msgbox % exploreobj(childwindows)
;~ return
;~ #^p::msgbox % WinGetClass("ahk_id " DllCall("GetParent", "PTR", WinExist("A")))
;~ #w::
;~ MouseGetPos,,,win
;~ tooltip % win+0
;~ return
;~ #^t:: 
;~ WinGetTitle, title, % "ahk_id " WinExist("A")
;~ msgbox % title
;~ return
;~ #^w::
;~ DetectHiddenWindows, on
;~ WinGet, Windows, List
;~ list := array()
;~ Loop % Windows
	;~ list.Insert(object("hwnd", Windows%A_Index%, "class", WinGetClass("ahk_id " Windows%A_Index%), "title", WinGetTitle("ahk_id " Windows%A_Index%)))
;~ msgbox % Exploreobj(list)
;~ return