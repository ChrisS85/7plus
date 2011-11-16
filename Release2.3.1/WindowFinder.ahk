GUI_WindowFinder(PreviousGUINum, GoToLabel="")
{
	static WindowList, sPreviousGUINum, GUINum, WindowFinderView, WindowPicture, hwndWindowPicture, result
	if(GoToLabel = "")
	{
		sPreviousGUINum := PreviousGUINum
		
		Gui, %PreviousGUINum%:+Disabled
		GUINum := GetFreeGuiNum(6)
		Gui, %GUINum%:Default
		Gui, +LabelWindowFinder +Owner%PreviousGUINum% +ToolWindow
		width := 1000
		height := 400
		Gui, Add, ListView, vWindowFinderView gWindowFinderListView r19 w500 AltSubmit -Multi, #|Title|Class|Executable
		ImageList := IL_Create(10,5,0)
		LV_SetImageList(ImageList)
		WindowList := Array()
		DetectHiddenWindows, Off
		WinGet, hwnds, list,,, Program Manager
		Loop, %hwnds%
		{
			OutputDebug hwnd %hwnd%
			hwnd := hwnds%A_Index%
			WinGetClass, class, ahk_id %hwnd%
			WinGetTitle, title, ahk_id %hwnd%
			WinGet, exe, ProcessName, ahk_id %hwnd%
			if((!title && exe != "Explorer.exe") || title = "Edit Event" || title = "7plus Settings" || InStr(class, "Tooltip") || InStr(class, "SysShadow")) ;Filter some windows
				continue
			pBitmap := Gdip_BitmapFromHWND(hwnd)
			w := Gdip_GetImageWidth(pBitmap)
			h := Gdip_GetImageHeight(pBitmap)
			ratio := w/h
			sw := min(500 / w, 1)
			sh := min(330 / h, 1)
			s := min(min(sw, sh), 1)
			pThumbnail := Gdip_CreateBitmap(500,330)
			pGraphics := Gdip_GraphicsFromImage(pThumbnail)			
			Gdip_SetInterpolationMode(pGraphics, 7)
			Gdip_DrawImage(pGraphics, pBitmap, 0, 0, w*s, h*s)
			Gdip_DeleteGraphics(pGraphics)
			Gdip_DisposeImage(pBitmap)
			WindowListEntry := RichObject()
			WindowListEntry.class := class
			WindowListEntry.title := title
			WindowListEntry.Executable := exe
			WindowListEntry.hwnd := hwnd
			WindowListEntry.Bitmap := pThumbnail
			WindowListEntry.hIcon := GetWindowIcon(hwnd,0)
			WindowListEntry.IconNumber := ImageList_ReplaceIcon(ImageList, -1, WindowListEntry.hIcon)
			WindowList.Insert(WindowListEntry)
		}
		;Fill listview
		for i, WindowListEntry in WindowList
			LV_Add((A_Index = 1 ? "Select " : "") "Icon" WindowListEntry.IconNumber +1 , A_Index, WindowListEntry.Title, WindowListEntry.Class, WindowListEntry.Executable)
		; LV_ModifyCol(1, 0)
		LV_ModifyCol(2, 200)
		LV_ModifyCol(3, 150)
		LV_ModifyCol(4, "AutoHdr")
		Gui, Add, Picture, vWindowPicture hwndhwndWindowPicture x+0 w400 h400 +0xE +0x40 ;+0xE is needed for setting the picture to a hbitmap
		x := Width - 184
		y := Height - 34
		Gui, Add, Button, gWindowFinderOK x%x% y%y% w70 h23, &OK
		x := Width - 104
		Gui, Add, Button, gWindowFinderCancel x%x% y%y% w80 h23, &Cancel
		
		Gui, Show, w%width% h%height%, Window Finder
		
		Gui, +LastFound
		WinGet, WindowFinder_hWnd,ID
		DetectHiddenWindows, Off
		loop
		{
			sleep 250
			IfWinNotExist ahk_id %WindowFinder_hWnd% 
				break
		}
		Gui, %sPreviousGUINum%:Default
		Loop % WindowList.MaxIndex()
		{
			DestroyIcon(WindowList[A_Index].hIcon)
			;~ Gdip_DisposeImage(WindowList[A_Index].pThumbnail)
		}
		return result
	}
	else if(GoToLabel = "WindowFinderListView")
	{
		if(A_GuiEvent="I" && InStr(ErrorLevel, "S", true))
		{			
			LV_GetText(pos,LV_GetNext(),1)
			hBitmap := Gdip_CreateHBITMAPFromBitmap(WindowList[pos].Bitmap)
			SetImage(hwndWindowPicture, hBihtmap)
			DeleteObject(hBitmap)
			;~ GuiControl, MoveDraw, Button1
			;~ GuiControl, MoveDraw, Button2
		}
		else if(A_GuiEvent="DoubleClick")
			GUI_WindowFinder("","WindowFinderOK")
		return
	}
	else if(GoToLabel = "WindowFinderOK")
	{
		LV_GetText(pos,LV_GetNext(""),1)
		result := WindowList[pos].DeepCopy()
		Gui, %sPreviousGUINum%:-Disabled
		Gui, Destroy
		WindowFinder_ClearImages(WindowList)
		return
	}
	else if(GoToLabel = "WindowFinderClose")
	{
		result := ""
		Gui, %sPreviousGUINum%:-Disabled
		Gui, Destroy
		Gui, %sPreviousGUINum%:Default		
		WindowFinder_ClearImages(WindowList)
		return
	}
}

WindowFinderOK:
GUI_WindowFinder("","WindowFinderOK")
return

WindowFinderClose:
WindowFinderEscape:
WindowFinderCancel:
GUI_WindowFinder("","WindowFinderClose")
return
WindowFinderListView:
GUI_WindowFinder("","WindowFinderListView")
return

WindowFinder_ClearImages(WindowList)
{
	enum := WindowList._newEnum()
	while enum[hwnd,WindowListEntry]
		Gdip_DisposeImage(WindowListEntry.Bitmap)
}
