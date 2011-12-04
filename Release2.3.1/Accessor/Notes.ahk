Accessor_Notes_Init(ByRef Notes, PluginSettings)
{
	Notes.Settings.Keyword := "Note"
	Notes.DefaultKeyword := "Note"
	Notes.KeywordOnly := true
	Notes.MinChars := 0
	Notes.OKName := "Show Note"
	Notes.List := Array()
	Notes.Icon := ExtractIcon("shell32.dll", 115, 64)
	Notes.Description := "This plugin allows to take notes and view them later."
	Notes.HasSettings := True
	if(!FileExist(Settings.ConfigPath "\Notes.xml"))
		return
	FileRead, xml, % Settings.ConfigPath "\Notes.xml"
	XMLObject := XML_Read(xml)
	;Convert empty and single arrays to real array
	if(IsObject(XMLObject) && IsObject(XMLObject.List))
	{
		if(!XMLObject.List.MaxIndex())
			XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		
	
		Loop % XMLObject.List.MaxIndex()
		{
			XMLObjectListEntry := XMLObject.List[A_Index]
			Text := XMLObjectListEntry.Text
			Notes.List.Insert(Object("Text",Text))
		}
	}
}
Accessor_Notes_ShowSettings(Notes, PluginSettings, PluginGUI)
{
	AddControl(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
}
Accessor_Notes_IsInSinglePluginContext(Notes, Filter, LastFilter)
{
}
Accessor_Notes_GetDisplayStrings(Notes, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	; Title := AccessorListEntry.titleNoFormatting
	; Path := AccessorListEntry.visibleUrl
	; Detail1 := AccessorListEntry.Detail1
	; Detail2 := AccessorListEntry.Detail2
}
Accessor_Notes_OnAccessorOpen(Notes, Accessor)
{
}
Accessor_Notes_OnAccessorClose(Notes, Accessor)
{
}
Accessor_Notes_OnExit(Notes)
{
	FileDelete, % Settings.ConfigPath "\Notes.xml"
	XMLObject := Object("List",Array())
	Loop % Notes.List.MaxIndex()
		XMLObject.List.Insert(Object("Text",Notes.List[A_Index].Text))
	XML_Save(XMLObject, Settings.ConfigPath "\Notes.xml")
	DestroyIcon(Notes.Icon)
}
Accessor_Notes_FillAccessorList(Notes, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	ImageList_ReplaceIcon(Accessor.ImageListID, -1, Notes.Icon)
	IconCount++
	GUINum := Accessor.GUINum
	if(!GUINum)
		return
	Gui, %GUINum%: Default
	GuiControlGet, Filter, , AccessorEdit
	Filter := strTrimLeft(Filter, Notes.Settings.Keyword " ")
	if(Filter)
		Accessor.List.Insert(Object("Title","New note","Path","Adds a new node", "Type","Notes", "Detail1", "Notes", "Detail2", "","Icon", IconCount))
	outputdebug % "note count " Notes.List.MaxIndex()
	Loop % Notes.List.MaxIndex()
		Accessor.List.Insert(Object("Title",Notes.List[A_Index].Text,"Path","", "Type","Notes", "Detail1", "Notes", "Detail2", "","Icon", IconCount, "ID", A_Index))
}
Accessor_Notes_PerformAction(Notes, Accessor, AccessorListEntry)
{
	global AccessorEdit
	if(AccessorListEntry.Path)
	{
		GUINum := Accessor.GUINum
		if(!GUINum)
			return
		Gui, %GUINum%: Default
		GuiControlGet, Filter, , AccessorEdit
		Filter := strTrimLeft(Filter, Notes.Settings.Keyword " ")
		outputdebug note %filter%
		Notes.List.Insert(Object("Text", Filter))
		outputdebug % "count " Notes.List.MaxIndex()
	}
	else
		MsgBox % AccessorListEntry.Title
	return
}
Accessor_Notes_ListViewEvents(Notes, AccessorListEntry)
{
	if(AccessorListEntry.Path)
		Notes.OKName := "Add note"
	else
		Notes.OKName := "Show note"
}
Accessor_Notes_EditEvents(Notes, AccessorListEntry, Filter, LastFilter)
{
}
Accessor_Notes_OnKeyDown(Notes, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global Accessor
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		NoteCopy()
		return true
	}
	if(wParam = 46)
	{
		Handled := NoteDelete()
		return Handled
	}
}
Accessor_Notes_SetupContextMenu(Notes, AccessorListEntry)
{
	Menu, AccessorMenu, add, Show Note,AccessorOK
	Menu, AccessorMenu, Default,Show Note
	Menu, AccessorMenu, add, Copy note to clipboard (CTRL+C),NoteCopy
	Menu, AccessorMenu, add, Delete note (Delete),NoteDelete
}

NoteCopy:
NoteCopy()
return
NoteCopy()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	if(!Accessor.List[id].Path)
		Clipboard := Accessor.List[id].Title
}
NoteDelete:
NoteDelete()
return
NoteDelete()
{
	global Accessor, AccessorListView, AccessorPlugins
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	Notes := AccessorPlugins.GetItemWithValue("Type", "Notes")
	if(!Accessor.List[id].Path)
	{
		Notes.List.Delete(Accessor.List[id].ID)
		FillAccessorList()
		return true
	}
	return false
}