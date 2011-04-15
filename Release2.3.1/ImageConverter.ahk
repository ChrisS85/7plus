ImageConverter(Files)
{
	global ImageConverter_ListView,ImageConverter_Picture,ImageConverter_Radio1,ImageConverter_Radio2,ImageConverter_AbsWidth,ImageConverter_AbsHeight
	global ImageConverter_RelWidth,ImageConverter_RelHeight,ImageConverter_KeepAspectRatio,ImageConverter_TargetExtension,ImageConverter_DeleteOldFiles
	global ImageConverter_OverwriteFiles,ImageConverter_Quality,ImageConverter_txtQuality,ImageConverter_Lock,ImageQuality, Vista7
	static sFiles, GUINum, hwndImageConverter_Picture, AspectRatio, LastChanged, w, h, lastPos, Targets
	if(!IsObject(Files))
		Files := ToArray(Files)
	if(Files.len() < 1)
	{
		Msgbox Image Converter: No files selected!
		return
	}
	Loop % Files.len()
	{
		SplitPath(Files[A_Index], "", "", Extension)
		if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
		{
			Msgbox % Files[A_Index] " is no supported image format!"
			return
		}
	}
	;Check if ImageConverter window is already open
	if(GuiNum)
	{		
		Gui, ListView, ImageConverter_ListView
		Offset := LV_GetCount()
		Added := false
		Loop % Files.len()
		{
			if(sFiles.IndexOf(Files[A_Index]) = 0)
			{
				SplitPath(Files[A_Index], Filename)
				LV_Add("",A_Index + Offset, Filename)
				sFiles.append(Files[A_Index])
				Added := true
			}
		}
		if(Added)
			GoSub ImageConverter_FillTargetFilenames
		Gui, %GUINum%:Show
		return
	}
	lastPos := ""
	sFiles := Files.DeepCopy()
	GUINum := GetFreeGUINum(7)
	Gui, %GUINum%:Default
	Gui, Add, ListView, -Multi AltSubmit gImageConverter_ListView vImageConverter_ListView r15 w300, #|File|Target Filename
	LV_ModifyCol(1, 0)
	LV_ModifyCol(2,150)
	LV_ModifyCol(3,"AutoHdr")
	Loop % sFiles.len()
	{
		SplitPath(sFiles[A_Index], Filename)
		LV_Add("",A_Index, Filename)
	}
	Gui, Add, Picture, vImageConverter_Picture hwndhwndImageConverter_Picture gImageConverter_Picture x+10 w400 h270 +0xE +0x40;+0xE is needed for setting the picture to a hbitmap
	Gui, Add, GroupBox, x10 y300 w300 h100, Resize
	Gui, Add, Radio, vImageConverter_Radio1 x20 y320 gImageConverter_RadioClicked, Absolute [px]
	Gui, Add, Radio, vImageConverter_Radio2 x20 y350 Checked gImageConverter_RadioClicked, Relative  [`%]
	Gui, Add, Text, x110 y320, Width:
	Gui, Add, Text, x110 y350, Width:
	Gui, Add, Text, x210 y320, Height:
	Gui, Add, Text, x210 y350, Height:
	Gui, Add, Edit, vImageConverter_AbsWidth x150 y316 w50 disabled gImageConverter_AbsWidthChanged, 0
	Gui, Add, Edit, vImageConverter_AbsHeight x250 y316 w50 disabled gImageConverter_AbsHeightChanged, 0
	Gui, Add, Edit, vImageConverter_RelWidth x150 y346 w50 gImageConverter_RelWidthChanged, 0
	Gui, Add, Edit, vImageConverter_RelHeight x250 y346 w50 gImageConverter_RelHeightChanged, 0
	Gui, Add, Checkbox, vImageConverter_KeepAspectRatio x20 y375 Checked gImageConverter_KeepAspectRatio, Keep aspect ratio
	Gui, Add, Text, x320 y315, Target Format:
	Gui, Add, DropDownList, vImageConverter_TargetExtension gImageConverter_TargetExtension Choose1 x410 y311, Keep Extension|bmp|dib|rle|jpg||jpeg|jpe|jfif|gif|tif|tiff|png
	Gui, Add, Text, vImageConverter_txtQuality x550 y315 hidden, Quality:
	Gui, Add, Edit, vImageConverter_Quality x590 y311 hidden, %ImageQuality%
	Gui, Add, Checkbox, vImageConverter_OverwriteFiles gImageConverter_FillTargetFilenames x320 y345, Overwrite existing files
	Gui, Add, Checkbox, vImageConverter_DeleteOldFiles x320 y375, Delete source files
	Gui, Add, Button, x450 y400 w80 gImageConverter_OK, OK
	Gui, Add, Button, x540 y400 w80 gImageConverter_Cancel, Cancel
	OnMessage(WM_COMMAND:=0x111,"ImageConverter_MessageHandler")
	LV_Modify(1,"Select")
	GoSub ImageConverter_TargetExtension
	Gui, Show, Autosize, Image Converter
	return
	
	ImageConverter_ListView:
	if(A_GUIEvent = "I" && InStr(ErrorLevel, "S", true)) ;Listview item selected
	{
		pos := LV_GetNext("")
		if(pos <= 0)
			pos := max(LV_GetNext(0,"Focused"),1)
		if(pos != lastPos)
		{
			pBitmap := Gdip_CreateBitmapFromFile(sFiles[pos])
			w := Gdip_GetImageWidth(pBitmap)
			h := Gdip_GetImageHeight(pBitmap)
			AspectRatio := w/h
			sw := min(400 / w, 1)
			sh := min(270 / h, 1)
			s := min(sw, sh)
			pThumbnail := Gdip_CreateBitmap(400,270)
			pGraphics := Gdip_GraphicsFromImage(pThumbnail)			
			Gdip_SetInterpolationMode(pGraphics, 7)
			Gdip_DrawImage(pGraphics, pBitmap, 0, 0, w*s, h*s)
			Gdip_DeleteGraphics(pGraphics)
			Gdip_DisposeImage(pBitmap)
			hBitmap := Gdip_CreateHBITMAPFromBitmap(pThumbnail)
			SetImage(hwndImageConverter_Picture, hBitmap)
			DeleteObject(hBitmap)
			Gdip_DisposeImage(pThumbnail)
			GuiControl,, ImageConverter_AbsWidth, %w%
			GuiControl,, ImageConverter_AbsHeight, %h%
			GuiControl,, ImageConverter_RelWidth, 100
			GuiControl,, ImageConverter_RelHeight, 100
		}
		lastPos := pos
	}
	return
	
	ImageConverter_Picture:
	pos := LV_GetNext("")
	if(pos <= 0)
		pos := max(LV_GetNext(0,"Focused"),1)
	run(sFiles[pos])
	return
	
	ImageConverter_RadioClicked:
	Gui, %GUINum%:Submit, NoHide
	GuiControl, %GUINum%:Enable%ImageConverter_Radio1%, ImageConverter_AbsWidth
	GuiControl, %GUINum%:Enable%ImageConverter_Radio1%, ImageConverter_AbsHeight
	GuiControl, %GUINum%:Enable%ImageConverter_Radio2%, ImageConverter_RelWidth
	GuiControl, %GUINum%:Enable%ImageConverter_Radio2%, ImageConverter_RelHeight
	return
	
	ImageConverter_AbsWidthChanged:
	if(ImageConverter_Lock<=0)
	{
		Gui, %GUINum%:Submit, NoHide
		LastChanged := "Width"
		ImageConverter_Lock := 1
		ImageConverter_RelWidth := Round(ImageConverter_AbsWidth / w * 100)
		GuiControl,, ImageConverter_RelWidth, %ImageConverter_RelWidth%
		if(ImageConverter_KeepAspectRatio)
		{
			ImageConverter_Lock += 2
			ImageConverter_AbsHeight := Round(ImageConverter_AbsWidth / AspectRatio)
			ImageConverter_RelHeight := ImageConverter_RelWidth
			GuiControl,, ImageConverter_AbsHeight, %ImageConverter_AbsHeight%
			GuiControl,, ImageConverter_RelHeight, %ImageConverter_RelHeight%
		}
	}
	else
		ImageConverter_Lock--
	return
	
	ImageConverter_AbsHeightChanged:
	if(ImageConverter_Lock<=0)
	{
		Gui, %GUINum%:Submit, NoHide
		LastChanged := "Height"
		ImageConverter_Lock := 1
		ImageConverter_RelHeight := Round(ImageConverter_AbsHeight / h*100)
		GuiControl,, ImageConverter_RelHeight, %ImageConverter_RelHeight%
		if(ImageConverter_KeepAspectRatio)
		{
			ImageConverter_Lock += 2
			ImageConverter_AbsWidth := Round(ImageConverter_AbsHeight * AspectRatio)			
			ImageConverter_RelWidth := ImageConverter_RelHeight
			GuiControl,, ImageConverter_AbsWidth, %ImageConverter_AbsWidth%
			GuiControl,, ImageConverter_RelWidth, %ImageConverter_RelWidth%
		}
	}
	else
		ImageConverter_Lock--
	return
	
	ImageConverter_RelWidthChanged:
	if(ImageConverter_Lock<=0)
	{
		Gui, %GUINum%:Submit, NoHide
		LastChanged := "Width"
		ImageConverter_Lock := 1
		ImageConverter_AbsWidth := Round(w * ImageConverter_RelWidth / 100)
		GuiControl,, ImageConverter_AbsWidth, %ImageConverter_AbsWidth%
		if(ImageConverter_KeepAspectRatio)
		{
			ImageConverter_Lock += 2
			ImageConverter_RelHeight := ImageConverter_RelWidth
			ImageConverter_AbsHeight := Round(h * ImageConverter_RelHeight / 100)
			GuiControl,, ImageConverter_AbsHeight, %ImageConverter_AbsHeight%
			GuiControl,, ImageConverter_RelHeight, %ImageConverter_RelHeight%
		}
	}
	else
		ImageConverter_Lock--
	return
	
	ImageConverter_RelHeightChanged:
	if(ImageConverter_Lock<=0)
	{
		Gui, %GUINum%:Submit, NoHide
		LastChanged := "Height"
		ImageConverter_Lock := 1
		ImageConverter_AbsHeight := Round(h * ImageConverter_RelHeight / 100)
		GuiControl,, ImageConverter_AbsHeight, %ImageConverter_AbsHeight%
		if(ImageConverter_KeepAspectRatio)
		{
			ImageConverter_Lock += 2
			ImageConverter_RelWidth := ImageConverter_RelHeight
			ImageConverter_AbsWidth := Round(w * ImageConverter_RelWidth / 100)
			GuiControl,, ImageConverter_RelWidth, %ImageConverter_RelWidth%
			GuiControl,, ImageConverter_AbsWidth, %ImageConverter_AbsWidth%
		}
	}
	else
		ImageConverter_Lock--
	return
	
	ImageConverter_KeepAspectRatio:
	Gui, %GUINum%:Submit, NoHide
	if(ImageConverter_KeepAspectRatio)
	{
		if(LastChanged = "Width")
		{
			if(ImageConverter_Radio1)
				GoSub ImageConverter_AbsWidthChanged
			else
				GoSub ImageConverter_RelWidthChanged
		}
		else
		{
			if(ImageConverter_Radio1)
				GoSub ImageConverter_AbsHeightChanged
			else
				GoSub ImageConverter_RelHeightChanged
		}
	}
	return
	
	ImageConverter_TargetExtension:
	GoSub ImageConverter_FillTargetFilenames
	if ImageConverter_TargetExtension In JPG,JPEG,JPE,JFIF
	{
		GuiControl, Show, ImageConverter_txtQuality
		GuiControl, Show, ImageConverter_Quality
	}
	else
	{
		GuiControl, Hide, ImageConverter_txtQuality
		GuiControl, Hide, ImageConverter_Quality
	}
	return
	
	ImageConverter_FillTargetFilenames:
	Gui, %GUINum%:Submit, NoHide
	Gui, ListView, ImageConverter_ListView
	Targets := Array()
	Loop % LV_GetCount()
	{
		LV_GetText(pos,A_Index,1)
		SplitPath(sFiles[pos], "", dir, Extension, Filename)
		if(ImageConverter_TargetExtension != "Keep extension")
			Extension := ImageConverter_TargetExtension
			
		Testpath := dir "\" Filename "." Extension
		i:=1 ;Find free Filename
		while((!ImageConverter_OverwriteFiles && FileExist(TestPath)) || (Targets.IndexOf(TestPath) > 0 && Targets.IndexOf(TestPath) < pos))
		{
			i++
			Testpath:=dir "\" Filename " (" i ")." Extension
		}
		SplitPath(Testpath,Filename)
		
		Targets[pos] := TestPath
		LV_Modify(A_Index, "Col3", Filename)
	}
	return
	
	ImageConverter_OK:
	Gui, %GUINum%: Submit
	ConvertedImages := Array()
	FailedImages := Array()
	Loop % LV_GetCount()
	{
		LV_GetText(pos,A_Index,1)		
		SplitPath(sFiles[pos],"",FilePath)
		LV_GetText(FileName,A_Index,3)
		FilePath .= "\" FileName
		pBitmap := Gdip_CreateBitmapFromFile(sFiles[pos])
		if(pBitmap > 0)
		{
			;Calculate sizes
			w_old := Gdip_GetImageWidth(pBitmap)
			h_old := Gdip_GetImageHeight(pBitmap)
			AR_old := w_old/h_old
			if(ImageConverter_Radio1)
			{
				w_new := ImageConverter_AbsWidth
				h_new := ImageConverter_AbsHeight
				;Since multiple files can be processed, the aspect ratio might be different.
				;The approach used here looks for the width or height scaling factor that is closer to 1 and applies it to the whole image.
				if(ImageConverter_KeepAspectRatio)
				{
					AR_w := w_new / w_old
					AR_h := h_new / h_old
					if(Abs(AR_w - 1) < Abs(AR_h - 1))
					{
						w_new := w_old * AR_w
						h_new := h_old * AR_w
					}
					else
					{
						w_new := w_old * AR_h
						h_new := h_old * AR_h
					}
				}
			}
			else
			{
				w_new := w_old * ImageConverter_RelWidth / 100
				h_new := h_old * ImageConverter_RelHeight / 100
			}
			
			;Save image
			pConverted := Gdip_CreateBitmap(w_new,h_new)
			pGraphics := Gdip_GraphicsFromImage(pConverted)			
			Gdip_SetInterpolationMode(pGraphics, 7)
			Gdip_DrawImage(pGraphics, pBitmap, 0, 0, w_new, h_new)
			Gdip_DeleteGraphics(pGraphics)
			Gdip_DisposeImage(pBitmap)
			if(Gdip_SaveBitmapToFile(pConverted, FilePath, ImageConverter_ImageQuality) = 0)
				ConvertedImages.append(sFiles[pos])
			else
				FailedImages.append(sFiles[pos])
			Gdip_DisposeImage(pConverted)
			
			;Possibly delete old file
			if(ImageConverter_DeleteOldFiles && !ImageConverter_OverwriteFiles)
				FileDelete, %FilePath%
		}
		else
			FailedImages.append(sFiles[pos])
	}
	if(FailedImages.len() > 0)
	{
		Loop % FailedImages.len()
			Files .= (A_Index := 1 ? "" : "`n") FailedImages[A_Index]
		Notify("Image Conversion failed!", "Failed to convert these files:`n" Files, 5, "GC=555555 TC=White MC=White",Vista7 ? 78 : 110)
	}
	else
		Notify("Image Conversion completed!", "Successfully converted " ConvertedImages.len() " files.", 5, "GC=555555 TC=White MC=White",Vista7 ? 145 : 22)
	
	Gui, %GUINum%: Destroy
	GUINum := ""
	return
	
	ImageConverter_Escape:
	ImageConverter_Close:
	ImageConverter_Cancel:
	Gui, %GUINum%: Destroy
	GUINum := ""
	return
}
ImageConverter_MessageHandler(wParam, lParam, msg, hwnd)
{
	global
	static aw,ah,rw,rh,quality
	local Word1:=(wParam&0xFFFF0000)>>16
	local WM_COMMAND:=0x111
	local EN_SETFOCUS:=0x100 
	local EN_KILLFOCUS:=0x200
	local aw_h,ah_h,rw_h,rh_h,quality_h
	GuiControlGet, aw_h, Hwnd, ImageConverter_AbsWidth
	GuiControlGet, ah_h, Hwnd, ImageConverter_AbsHeight
	GuiControlGet, rw_h, Hwnd, ImageConverter_RelWidth
	GuiControlGet, rh_h, Hwnd, ImageConverter_RelHeight
	GuiControlGet, quality_h, Hwnd, ImageConverter_Quality
	if(msg = WM_COMMAND)
	{
		if(lParam = aw_h || lParam = ah_h || lParam = rw_h || lParam = rh_h || lParam = quality_h) ;Handle Focus messages to validate input
		{
			if(Word1 = EN_SETFOCUS)
			{
				GUI, Submit, NoHide
				aw := ImageConverter_AbsWidth
				ah := ImageConverter_AbsHeight
				rw := ImageConverter_RelWidth
				rh := ImageConverter_RelHeight
				quality := ImageConverter_Quality
			}
			else if(Word1 = EN_KILLFOCUS)
			{
				local text
				ControlGetText, text, ,ahk_id %lParam%
				if((!IsNumeric(text) || text <= 0) && lParam != quality_h)
				{
					ImageConverter_Lock := 4
					GuiControl, , ImageConverter_AbsWidth, %aw%
					GuiControl, , ImageConverter_AbsHeight, %ah%
					GuiControl, , ImageConverter_RelWidth, %rw%
					GuiControl, , ImageConverter_RelHeight, %rh%
				}
				else if(lParam = quality_h && (!IsNumeric(text) || text <= 0 || text > 100))					
					GuiControl, , ImageConverter_Quality, %quality%
			}
		}
	}
}