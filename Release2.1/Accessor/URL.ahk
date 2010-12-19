Accessor_URL_Init(ByRef URL, Settings)
{
	global ConfigPath
	URL.KeywordOnly := false
	URL.MinChars := 3
	URL.OKName := "Open URL"
	URL.Description := "This plugin allows to open URLs in the browser and also has a history function."
	URL.HasSettings := true
	URL.Settings.UseHistory := Settings.UseHistory
	URL.Settings.MaxHistoryLen := Settings.MaxHistoryLen
	URL.Settings.SaveHistoryOnExit := Settings.SaveHistoryOnExit
	URL.History := Array()
		outputdebug % "create list new len: " URL.History.len()
	if(!FileExist(ConfigPath "\History.xml"))
		return
	FileRead, xml, %ConfigPath%\History.xml
	XMLObject := XML_Read(xml)
	;Convert empty and single arrays to real array
	if(!XMLObject.List.len())
		XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()		
	
	Loop % min(XMLObject.List.len(), URL.Settings.MaxHistoryLen)
	{
		XMLObjectListEntry := XMLObject.List[A_Index]
		HistoryURL := XMLObjectListEntry.URL
		URL.History.append(Object("URL",HistoryURL))
	}
}
Accessor_URL_ShowSettings(URL, PluginSettings, PluginGUI)
{	
	SubEventGUI_Add(PluginSettings, PluginGUI, "Checkbox", "UseHistory", "Use history", "", "")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Checkbox", "SaveHistoryOnExit", "Save history on exit", "", "")
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "MaxHistoryLen", "", "", "History length:","Clear history","Accessor_URL_ClearHistory")
}
Accessor_URL_ClearHistory:
Accessor_URL_ClearHistory()
return
Accessor_URL_ClearHistory()
{
	global AccessorPlugins
	URLPlugin := AccessorPlugins.SubItem("Type","URL")
	URLPlugin.History := Array()
}
Accessor_URL_IsInSinglePluginContext(URL, Filter, LastFilter)
{
	return IsURL(Filter)
}
Accessor_URL_GetDisplayStrings(URL, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	; Title := AccessorListEntry.titleNoFormatting
	; Path := AccessorListEntry.visibleUrl
	; Detail1 := AccessorListEntry.Detail1
	; Detail2 := AccessorListEntry.Detail2
}
Accessor_URL_OnAccessorOpen(URL, Accessor)
{
}
Accessor_URL_OnAccessorClose(URL, Accessor)
{
}
Accessor_URL_OnExit(URL)
{
	global ConfigPath
	FileDelete, %ConfigPath%\History.xml
	if(!URL.Settings.SaveHistoryOnExit)
		return
	XMLObject := Object("List",Array())
	Loop % URL.History.len()
		XMLObject.List.append(Object("URL",URL.History[A_Index].URL))
	XML_Save(XMLObject,ConfigPath "\History.xml")
}
Accessor_URL_FillAccessorList(URL, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	;ImageList_ReplaceIcon(Accessor.ImageListID, -1, URL.Icon)
	; IconCount++
	outputdebug Accessor_URL_FillAccessorList %filter%
	if(!CouldBeURL(Filter))
		return
	outputdebug couldbeurl
	Filter := strTrim(Filter, " ")
	if(pos := RegexMatch(Filter, "\${(\d+)}", Parameter) && (ArgumentsStart := InStr(Filter, " ")))
	{
		Parameters := Array()
		outputdebug placeholder %Parameter1%
		Parameters.append(Parameter1)
		p0 := Parse(Filter, "1 2 3 4 5 6 7 8 9 10", Filter, p1, p2, p3, p4, p5, p6, p7, p8, p9)
		while(pos := RegexMatch(Filter, "\${(\d+)}", Parameter, pos + 1))
			Parameters.append(Parameter1)
		
		Loop % Parameters.len()
		{
			outputdebug % "param " A_Index ": " p%A_Index%
			Filter := StringReplace(Filter, "${" A_Index "}", p%A_Index%)
		}
	}
	outputdebug url filter %filter%
	Accessor.List.append(Object("Title",Filter,"Path", "Open URL", "Type","URL", "Detail1", "URL", "Detail2", "","Icon", 3))
	if(URL.Settings.UseHistory)
	{
		outputdebug % "history len: " URL.History.len()
		Loop % URL.History.len()
		{
			outputdebug % history URL.History[A_Index].URL
			if(InStr(URL.History[A_Index].URL, Filter) && URL.History[A_Index].URL != Filter && CouldBeURL(URL.History[A_Index].URL))
				Accessor.List.append(Object("Title", URL.History[A_Index].URL, "Path", "Open URL", "Type", "URL", "Detail1", "URL", "Detail2", "","Icon", 3, "History", true))
		}
	}
}
Accessor_URL_PerformAction(URLPlugin, Accessor, AccessorListEntry)
{
	global AccessorEdit
	if(AccessorListEntry.Title)
	{
		if(URLPlugin.Settings.UseHistory)
		{			
			if(index := URLPlugin.History.indexOfSubItem("URL",AccessorListEntry.Title)) ;Move existing items to the top
				URLPlugin.History.Delete(index)
			URLPlugin.History.append(Object("URL", AccessorListEntry.Title)) ;Add entered item to the top
			if(URLPlugin.History.len() > URLPlugin.Settings.MaxHistoryLen) ;Make sure history len is not exceeded
				URLPlugin.History.Delete(1)
		}
		outputdebug % "append new len: " URLPlugin.History.len()
		url := (!InStr(AccessorListEntry.Title, "://") ? "http://" : "") AccessorListEntry.Title
		run %url%
	}
	return
}
Accessor_URL_ListViewEvents(URL, AccessorListEntry)
{
}
Accessor_URL_EditEvents(URL, AccessorListEntry, Filter, LastFilter)
{
}
Accessor_URL_OnKeyDown(URL, wParam, lParam, Filter, selected, AccessorListEntry)
{
}
Accessor_URL_SetupContextMenu(URL, AccessorListEntry)
{
	Menu, AccessorMenu, add, Open URL, AccessorOK
}