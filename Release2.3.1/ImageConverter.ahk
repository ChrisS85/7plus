ImageConverter(Files, Action, GoTo="")
{
	global ImageConverter_ListView,ImageConverter_Picture,ImageConverter_Radio1,ImageConverter_Radio2,ImageConverter_AbsWidth,ImageConverter_AbsHeight,ImageConverter_CropLeft, ImageConverter_CropRight, ImageConverter_CropTop, ImageConverter_CropBottom
	global ImageConverter_RelWidth,ImageConverter_RelHeight,ImageConverter_KeepAspectRatio,ImageConverter_TargetExtension,ImageConverter_DeleteOldFiles, ImageConverter_WhichFiles
	global ImageConverter_OverwriteFiles,ImageConverter_Quality,ImageConverter_txtQuality,ImageConverter_Lock,ImageQuality, Vista7, TemporaryEvents,ImageConverter_FTPTargetDir,ImageConverter_Hoster,FTPProfiles
	static sFiles, GUINum, hwndImageConverter_Picture, AspectRatio, LastChanged, w, h, lastPos, Targets
	if(GoTo)
		GoTo %GoTo%
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
		Gui, %GUINum%:Default
		outputdebug gui open
		Gui, ListView, ImageConverter_ListView
		Offset := LV_GetCount()
		Added := false
		Loop % Files.len()
		{
			outputdebug % "file " files[a_index]
			if(sFiles.IndexOf(Files[A_Index]) = 0)
			{
				SplitPath(Files[A_Index], Filename)
				LV_Add("",A_Index + Offset, Filename)
				outputdebug % "add file " Filename " at " A_Index "+" Offset
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
	Gui, Add, ListView, -Multi AltSubmit gImageConverter_ListView vImageConverter_ListView NoSort r19 w300, #|File|Target Filename
	LV_ModifyCol(1, 0)
	LV_ModifyCol(2,150)
	LV_ModifyCol(3,"AutoHdr")
	Loop % sFiles.len()
	{
		SplitPath(sFiles[A_Index], Filename)
		LV_Add("",A_Index, Filename)
	}
	Gui, Add, Picture, vImageConverter_Picture hwndhwndImageConverter_Picture gImageConverter_Picture x+10 w560 h350 +0xE +0x40;+0xE is needed for setting the picture to a hbitmap
	AddTooltip(hwndImageConverter_Picture, "Click the image to edit it in the registered image editing program. Save it and quit the program to refresh it here. The original files will not be touched until batch conversion is performed.")
	Gui, Add, GroupBox, x10 y360 w300 h100, Resize
	Gui, Add, Radio, vImageConverter_Radio1 x20 y380 gImageConverter_RadioClicked, Absolute [px]
	Gui, Add, Radio, vImageConverter_Radio2 x20 y410 Checked gImageConverter_RadioClicked, Relative  [`%]
	Gui, Add, Text, x110 y380, Width:
	Gui, Add, Text, x110 y410, Width:
	Gui, Add, Text, x210 y380, Height:
	Gui, Add, Text, x210 y410, Height:
	Gui, Add, Edit, vImageConverter_AbsWidth x150 y376 w50 disabled gImageConverter_AbsWidthChanged, 0
	Gui, Add, Edit, vImageConverter_AbsHeight x250 y376 w50 disabled gImageConverter_AbsHeightChanged, 0
	Gui, Add, Edit, vImageConverter_RelWidth x150 y406 w50 gImageConverter_RelWidthChanged, 0
	Gui, Add, Edit, vImageConverter_RelHeight x250 y406 w50 gImageConverter_RelHeightChanged, 0
	Gui, Add, Checkbox, vImageConverter_KeepAspectRatio x20 y435 Checked gImageConverter_KeepAspectRatio, Keep aspect ratio
	Gui, Add, GroupBox, x320 y360 w210 h100 section, Crop
	Gui, Add, Text, xs+10 ys+20, Left:
	Gui, Add, Text, xs+110 ys+20, Right:
	Gui, Add, Text, xs+10 ys+50, Top:
	Gui, Add, Text, xs+110 ys+50, Bottom:
	Gui, Add, Edit, vImageConverter_CropLeft xs+50 y376 w50 gImageConverter_CropLeftChanged, 0
	Gui, Add, Edit, vImageConverter_CropRight xs+150 y376 w50 gImageConverter_CropRightChanged, 0
	Gui, Add, Edit, vImageConverter_CropTop xs+50 y406 w50 gImageConverter_CropTopChanged, 0
	Gui, Add, Edit, vImageConverter_CropBottom xs+150 y406 w50 gImageConverter_CropBottomChanged, 0
	Gui, Add, Text, x540 y375, Target Format:
	Gui, Add, DropDownList, vImageConverter_TargetExtension gImageConverter_TargetExtension Choose1 x630 y371, Keep Extension|bmp|dib|rle|jpg||jpeg|jpe|jfif|gif|tif|tiff|png
	Gui, Add, Text, vImageConverter_txtQuality x770 y375 hidden, Quality:
	Gui, Add, Edit, vImageConverter_Quality x810 y371 hidden, %ImageQuality%
	Gui, Add, Checkbox, vImageConverter_OverwriteFiles gImageConverter_FillTargetFilenames x540 y405, Overwrite existing files
	Gui, Add, Checkbox, vImageConverter_DeleteOldFiles x540 y435, Delete source files
	
	Gui, Add, Text, x10 y486, Upload
	Gui, Add, DropDownList, x+10 y482 w80 vImageConverter_WhichFiles, selected||all
	Gui, Add, Text, x+10 y486, files to:
	Loop % FTPProfiles.len()
		Hosters .= (A_Index != 1 ? "|" : "") A_Index ": " FTPProfiles[A_Index].Hostname (Action.Hoster = A_Index ? "|" : "")
	Hosters .= "|" GetImageHosterList().ToString("|")
	if(!IsNumeric(Action.Hoster))
		Hosters := RegexReplace(Hosters, Action.Hoster "\|?", Action.Hoster "||")
	Gui, Add, DropDownList, x+10 y482 w140 vImageConverter_Hoster gImageConverter_Hoster, %Hosters%
	Gui, Add, Text, x+10 y486, Directory:	
	Gui, Add, Edit, x+10 y482 vImageConverter_FTPTargetDir, % Action.FTPTargetDir
	GoSub ImageConverter_Hoster
	Gui, Add, Button, x+5 y481 gImageConverter_Upload, Upload selected
	Gui, Add, Button, x+10 y481 gImageConverter_CopyToClipboard, Copy to Clipboard
	Gui, Add, Button, x+10 y481 gImageConverter_OK, Convert selected
	Gui, Add, Button, x+10 y481 w60 gImageConverter_Cancel, Cancel
	OnMessage(WM_COMMAND:=0x111,"ImageConverter_MessageHandler")
	LV_Modify(1,"Select")
	GoSub ImageConverter_TargetExtension
	Gui, +LabelImageConverter
	Gui, Show, Autosize, Image Converter
	return
	
	ImageConverter_ListView:
	if(A_GUIEvent = "I" && InStr(ErrorLevel, "S", true)) ;Listview item selected
	{
		pos := LV_GetNext("")
		if(pos <= 0)
			pos := max(LV_GetNext(0,"Focused"),1)
		if(pos != lastPos)
			GoSub ImageConverter_LoadPicture
		lastPos := pos
	}
	return
	
	ImageConverter_LoadPicture:
	outputdebug load picture
	pBitmap := Gdip_CreateBitmapFromFile(sFiles[pos])
	w := Gdip_GetImageWidth(pBitmap)
	h := Gdip_GetImageHeight(pBitmap)
	AspectRatio := w/h
	sw := min(560 / w, 1)
	sh := min(350 / h, 1)
	s := min(sw, sh)
	pThumbnail := Gdip_CreateBitmap(560,350)
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
	return
	
	ImageConverter_Picture:
	pos := LV_GetNext("")
	if(pos <= 0)
		pos := max(LV_GetNext(0,"Focused"),1)
	; DllCall("shell32\ShellExecute", uint, 0, str, "Edit", str, sFiles[Pos], str, "", str, "", int, 1)
	run, % "edit """ sFiles[Pos] """",,UseErrorLevel
	SplitPath(sFiles[Pos], Filename, Path)
	WatchDirectory(Path "|" Filename "\", "ImageConverter_OpenedFileChange")
	outputdebug % "watch " Path "|" Filename "\"
	; WatchDirectory("C:\test*|.jpg\", "ImageConverter_OpenedFileChange")
	; run(sFiles[pos])
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
	
	
	
ImageConverter_CropLeftChanged:
ImageConverter_CropRightChanged:
ImageConverter_CropTopChanged:
ImageConverter_CropBottomChanged:
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
	
	ImageConverter_Hoster: ;Called when hoster is changed
	GuiControlGet, ImageConverter_Hoster
	if(IsNumeric(SubStr(ImageConverter_Hoster, 1, 1)))
		GuiControl, Enable, ImageConverter_FTPTargetDir
	else
		GuiControl, Disable, ImageConverter_FTPTargetDir
	return
	
	ImageConverter_CopyToClipboard:
	Gui, %GUINum%: Submit, NoHide
	Selected := LV_GetNext()
	LV_GetText(pos,Selected,1)		
	LV_GetText(FileName,Selected,3)		
	SplitPath(sFiles[pos],"",FilePath)
	FilePath .= "\" FileName
	pConverted := ConvertImage(sFiles[pos], FilePath, ImageConverter_Radio1,ImageConverter_AbsWidth,ImageConverter_AbsHeight,ImageConverter_KeepAspectRatio,ImageConverter_RelWidth,ImageConverter_RelHeight, changed)
	if(pConverted)
	{
		Gdip_SetBitmapToClipboard(pConverted)
		Gdip_DisposeImage(pConverted)
	}
	else
		Msgbox Failed to convert image!
	Loop % sFiles.len()
	{
		if(!InStr(sFiles[A_Index], "temp\7plus\"))
		{
			DontClose := true
			break
		}
	}
	if(!DontClose)
		GoSub ImageConverter_Cancel
	return
	
	ImageConverter_Upload:
	ImageConverter_OK:
	Gui, %GUINum%: Submit
	ConvertedImages := Array()
	FailedImages := Array()
	Loop % LV_GetCount()
	{
		LV_GetText(pos,A_Index,1)		
		LV_GetText(FileName,A_Index,3)		
		SplitPath(sFiles[pos],"",FilePath)
		LV_GetText(FileName,A_Index,3)		
		FilePath .= "\" FileName
		pConverted := ConvertImage(sFiles[pos], FilePath, ImageConverter_Radio1,ImageConverter_AbsWidth,ImageConverter_AbsHeight,ImageConverter_KeepAspectRatio,ImageConverter_RelWidth,ImageConverter_RelHeight, changed)
		if(pConverted)
		{
			if(!changed || Gdip_SaveBitmapToFile(pConverted, A_ThisLabel = "ImageConverter_OK" ? FilePath : sFiles[pos], ImageConverter_Quality) = 0)
				ConvertedImages.append(A_ThisLabel = "ImageConverter_OK" ? FilePath : sFiles[pos])
			else
				FailedImages.append(A_ThisLabel = "ImageConverter_OK" ? FilePath : sFiles[pos])
			Gdip_DisposeImage(pConverted)
			
			;Possibly delete old file
			if(A_ThisLabel = "ImageConverter_OK" && ImageConverter_DeleteOldFiles && !ImageConverter_OverwriteFiles)
				FileDelete, %FilePath%
		}
		else
			FailedImages.append(sFiles[pos])
	}
	if(A_ThisLabel = "ImageConverter_OK")
	{
		if(FailedImages.len() > 0)
		{
			Loop % FailedImages.len()
				Files .= (A_Index := 1 ? "" : "`n") FailedImages[A_Index]
			Notify("Image Conversion failed!", "Failed to convert these files:`n" Files, 5, "GC=555555 TC=White MC=White",Vista7 ? 78 : 110)
		}
		else
			Notify("Image Conversion completed!", "Successfully converted " ConvertedImages.len() " files.", 5, "GC=555555 TC=White MC=White",Vista7 ? 145 : 22)
	}
	else if(A_ThisLabel = "ImageConverter_Upload")
	{
		;Let's build an event that uploads the files using the selected hoster and deletes them afterwards (if they are temporary (screenshot) files located in temp dir)
		Event := EventSystem_CreateEvent()
		GuiControlGet, ImageConverter_Hoster
		if(IsNumeric(SubStr(ImageConverter_Hoster, 1,max(InStr(ImageConverter_Hoster, ":") - 1, 1))))
		{
			GuiControlGet, ImageConverter_FTPTargetDir
			Event.Actions.append(EventSystem_CreateSubEvent("Action","Upload"))
			Event.Actions[1].SourceFiles := ConvertedImages
			Event.Actions[1].TargetFolder := ImageConverter_FTPTargetDir
			Event.Actions[1].FTPProfile := SubStr(ImageConverter_Hoster, 1,max(InStr(ImageConverter_Hoster, ":") - 1, 1))
		}
		else
		{
			Event.Actions.append(EventSystem_CreateSubEvent("Action","ImageUpload"))
			Event.Actions[1].Files := ConvertedImages
		}
		Loop % ConvertedImages.len()
		{
			if(InStr(ConvertedImages[A_Index], "temp\7plus\"))
			{
				Action := EventSystem_CreateSubEvent("Action","Delete")
				Action.SourceFile := ConvertedImages[A_Index]
				Action.Silent := 1
				Event.Actions.append(Action)
			}
		}
		TemporaryEvents.RegisterEvent(Event)
		TriggerSingleEvent(Event)
	}
	GoSub ImageConverter_Cleanup
	return
	
	ImageConverterEscape:
	ImageConverterClose:
	ImageConverter_Cancel:
	Loop % sFiles.len() ;Delete temporary images (from screenshot actions and similar)
	{
		if(InStr(sFiles[A_Index], "temp\7plus\"))
			FileDelete, % sFiles[A_Index]
	}
	GoSub ImageConverter_Cleanup
	return
	
	ImageConverter_Cleanup:
	Gui, %GUINum%: Destroy	
	GUINum := ""
	sFiles := ""
	hwndImageConverter_Picture := 0
	AspectRatio := 0
	LastChanged := ""
	w := 0
	h := 0
	lastPos := 0
	Targets := ""
	PID := 0
	return
}
ImageConverter_OpenedFileChange(from, to)
{
	outputdebug file change %from% %to%
	ImageConverter("","","ImageConverter_LoadPicture")
	WatchDirectory(from, "")
}
ConvertImage(OldFile, NewFile, ImageConverter_Radio1,ImageConverter_AbsWidth,ImageConverter_AbsHeight,ImageConverter_KeepAspectRatio,ImageConverter_RelWidth,ImageConverter_RelHeight, ByRef changed)
{
	Changed := false
	pBitmap := Gdip_CreateBitmapFromFile(OldFile)
	if(pBitmap > 0)
	{
		SplitPath(OldFile,"","",OldExt)		
		SplitPath(NewFile,"","",NewExt)
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
		if(w_new != w_old || h_new != h_old)
		{
			pConverted := Gdip_CreateBitmap(w_new,h_new)
			pGraphics := Gdip_GraphicsFromImage(pConverted)			
			Gdip_SetInterpolationMode(pGraphics, 7)
			Gdip_DrawImage(pGraphics, pBitmap, 0, 0, w_new, h_new)
			Gdip_DeleteGraphics(pGraphics)
			Gdip_DisposeImage(pBitmap)
			changed := true
		}
		else
		{
			pConverted := pBitmap
			pBitmap := ""
		}
		if(OldExt != NewExt || (A_ThisLabel = "ImageConverter_OK" && OldFile != NewFile))
			changed := true
		return pConverted
	}
	return 0
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