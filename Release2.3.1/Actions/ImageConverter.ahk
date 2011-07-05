Action_ImageConverter_Init(Action)
{
	Action.Category := "7plus"
	Action.Files := "${SelNM}"
	Action.Hoster := "ImgUr"
	Action.FTPTargetDir := ""
}

Action_ImageConverter_ReadXML(Action, XMLAction)
{
	Action.Files := XMLAction.Files
	if(XMLAction.HasKey("Hoster"))
		Action.Hoster := XMLAction.Hoster
	if(XMLAction.HasKey("FTPTargetDir"))
		Action.FTPTargetDir := XMLAction.FTPTargetDir
}
Action_ImageConverter_Execute(Action, Event)
{
	Files := Event.ExpandPlaceholders(Action.Files)
	ImageConverter(Files, Action)
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