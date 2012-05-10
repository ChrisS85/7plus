Class CClipboardPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Clipboard", CClipboardPlugin)
	
	Description := "This plugin is used to add, search and paste persistent clips stored by the 7plus clipboard manager"

	SaveHistory := false

	AllowDelayedExecution := false
	
	Icon := ExtractIcon("shell32.dll", 261, 64)

	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "clip"
		KeywordOnly := false
		MinChars := 0
	}

	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Paste", "Paste")
		}

		Type := "Clipboard"
		Icon := CClipboardPlugin.Instance.Icon

		__new()
		{
			this.Actions := new this.CActions()
		}
	}
	Class CStoreResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Store clip", "Paste")
		}

		Type := "Clipboard"
		Icon := CClipboardPlugin.Instance.Icon

		__new()
		{
			this.Actions := new this.CActions()
		}
	}
	Init()
	{
	}
	OnExit(Accessor)
	{
	}
	OnOpen(Accessor)
	{
		if(IsEditControlActive())
			this.Priority := 5000 ;Lower priority than most other dynamic priorities, since they are more specialized
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		global ClipboardList
		Results := Array()
		NameResults := Array()
		TextResults := Array()
		if(Accessor.CurrentSelection)
		{
			Result := new this.CStoreResult()
			Result.Title := "Store selected text as clip"
			Result.Path := Accessor.CurrentSelection
			Result.Detail1 := "Clip"
			Result.ClipType := "SelectedText"
			Results.Insert(Result)
		}
		if(StrLen(Filter) >= 2)
		{
			for index, clip in ClipboardList
			{
				if(InStr(clip, Filter))
				{
					Result := new this.CResult()
					Result.Title := index
					Result.Path := clip
					Result.Detail1 := "Clip"
					Result.ClipType := "History"
					Results.Insert(Result)
				}
			}
			for index2, clip in ClipboardList.Persistent
			{
				if(InStr(clip.Name, Filter))
				{
					Result := new this.CResult()
					Result.Title := clip.Name
					Result.Path := clip.Text
					Result.Detail1 := "Clip"
					Result.ClipType := "Persistent"
					Result.Index := index2
					NameResults.Insert(Result)
				}
				else if(InStr(clip.Text, Filter))
				{
					Result := new this.CResult()
					Result.Title := clip.Name
					Result.Path := clip.Text
					Result.Detail1 := "Clip"
					Result.ClipType := "Persistent"
					Result.Index := index2
					TextResults.Insert(Result)
				}
			}
		}
		Results.Extend(NameResults)
		Results.Extend(TextResults)
		return Results
	}
	ShowSettings(PluginSettings, Accessor, PluginGUI)
	{
	}
	Paste(Accessor, ListEntry)
	{
		if(ListEntry.ClipType = "SelectedText")
			AddClip(ListEntry.Path)
		else
		{
			this.ListEntry := ListEntry
			Settimer, CClipboardPlugin_WaitForAccessorClose, -100
		}
	}
	WaitForAccessorClose()
	{
		if(!WinActive("ahk_id " CAccessor.Instance.GUI.hwnd))
		{
			if(this.ListEntry.ClipType = "History")
				PasteText(this.ListEntry.Path)
			else if(this.ListEntry.ClipType = "Persistent")
				PersistentClipboard(this.ListEntry.Index)
			this.Remove("ListEntry")
		}
		else
			Settimer, CClipboardPlugin_WaitForAccessorClose, -100
	}
}
CClipboardPlugin_WaitForAccessorClose:
CClipboardPlugin.Instance.WaitForAccessorClose()
return