Action_Write_Init(Action)
{
	Action.Category := "File"
	Action.Append := 0
}

Action_Write_ReadXML(Action, XMLAction)
{
	Action.Content := XMLAction.Content
	Action.Target := XMLAction.Target
	Action.Quality := XMLAction.Quality
	Action.Append := XMLAction.Append
	Action.ImageExtension := XMLAction.ImageExtension
}

Action_Write_Execute(Action, Event)
{
	Target := Event.ExpandPlaceholders(Action.Target)
	SplitPath, InputVar ,, OutDir, OutExtension, OutNameNoExt
	if(InStr(Action.Content, "${clip}") && WriteClipboardImageToFile(OutDir "\" OutNameNoExt "." Action.ImageExtension,Action.Quality))
		return
	Content := Event.ExpandPlaceholders(Action.Content)
	if(!Action.Append)
		FileDelete, %Target%
	Content := strTrim(Content,"`r`n")
	Content := strTrim(Content,"`n")
	Content .= "`n"
	FileAppend, %Content%, %Target%
	return 1
} 

Action_Write_DisplayString(Action)
{
	return (Action.Append ? "Append " : "Write ") Action.Content " to " Action.Target
}

Action_Write_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Content", "", "", "Content:", "Placeholders", "Action_Write_Placeholders_Content")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Target", "", "", "Target:", "Browse", "Action_Write_Browse", "Placeholders", "Action_Write_Placeholders_Target")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Quality", "", "", "Image quality:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "ImageExtension", "", "", "Image extension:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Append", "Append text to file")
	}
	else if(GoToLabel = "Placeholders_Content")
		SubEventGUI_Placeholders(sActionGUI, "Content")
	else if(GoToLabel = "Placeholders_Target")
		SubEventGUI_Placeholders(sActionGUI, "Target")
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "Target", "Select File", "", 0, "S2")
}

Action_Write_Placeholders_Content:
Action_Write_GuiShow("", "", "Placeholders_Content")
return
Action_Write_Placeholders_Target:
Action_Write_GuiShow("", "", "Placeholders_Target")
return
Action_Write_Browse:
Action_Write_GuiShow("", "", "Browse")
return

Action_Write_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  