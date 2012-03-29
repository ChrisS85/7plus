Class CNotesPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Notes", CNotesPlugin)
	
	Description := "This plugin allows to take notes and view them later."
	
	;List of stored notes
	List := Array()

	Icon := ExtractIcon("shell32.dll", 115, 64)

	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "Note"
		KeywordOnly := true
		MinChars := 0
	}

	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Copy note", "Copy")
			__new(NewNote = false)
			{
				if(NewNote)
					this.DefaultAction := new CAccessor.CAction("Create note", "CreateNote")
				else
					this.Insert(new CAccessor.CAction("Delete note", "DeleteNote"))
			}
		}
		Type := "Notes"
		__new(NewNote = false)
		{
			this.Actions := new this.CActions(NewNote)
		}
	}
	Init()
	{
		if(!FileExist(Settings.ConfigPath "\Notes.xml"))
			return
		FileRead, xml, % Settings.ConfigPath "\Notes.xml"
		XMLObject := XML_Read(xml)
		;Convert empty and single arrays to real array
		if(IsObject(XMLObject) && IsObject(XMLObject.List))
		{
			if(!XMLObject.List.MaxIndex())
				XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		
		
			for index, XMLObjectListEntry in XMLObject.List
				this.List.Insert(Object("Text", XMLObjectListEntry.Text))
		}
	}
	OnExit(Accessor)
	{
		FileDelete, % Settings.ConfigPath "\Notes.xml"
		XMLObject := Object("List", Array())
		for index, item in this.List
			XMLObject.List.Insert(Object("Text", item.Text))
		XML_Save(XMLObject, Settings.ConfigPath "\Notes.xml")
		DestroyIcon(this.Icon)
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		if(!Filter && Accessor.CurrentSelection)
			Filter := Accessor.CurrentSelection
		if(Filter)
		{
			Result := new this.CResult(true)
			Result.Title := "New note:"
			Result.Path := Filter
			Result.Detail1 := "Notes"
			Result.Icon := this.Icon
			Results.Insert(Result)
		}
		for index, note in this.List
		{
			Result := new this.CResult()
			Result.Title := note.Text
			Result.Path := ""
			Result.Detail1 := "Notes"
			Result.ID := index
			Result.Icon := this.Icon
			Results.Insert(Result)
		}
		return Results
	}
	ShowSettings(PluginSettings, Accessor, PluginGUI)
	{
	}
	Copy(Accessor, ListEntry)
	{
		Clipboard := ListEntry.Title
	}
	CreateNote(Accessor, ListEntry)
	{
		if(ListEntry.Path)
		{
			this.List.Insert(Object("Text", ListEntry.Path))
			Accessor.RefreshList()
		}
		return true
	}
	DeleteNote(Accessor, ListEntry)
	{
		if(ListEntry.ID)
		{
			this.List.Remove(ListEntry.ID)
			Accessor.RefreshList()
		}
		return true
	}
}