Action_Clipboard_Init(Action)
{
	Action.Category := "System"
	Action.InsertType := "Text"
	Action.Content := ""
	Action.Clear := 1
	Action.Cut := 0
	Action.Append := 0
}

Action_Clipboard_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "InsertType")
	Action.ReadVar(XMLAction, "Content")
	Action.ReadVar(XMLAction, "Clear")
	Action.ReadVar(XMLAction, "Cut")
	Action.ReadVar(XMLAction, "Append")
}

Action_Clipboard_Execute(Action, Event)
{
	global ImageExtensions
	Content := Event.ExpandPlaceholders(Action.Content)
	if(Action.InsertType = "Text")
	{
		text := ReadClipboardText()
		Clipboard := (Action.Append ? text "`r`n": "") Content
	}
	else if(Action.InsertType = "File")
	{
		if(Action.Append)
			AppendToClipboard( Content, Action.Cut)
		else
			CopyToClipboard(Content, Action.Clear, Action.Cut)
	}
	else if(Action.InsertType = "FileContent")
	{
		textfiles := Content
		SplitByExtension(textfiles, imagefiles, ImageExtensions)
		if(textfiles.len() > 0 && FileExist(textfiles[1]))
		{
			file := textfiles[1]
			FileRead, content, %file%
			Clipboard := Action.Append ? Clipboard content : content
		}
		else if(imagefiles.len() > 0 && FileExist(imagefiles[1]))
			Gdip_ImageToClipboard(imagefiles[1])
	}
	return 1
} 

Action_Clipboard_DisplayString(Action)
{
	if(Action.InsertType = "Text")
		return (Action.Append ? "Append " : "Write ") Action.Content " to clipboard"
	else if(Action.InsertType = "File")
		return (Action.Append ? "Append " : "Copy ") Action.Content " to clipboard"
	else if(Action.InsertType = "FileContent")
		return (Action.Append ? "Append " : "Copy ") "content of " Action.Content " to clipboard"
}

Action_Clipboard_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action writes text,text from files or files(copy/move) to the clipboard.")
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "InsertType", "Text|File|FileContent", "", "Write:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Content", "", "", "Content:", "Browse", "Action_Clipboard_Browse", "Placeholders", "Action_Clipboard_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Clear", "Clear Clipboard first (might be neccessary)", "", "")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Append", "Append to clipboard (not for images)", "", "")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "Cut", "Cut files instead of copy (only for files)", "", "")
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_SelectFile(sActionGUI, "Content")
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Content")
}
Action_Clipboard_Browse:
Action_Clipboard_GuiShow(Action, ActionGUI, "Browse")
return

Action_Clipboard_Placeholders:
Action_Clipboard_GuiShow(Action, ActionGUI, "Placeholders")
return

Action_Clipboard_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 