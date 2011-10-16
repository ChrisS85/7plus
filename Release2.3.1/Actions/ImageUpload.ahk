Action_ImageUpload_Init(Action)
{
	Action.Category := "File"
	Action.Hoster := "ImgUr"
	Action.SourceFiles := "${SelNM}" ;All upload actions need to have SourceFiles property (used in ImageConverter)
	Action.CopyToClipboard := 1
}

Action_ImageUpload_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Hoster")
	Action.ReadVar(XMLAction, "SourceFiles")
	Action.ReadVar(XMLAction, "CopyToClipboard")
}

Action_ImageUpload_DisplayString(Action)
{
	return "Upload images: " Action.SourceFiles
}
Action_ImageUpload_Execute(Action, Event)
{
	global Vista7
	if(!Action.HasKey("tmpFiles"))
	{
		Action.tmpFiles := ToArray(Event.ExpandPlaceholders(Action.SourceFiles))
		Action.tmpFailed := Array()
		if(Action.tmpFiles.len() < 1)
			return 0
		else
			Action.tmpFile := 1
	}
	if(Action.HasKey("tmpFiles"))
	{
		if(Action.tmpFile > Action.tmpFiles.len()) ;All uploads finished
		{
			if(Action.CopyToClipboard)
				Clipboard := Action.tmpClipboard
			Notify("","",0, "Wait",Action.tmpNotifyID)
			if(Action.tmpFailed.len() = 0)
				Notify("Transfer finished", "File(s) uploaded" (Action.CopyToClipboard ? " and copied to clipboard" : ""), 2, "GC=555555 TC=White MC=White",NotifyIcons.Success)
			else if(Action.tmpFailed.len() = Action.tmpFiles.len() && Action.tmpFiles.len() > 0)
				Notify("Transfer failed", "Maybe the file extension is not supported by this hoster?", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",NotifyIcons.Error)
			else
				Notify("Transfer partially failed", "The following files could not be transferred:`n" Action.tmpFailed.ToString() , "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",NotifyIcons.Error)
			Action.Remove("tmpNotifyID")
			Action.Remove("tmpFiles")
			Action.Remove("tmpFile")
			Action.Remove("tmpClipboard")
			Action.Remove("tmpFailed")
			return 1
		}
		Process, Exist, % Action.tmpPID
		if(!ErrorLevel || !Action.tmpPID) ;No upload process running, start one
		{
			File := Action.tmpFiles[Action.tmpFile]
			if(!FileExist(File) || !File)
			{
				Action.tmpFile++
				return -1
			}
			If(A_IsCompiled)
				run % """" A_ScriptFullPath """ -iu """ File """ " Event.ID " " Action.Hoster,,UseErrorLevel, PID
			else
				run % """" A_AhkPath """ """ A_ScriptFullPath """ -iu """ File """ " Event.ID " " Action.Hoster,,UseErrorLevel, PID
			Action.tmpPID := PID
			return -1
		}
		else ;Upload still running, keep Action in EventSchedule
			return -1
	}
	return 0 ;No files
}
;This handles progress from upload processes
Action_ImageUpload_ProgressHandler(Status, ID)
{
	global EventSchedule
	Event := EventSchedule.SubItem("ID", ID)
	Action := Event.Actions.SubItem("Type", "ImageUpload")
	if(Status = 102) ;Upload completed
	{
		;Code to read link and copy to clipboard
		FileRead, Link, %A_Temp%\7plus\Upload%ID%.txt
		FileDelete, %A_Temp%\7plus\Upload%ID%.txt
		Action.tmpClipboard .= (Action.tmpClipboard ? "`n" : "") Link
		Action.tmpFile++
	}
	else if(Status = 101) ;Error
	{
		Action.tmpFailed.Append(Action.tmpFiles[Action.tmpFile])
		Action.tmpFile++
	}
	else if(Status >= 0 && Status <= 100) ;Progress notification
	{
		outputdebug progress notification
		if(!Action.HasKey("tmpNotifyID"))
		{
			Action.tmpNotifyID := Notify("Uploading " Action.tmpFiles.len() " file" (Action.tmpFiles.len() > 1 ? "s" : "" ) " to " Action.Hoster,"File " Action.tmpFile ": " Action.tmpFiles[Action.tmpFile],"","PG=100 GC=555555 TC=White MC=White",NotifyIcons.Internet)
			return
		}
		Notify("","",Status, "Progress",Action.tmpNotifyID)
		Notify("","","File " Action.tmpFile ": " Action.tmpFiles[Action.tmpFile], "Text",Action.tmpNotifyID)
	}
}

Action_ImageUpload_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action uploads images to image hosters. Currently only ImgUr is supported, others may follow.")		
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Hoster", GetImageHosterList().ToString("|"), "", "Hoster:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "SourceFiles", "", "", "Files:", "Placeholders", "Action_ImageUpload_Placeholders_Files")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "LinksPlaceholder", "", "", "Links Placeholder:", "", "","","","Name only, without ${}")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "CopyToClipboard", "Copy links to clipboard")
	}
	else if(GoToLabel = "Placeholders_Files")
		SubEventGUI_Placeholders(sActionGUI, "SourceFiles")
}
Action_ImageUpload_Placeholders_Files:
Action_ImageUpload_GuiShow("", "", "Placeholders_Files")
return

Action_ImageUpload_GUISubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}
GetImageHosterList()
{
	return Array("ImgUr")
}
;This function is run in a second 7plus process
ImageUploadThread(ParameterIndex,7plusHWND)
{
	global
	static File, ID, Hoster, s7plusHWND
	local URL
	if(!s7plusHWND)
	{
		s7plusHWND := 7plusHWND
		ParameterIndex++
		File := %ParameterIndex%
		ParameterIndex++
		ID := %ParameterIndex%
		ParameterIndex++
		Hoster := %ParameterIndex%
		if(!FileExist(File))
		{
			SendMessage, 55556, 101,ID,,ahk_id %7plusHWND% ;Upload failed
			ExitApp
		}
		URL := %Hoster%_Upload(File,xml)
		 If(URL)
		 {
			FileAppend, %URL%, %A_Temp%\7plus\Upload%ID%.txt
			SendMessage, 55556, 102, ID,,ahk_id %7plusHWND% ;Upload completed
			ExitApp
		 }
		 else
		{
			SendMessage, 55556, 101,ID,,ahk_id %7plusHWND% ;Upload failed
			ExitApp
		}
	}
	else ;Function is also used as progress callback, in this case the first parameter is progress in percent, 2nd is total file size
	{
		If(ParameterIndex <= 0 && ParameterIndex >= -1)
			SendMessage, 55556, Round((ParameterIndex + 1) * 100),ID,,ahk_id %s7plusHWND% ;Upload progress message
	}
}

Imgur_Upload( image_file, byref output_XML="" ) { ; ----------------------------- 
; Uploads one image file to Imgur via the anonymous API and returns the URL to the image. 
; To acquire an anonymous API key, please register at http://imgur.com/register/api_anon. 
; This function was written by [VxE] and relies on the HTTPRequest function, also by [VxE]. 
; HTTPRequest can be found at http://www.autohotkey.com/forum/viewtopic.php?t=73040 
   Static Imgur_Upload_Endpoint := "http://api.imgur.com/2/upload.xml" 
   Static Anonymous_API_Key := Decrypt("F5QTo=^aqmf^h|C}@ERLI;GG;T>sjV""t")
   FileGetSize, size, % image_file 
   FileRead, output_XML, % "*c " image_file 
   If HTTPRequest( Imgur_Upload_Endpoint "?key=" Anonymous_API_Key, output_XML 
      , Response_Headers := "Content-Type: application/octet-stream`nContent-Length: " size 
      , "Callback: ImageUploadThread" ) 
   && ( pos := InStr( output_XML, "<original>" ) ) 
      Return SubStr( output_XML, pos + 10, Instr( output_XML, "</original>", 0, pos ) - pos - 10 ) 
   Else Return "" ; error: see response 
} ; Imgur_Upload( image_path, Anonymous_API_Key, byref output_XML="" ) ----------------------------- 

XML_MakePretty( XML, Tab="`t" ) { ; ---------------------------------------------------------------- 
; Function by [VxE]. Adds newlines and tabs between XML tags to give human-friendly arrangement to 
; an XML stream. 'Tab' contains the string to use as an indentation unit (it may be more readable to 
; use 2 or 3 spaces instead of a full tab... so it's up to you!). 
   oel := ErrorLevel, PrevCloseTag := 0, tabs := "", tablen := StrLen( tab ) 
   StringLen, pos, XML 
   Loop, Parse, XML, <, % "`t`r`n " 
      If ( A_Index = 1 ) 
         VarSetCapacity( XML, pos, 0 ) 
      Else 
      { 
         StringGetPos, pos, A_LoopField, > 
         StringMid, b, A_LoopField, pos, 1 
         StringLeft, a, A_LoopField, 1 
         If !( OpenTag := a != "/" ) * ( CloseTag := a = "/" || a = "!" || a = "?" || b = "/" ) 
            StringTrimRight, tabs, tabs, tablen 
         XML .= ( OpenTag || PrevCloseTag ? tabs : "" ) "<" A_LoopField 
         If !( PrevCloseTag := CloseTag ) * OpenTag 
            tabs := ( tabs = "" ? "`n" : tabs ) tab 
      } 
   Return XML, ErrorLevel := oel 
} ; XML_MakePretty( XML, Tab="`t" ) ----------------------------------------------------------------