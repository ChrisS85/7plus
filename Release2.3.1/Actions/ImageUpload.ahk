Class CImageUploadAction Extends CAction
{
	static Type := RegisterType(CImageUploadAction, "ImageUpload")
	static Category := RegisterCategory(CImageUploadAction, "File")
	static Hoster := "ImgUr"
	static SourceFiles := "${SelNM}" ;All upload actions need to have SourceFiles property (used in ImageConverter)
	static CopyToClipboard := 1

	__New()
	{
		;Setup the message handler for receiving image upload progress notifications
		OnMessage(55556, "Action_ImageUpload_ProgressHandler")
	}
	DisplayString()
	{
		return "Upload images: " this.SourceFiles
	}
	Execute(Event)
	{
		if(!this.HasKey("tmpFiles"))
		{
			Files := Event.ExpandPlaceholders(this.SourceFiles)
			this.tmpFiles := ToArray(Files)
			this.tmpFailed := Array()
			if(this.tmpFiles.MaxIndex() < 1)
				return 0
			else
				this.tmpFile := 1
		}
		if(this.HasKey("tmpFiles"))
		{
			if(this.tmpFile > this.tmpFiles.MaxIndex()) ;All uploads finished
			{
				if(this.CopyToClipboard)
					Clipboard := this.tmpClipboard
				Notify("","",0, "Wait",this.tmpNotifyID)
				if(this.tmpFailed.MaxIndex() = 0)
					Notify("Transfer finished", "File(s) uploaded" (this.CopyToClipboard ? " and copied to clipboard" : ""), 2, "GC=555555 TC=White MC=White",NotifyIcons.Success)
				else if(this.tmpFailed.MaxIndex() = this.tmpFiles.MaxIndex() && this.tmpFiles.MaxIndex() > 0)
					Notify("Transfer failed", "Maybe the file extension is not supported by this hoster?", "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",NotifyIcons.Error)
				else
					Notify("Transfer partially failed", "The following files could not be transferred:`n" this.tmpFailed.ToString() , "5", "GC=555555 AC=FTP_Notify_Error TC=White MC=White",NotifyIcons.Error)
				this.Remove("tmpNotifyID")
				this.Remove("tmpFiles")
				this.Remove("tmpFile")
				this.Remove("tmpClipboard")
				this.Remove("tmpFailed")
				return 1
			}
			Process, Exist, % this.tmpPID
			if(!ErrorLevel || !this.tmpPID) ;No upload process running, start one
			{
				File := this.tmpFiles[this.tmpFile]
				if(!FileExist(File) || !File)
				{
					this.tmpFile++
					return -1
				}
				If(A_IsCompiled)
					run % """" A_ScriptFullPath """ -iu """ File """ " Event.ID " " this.Hoster,,UseErrorLevel, PID
				else
					run % """" A_AhkPath """ """ A_ScriptFullPath """ -iu """ File """ " Event.ID " " this.Hoster,,UseErrorLevel, PID
				this.tmpPID := PID
				return -1
			}
			else ;Upload still running, keep Action in EventSchedule
				return -1
		}
		return 0 ;No files
	}


	GuiShow(GUI, GoToLabel = "")
	{
		static sGUI
		if(GoToLabel = "")
		{
			sGUI := GUI
			this.AddControl(GUI, "Text", "Desc", "This action uploads images to image hosters. Currently only ImgUr is supported, others may follow.")		
			this.AddControl(GUI, "DropDownList", "Hoster", GetImageHosterList().ToString("|"), "", "Hoster:")
			this.AddControl(GUI, "Edit", "SourceFiles", "", "", "Files:", "Placeholders", "Action_ImageUpload_Placeholders_Files")
			this.AddControl(GUI, "Edit", "LinksPlaceholder", "", "", "Links Placeholder:", "", "","","","Name only, without ${}")
			this.AddControl(GUI, "Checkbox", "CopyToClipboard", "Copy links to clipboard")
		}
		else if(GoToLabel = "Placeholders_Files")
			ShowPlaceholderMenu(sGUI, "SourceFiles")
	}
}
Action_ImageUpload_Placeholders_Files:
GetCurrentSubEvent().GuiShow("", "Placeholders_Files")
return

;This is called in the main 7plus process when a status message from an upload process is received
Action_ImageUpload_ProgressHandler(Status, ID)
{
	Event := EventSystem.EventSchedule.GetItemWithValue("ID", ID)
	Action := Event.Actions.GetItemWithValue("Type", "ImageUpload")
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
		Action.tmpFailed.Insert(Action.tmpFiles[Action.tmpFile])
		Action.tmpFile++
	}
	else if(Status >= 0 && Status <= 100) ;Progress notification
	{
		outputdebug progress notification
		if(!Action.HasKey("tmpNotifyID"))
		{
			Action.tmpNotifyID := Notify("Uploading " Action.tmpFiles.MaxIndex() " file" (Action.tmpFiles.MaxIndex() > 1 ? "s" : "" ) " to " Action.Hoster,"File " Action.tmpFile ": " Action.tmpFiles[Action.tmpFile],"","PG=100 GC=555555 TC=White MC=White",NotifyIcons.Internet)
			return
		}
		Notify("","",Status, "Progress",Action.tmpNotifyID)
		Notify("","","File " Action.tmpFile ": " Action.tmpFiles[Action.tmpFile], "Text",Action.tmpNotifyID)
	}
}
	
GetImageHosterList()
{
	return Array("ImgUr")
}

;This function is run in another 7plus process to prevent blocking the only available real thread
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
