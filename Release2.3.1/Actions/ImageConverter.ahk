Action_ImageConverter_Init(Action)
{
	Action.Category := "7plus"
	Action.Files := "${SelNM}"
	Action.Hoster := "ImgUr"
	Action.FTPTargetDir := ""
	Action.TemporaryFiles := 0
	Action.ReuseWindow := 0
}

Action_ImageConverter_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Files")
	Action.ReadVar(XMLAction, "Hoster")
	Action.ReadVar(XMLAction, "FTPTargetDir")
	Action.ReadVar(XMLAction, "TemporaryFiles")
	Action.ReadVar(XMLAction, "ReuseWindow")
}
Action_ImageConverter_Execute(Action, Event)
{
	global CImageConverter
	msgbox % Action.Files
	Files := Event.ExpandPlaceholders(Action.Files)
	msgbox % files
	if(Action.ReuseWindow)
		for index, window in CImageConverter.Instances ;Find existing instance of window
			if(window.ReuseWindow)
			{
				ImageConverter := window
				break
			}
	if(!ImageConverter)
		ImageConverter := New("CImageConverter", Action)
	ImageConverter.AddFiles(Files)
	return 1
}

Action_ImageConverter_DisplayString(Action)
{
	return "Open Image Converter: " Action.Files
} 
Action_ImageConverter_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	global FTPProfiles
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Files", "", "", "Files:", "Placeholders", "Action_ImageConverter_Placeholders")
		Loop % FTPProfiles.len()
			Hosters .= "|" A_Index ": " FTPProfiles[A_Index].Hostname
		Hosters .= "|" GetImageHosterList().ToString("|")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Hoster", Hosters, "", "IMG Hoster:","","","","","FTP profiles which are created on their specific sub page in the settings window can be used here.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "FTPTargetDir", "", "", "FTP Target dir:", "Placeholders", "Action_ImageConverter_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "TemporaryFiles", "Temporary files", "", "", "", "","","","If set, source files will be deleted after operation.")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "ReuseWindow", "Reuse window", "", "", "", "","","","If set, all files from an action with this property will be added to the same window.`nIt's best if they are also located in the same directory.")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Files")
	else if(GoToLabel = "TargetFolder")
		SubEventGUI_Placeholders(sActionGUI, "FTPTargetDir")
}
Action_ImageConverter_Placeholders:
Action_ImageConverter_GuiShow("", "", "Placeholders")
return
Action_ImageConverter_Placeholders_TargetFolder:
Action_ImageConverter_GuiShow("", "", "TargetFolder")
return
Action_ImageConverter_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 